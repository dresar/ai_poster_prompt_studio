import { Request, Response, NextFunction } from "express";
import { AIGatewayService } from "../ai-gateway/ai-gateway.service";
import { db } from "../../config/db";
import {
  users,
  prompts,
  appSettings,
  visualStyles,
  logs,
  contentIdeas,
  licenseKeys,
  characters,
  dropdownOptions,
} from "../../db/schema";
import { eq, and, gte, sql, asc } from "drizzle-orm";
import { AppError } from "../../middlewares/errorHandler";
import { env } from "../../config/env";
import { logger } from "../../config/logger";
import { PayloadSchema, VideoPayloadSchema, AdvancedVideoPayloadSchema } from "./payload.schema";
import { renderDSL } from "./dslRenderer";
import https from "https";
import crypto from "crypto";
import path from "path";
import fs from "fs";

const aiService = new AIGatewayService();

// Helper to check user daily quota
async function checkQuota(userId: string): Promise<void> {
  const foundUsers = await db
    .select()
    .from(users)
    .where(eq(users.id, userId))
    .limit(1);
  const user = foundUsers[0];

  if (!user) {
    throw new AppError("Pengguna tidak ditemukan.", 404, "NOT_FOUND");
  }

  // Quota bypass - subscription status is no longer enforced
  return;
}

export const analyzeTopic = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { topic } = req.body;
    const analysis = await aiService.analyzeTopic(topic);

    res.status(200).json({
      success: true,
      data: analysis,
    });
  } catch (error) {
    next(error);
  }
};

export const generatePoster = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = req.user!.id;

    // 1. Quota check
    await checkQuota(userId);

    const formState = req.body;

    // ── AI Auto-Recommendation ──
    // When user selects 'auto' or leaves fields empty, instruct AI to choose best options
    const autoFields: string[] = [];
    const fieldLabels: Record<string, string> = {
      style: "gaya visual",
      layout: "tata letak",
      colorPalette: "palet warna",
      mood: "nuansa/mood",
      textRule: "aturan teks",
      characterFocus: "fokus karakter",
      aspectRatio: "rasio aspek",
    };

    for (const [field, label] of Object.entries(fieldLabels)) {
      if (!formState[field] || formState[field] === "auto") {
        autoFields.push(label);
      }
    }

    if (autoFields.length > 0) {
      formState._aiAutoRecommend = true;
      formState._autoFields = autoFields;
      formState._autoInstruction = `Kamu HARUS memilih sendiri ${autoFields.join(", ")} yang paling optimal dan menarik berdasarkan topik "${formState.topic}". Pilih kombinasi yang menghasilkan desain paling viral dan eye-catching.`;
    }

    // 2. Build dropdown specifications string by resolving helperText from database
    const getDropdownHelperText = async (
      value: string | undefined,
    ): Promise<string> => {
      if (!value || value === "auto" || value === "random") return "";
      const optionArr = await db
        .select({ helperText: dropdownOptions.helperText })
        .from(dropdownOptions)
        .where(
          and(
            eq(dropdownOptions.value, value),
            eq(dropdownOptions.isActive, true),
          ),
        )
        .limit(1);
      return optionArr[0]?.helperText || value;
    };

    const resolvedColorPalette = await getDropdownHelperText(
      formState.colorPalette,
    );
    const resolvedMood = await getDropdownHelperText(
      formState.mood || formState.theme,
    );
    const resolvedAspectRatio = await getDropdownHelperText(
      formState.aspectRatio,
    );
    const resolvedLayout = await getDropdownHelperText(formState.layout);
    const resolvedTextRule = await getDropdownHelperText(
      formState.textRule || formState.textRules,
    );
    const resolvedCta = await getDropdownHelperText(
      formState.cta || formState.callToAction,
    );

    const dropdownSpecs: string[] = [];
    if (resolvedColorPalette)
      dropdownSpecs.push(`Color Palette: ${resolvedColorPalette}.`);
    if (resolvedMood) dropdownSpecs.push(`Mood/Vibe: ${resolvedMood}.`);
    if (resolvedAspectRatio)
      dropdownSpecs.push(`Aspect Ratio: ${resolvedAspectRatio}.`);
    if (resolvedLayout) dropdownSpecs.push(`Layout Format: ${resolvedLayout}.`);
    if (resolvedTextRule)
      dropdownSpecs.push(`Typography/Text Rule: ${resolvedTextRule}.`);
    if (resolvedCta)
      dropdownSpecs.push(`Call-to-Action (CTA) Rule: ${resolvedCta}.`);
    const resolvedDropdownPrompt = dropdownSpecs.join(" ");

    // 2.5. Resolve visual style template from database if selected
    let styleTemplate = "";
    if (formState.style && formState.style !== "auto") {
      const visualStyleObjArr = await db
        .select()
        .from(visualStyles)
        .where(
          and(
            eq(visualStyles.name, formState.style),
            eq(visualStyles.isActive, true),
          ),
        )
        .limit(1);
      const visualStyleObj = visualStyleObjArr[0];
      if (visualStyleObj) {
        styleTemplate = visualStyleObj.promptTemplate;
      }
    }

    // 2.6. Resolve character focus prompt consistency if a specific character is selected
    let resolvedCharacterPrompt = '';
    let resolvedCharacterObj: any = null;
    if (formState.characterFocus && !['auto', 'random', 'product_only'].includes(formState.characterFocus)) {
      const characterObjArr = await db.select().from(characters)
        .where(and(eq(characters.id, formState.characterFocus), eq(characters.isActive, true)))
        .limit(1);
      const characterObj = characterObjArr[0];
      if (characterObj) {
        resolvedCharacterObj = characterObj;
        let charPrompt = `Character Name: ${characterObj.name}.`;
        if (characterObj.masterPrompt) {
          charPrompt += ` STRICT MASTER PROMPT: ${characterObj.masterPrompt}.`;
        } else if (characterObj.promptConsistency) {
          charPrompt += ` Visual Consistency Rule: ${characterObj.promptConsistency}.`;
        }
        if (characterObj.positivePrompt) {
          charPrompt += ` POSITIVE TAGS: ${characterObj.positivePrompt}.`;
        }
        if (characterObj.negativePrompt) {
          charPrompt += ` NEGATIVE TAGS (DO NOT DRAW): ${characterObj.negativePrompt}.`;
        }
        resolvedCharacterPrompt = charPrompt;
      }
    }

    // 3. Reference image analysis if provided
    let aiAnalysis = null;
    if (formState.referenceImageUrl) {
      aiAnalysis = await aiService.analyzeReferenceImage(formState.referenceImageUrl);
    }

    const payloadState = {
      ...formState,
      styleTemplate,
      characterFocusPrompt: resolvedCharacterPrompt,
      characterFocusObj: resolvedCharacterObj,
      dropdownSpecs: resolvedDropdownPrompt,
      referenceImage: {
        url: formState.referenceImageUrl || null,
        aiAnalysis,
      },
    };

    // 4. Generate prompt
    let payloadJson: any;
    let promptFinal = "";
    const isStrict = env.USE_STRICT_PAYLOAD_SCHEMA === "true";

    try {
      const result = await aiService.generatePrompt(payloadState);
      payloadJson = result.payloadJson;

      if (isStrict) {
        let schema: any = PayloadSchema;
        if (formState.feature === "video") schema = VideoPayloadSchema;
        else if (formState.feature === "advanced_video") schema = AdvancedVideoPayloadSchema;
        // Validate with Zod
        const parsedData = schema.safeParse(payloadJson);
        if (!parsedData.success) {
          logger.error(
            `AI generated payload failed schema validation: ${parsedData.error.message}. Retrying once...`,
          );
          // Retry logic (1x)
          const retryResult = await aiService.generatePrompt(
            payloadState,
            parsedData.error.message,
          );
          payloadJson = retryResult.payloadJson;
          const parsedRetry = schema.safeParse(payloadJson);
          if (!parsedRetry.success) {
            logger.error(
              `Retry failed schema validation: ${parsedRetry.error.message}`,
            );
            throw new AppError(
              "AI_SCHEMA_MISMATCH",
              502,
              "Failed to generate valid strict payload structure from AI.",
            );
          }
          payloadJson = parsedRetry.data;
        } else {
          payloadJson = parsedData.data;
        }
        promptFinal = result.promptFinal;
      } else {
        promptFinal = result.promptFinal;
      }
    } catch (e: any) {
      if (e.name === "AppError" || e.statusCode === 502) {
        throw e;
      }
      throw new AppError(`Prompt generation failed: ${e.message}`, 500);
    }

    // 5. Calculate viral score & hooks
    const viralData = await aiService.scoreViral(promptFinal);
    const generatedHooks = payloadJson.output?.hooks || [];
    const fallbackHooks = await aiService.generateHooks(formState.topic);
    const finalHooks =
      generatedHooks.length > 0 ? generatedHooks : fallbackHooks;

    payloadJson.output = {
      ...payloadJson.output,
      promptFinal,
      viralScore: viralData.score,
      hooks: finalHooks,
    };

    // 6. Save prompt to DB
    const promptId = crypto.randomUUID();
    const schemaVersion = isStrict ? "v2" : "v1"; // v2 for strict schema
    const [savedPrompt] = await db
      .insert(prompts)
      .values({
        id: promptId,
        userId,
        mode: formState.feature || "poster",
        topic: formState.topic || "Untitled",
        payloadJson: payloadJson,
        promptFinal: promptFinal,
        referenceImageUrl: formState.referenceImageUrl || null,
        category: formState.feature || "poster",
        hooks: finalHooks,
        viralScore: viralData.score,
        schemaVersion,
      })
      .returning();

    // Decrement credits for PRO user
    const foundUsers = await db
      .select()
      .from(users)
      .where(eq(users.id, userId))
      .limit(1);
    const userObj = foundUsers[0];
    if (userObj && userObj.subscriptionStatus === "PRO") {
      await db
        .update(users)
        .set({ credits: sql`credits - 1` })
        .where(eq(users.id, userId));
    }

    // 7. Write audit log
    await db.insert(logs).values({
      id: crypto.randomUUID(),
      userId,
      action: "generate_poster_prompt",
      detail: { promptId: savedPrompt.id, topic: formState.topic },
    });

    res.status(201).json({
      success: true,
      message: "Poster prompt generated successfully",
      data: {
        prompt: savedPrompt,
        viralBreakdown: viralData.breakdown,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const generateEnhance = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = req.user!.id;

    // 1. Quota check
    await checkQuota(userId);

    const { imageUrl, enhanceStyle, changeLevel, notes } = req.body;

    if (!imageUrl) {
      throw new AppError(
        "imageUrl is required for photo enhancement",
        400,
        "BAD_REQUEST",
      );
    }

    // 2. Gemini Vision: analyze photo AND generate structured enhance prompt
    const { payloadJson, promptFinal } = await aiService.generateEnhancePrompt(
      imageUrl,
      enhanceStyle || "kpop_aesthetic",
      changeLevel || "natural",
      notes || "",
    );

    // 3. Score viral potential
    const viralData = await aiService.scoreViral(promptFinal);

    // 4. Merge viral score into payload
    payloadJson.output = {
      ...payloadJson.output,
      promptFinal,
      viralScore: viralData.score,
    };

    // 5. Save to DB
    const promptId = crypto.randomUUID();
    const [savedPrompt] = await db
      .insert(prompts)
      .values({
        id: promptId,
        userId,
        mode: "photo_enhance",
        topic: `Enhance: ${enhanceStyle || "kpop_aesthetic"}`,
        payloadJson: payloadJson,
        promptFinal: promptFinal,
        referenceImageUrl: imageUrl,
        category: enhanceStyle || "kpop_aesthetic",
        hooks: payloadJson?.output?.hooks || [],
        viralScore: viralData.score,
      })
      .returning();

    // 6. Decrement credits for PRO user
    const foundUsers = await db
      .select()
      .from(users)
      .where(eq(users.id, userId))
      .limit(1);
    const userObj = foundUsers[0];
    if (userObj && userObj.subscriptionStatus === "PRO") {
      await db
        .update(users)
        .set({ credits: sql`credits - 1` })
        .where(eq(users.id, userId));
    }

    // 7. Write audit log
    await db.insert(logs).values({
      id: crypto.randomUUID(),
      userId,
      action: "generate_enhance_prompt",
      detail: { promptId: savedPrompt.id, enhanceStyle, imageUrl },
    });

    res.status(201).json({
      success: true,
      message: "Photo enhancement prompt generated successfully",
      data: {
        prompt: savedPrompt,
        viralBreakdown: viralData.breakdown,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getContentIdeas = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { category } = req.query;
    const userId = req.user!.id;
    const ideas = await aiService.generateContentIdeas(
      userId,
      String(category),
    );

    // Save each recommended idea to the ContentIdea table
    await Promise.all(
      ideas.map((idea) =>
        db.insert(contentIdeas).values({
          id: crypto.randomUUID(),
          userId,
          category: String(category),
          idea,
        }),
      ),
    );

    res.status(200).json({
      success: true,
      data: ideas,
    });
  } catch (error) {
    next(error);
  }
};

export const getHooks = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { topic } = req.query;
    const hooks = await aiService.generateHooks(String(topic));

    res.status(200).json({
      success: true,
      data: hooks,
    });
  } catch (error) {
    next(error);
  }
};

export const improvePrompt = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { promptDraft } = req.body;
    const improved = await aiService.improvePrompt(promptDraft);

    res.status(200).json({
      success: true,
      data: improved,
    });
  } catch (error) {
    next(error);
  }
};

export const getPublicVisualStyles = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const styles = await db
      .select({
        id: visualStyles.id,
        name: visualStyles.name,
        promptTemplate: visualStyles.promptTemplate,
        previewImageUrl: visualStyles.previewImageUrl,
      })
      .from(visualStyles)
      .where(eq(visualStyles.isActive, true))
      .orderBy(asc(visualStyles.name));

    res.status(200).json({
      success: true,
      data: styles,
    });
  } catch (error) {
    next(error);
  }
};

export const getPublicCharacters = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const list = await db
      .select({
        id: characters.id,
        name: characters.name,
        description: characters.description,
        imageUrl: characters.imageUrl,
        promptConsistency: characters.promptConsistency,
        category: characters.category,
      })
      .from(characters)
      .where(eq(characters.isActive, true))
      .orderBy(asc(characters.name));

    res.status(200).json({
      success: true,
      data: list,
    });
  } catch (error) {
    next(error);
  }
};

export const activateLicense = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { key, licenseKey } = req.body;
    const finalKey = key || licenseKey;
    const userId = req.user!.id;
    const userEmail = req.user!.email;

    const licenseArr = await db
      .select()
      .from(licenseKeys)
      .where(eq(licenseKeys.key, finalKey || ""))
      .limit(1);
    const license = licenseArr[0];

    if (!license) {
      throw new AppError(
        "Lisensi tidak valid atau tidak ditemukan",
        404,
        "NOT_FOUND",
      );
    }

    if (license.isUsed) {
      throw new AppError(
        "Lisensi ini sudah pernah diaktifkan",
        400,
        "ALREADY_USED",
      );
    }

    // Update User & License (Only add credits, no PRO subscription status)
    await db.transaction(async (tx) => {
      await tx
        .update(users)
        .set({
          credits: sql`credits + ${license.credits}`,
        })
        .where(eq(users.id, userId));

      await tx
        .update(licenseKeys)
        .set({
          isUsed: true,
          usedBy: userEmail,
          usedAt: new Date(),
        })
        .where(eq(licenseKeys.id, license.id));

      await tx.insert(logs).values({
        id: crypto.randomUUID(),
        userId,
        action: "claim_voucher",
        detail: { key, credits: license.credits },
      });
    });

    res.status(200).json({
      success: true,
      message: `Selamat! Voucher berhasil diklaim. Anda mendapatkan tambahan ${license.credits} kredit prompt.`,
    });
  } catch (error) {
    next(error);
  }
};

export const uploadImage = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { image, fileName } = req.body;
    if (!image) {
      throw new AppError("Image data is required", 400, "BAD_REQUEST");
    }

    const userId = req.user!.id;
    const result = await performUpload(
      image,
      fileName || `upload-${Date.now()}.png`,
      userId,
      req,
    );

    res.status(200).json({
      success: true,
      url: result.url,
      isFallback: result.isFallback,
      storageType: result.storageType,
    });
  } catch (error) {
    next(error);
  }
};

export const uploadMultiImages = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const { images } = req.body; // array of { image: base64, fileName: string }
    if (!images || !Array.isArray(images) || images.length === 0) {
      throw new AppError("Array gambar tidak boleh kosong", 400, "BAD_REQUEST");
    }
    if (images.length > 10) {
      throw new AppError(
        "Maksimal 10 gambar sekaligus",
        400,
        "TOO_MANY_IMAGES",
      );
    }

    const userId = req.user!.id;
    const results = await Promise.all(
      images.map((item: { image: string; fileName?: string }, idx: number) =>
        performUpload(
          item.image,
          item.fileName || `upload-${Date.now()}-${idx}.png`,
          userId,
          req,
        ),
      ),
    );

    res.status(200).json({
      success: true,
      urls: results.map((r) => r.url),
      storageTypes: results.map((r) => r.storageType),
    });
  } catch (error) {
    next(error);
  }
};

// Core upload logic — Cloudinary → user ImageKit → admin ImageKit → local storage
async function performUpload(
  image: string,
  fileName: string,
  userId: string,
  req: Request,
): Promise<{
  url: string;
  isFallback: boolean;
  storageType: "user_imagekit" | "admin_imagekit" | "local";
}> {
  // 1. Try Storage CDN Gateway (Cloudinary Provider) upload first
  try {
    const url = await uploadToCloudinary(image, fileName);
    return { url, isFallback: false, storageType: "user_imagekit" };
  } catch (cloudinaryErr) {
    logger.warn(`Storage CDN Gateway (Cloudinary) upload failed: ${(cloudinaryErr as Error).message}`);
  }

  // 2. Try user's own ImageKit credentials
  try {
    const userArr = await db
      .select({
        imagekitPublicKey: users.imagekitPublicKey,
        imagekitPrivateKey: users.imagekitPrivateKey,
        imagekitUrlEndpoint: users.imagekitUrlEndpoint,
      })
      .from(users)
      .where(eq(users.id, userId))
      .limit(1);
    const user = userArr[0];

    if (user?.imagekitPrivateKey && user?.imagekitUrlEndpoint) {
      let privKey = user.imagekitPrivateKey;
      // Decrypt if encrypted
      try {
        const { decrypt: dec } = await import("../../core/utils/encryption");
        privKey = dec(privKey);
      } catch (_) {
        /* use as-is if not encrypted */
      }

      const userConfig = {
        publicKey: user.imagekitPublicKey || "",
        privateKey: privKey,
        urlEndpoint: user.imagekitUrlEndpoint,
      };
      const url = await uploadToImageKit(image, fileName, userConfig);
      return { url, isFallback: false, storageType: "user_imagekit" };
    }
  } catch (userIkError) {
    logger.warn(
      `User ImageKit failed for ${userId}: ${(userIkError as Error).message}`,
    );
  }

  // 2. Try admin ImageKit credentials
  try {
    const settingsObjArr = await db
      .select()
      .from(appSettings)
      .where(eq(appSettings.key, "imagekit_settings"))
      .limit(1);
    const settingsObj = settingsObjArr[0];

    if (settingsObj) {
      const config = settingsObj.value as {
        publicKey: string;
        privateKey: string;
        urlEndpoint: string;
      };
      if (
        config.privateKey &&
        config.urlEndpoint &&
        config.privateKey !== "placeholder"
      ) {
        const url = await uploadToImageKit(image, fileName, config);
        return { url, isFallback: false, storageType: "admin_imagekit" };
      }
    }
  } catch (adminIkError) {
    logger.warn(`Admin ImageKit failed: ${(adminIkError as Error).message}`);
  }

  // 3. Fallback: local server storage (cPanel uploads/)
  try {
    const cleanBase64 = image.includes(";base64,")
      ? image.split(";base64,")[1]
      : image;
    const buffer = Buffer.from(cleanBase64, "base64");
    const localFileName = `${Date.now()}-${fileName}`;

    const uploadsDir = path.join(process.cwd(), "uploads");
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }

    const localPath = path.join(uploadsDir, localFileName);
    fs.writeFileSync(localPath, buffer);

    const protocol =
      req.secure || req.headers["x-forwarded-proto"] === "https"
        ? "https"
        : "http";
    const host = req.get("host") || "localhost:3000";
    const url = `${protocol}://${host}/uploads/${localFileName}`;

    return { url, isFallback: true, storageType: "local" };
  } catch (localError) {
    throw new AppError(
      `Semua metode penyimpanan gagal: ${(localError as Error).message}`,
      500,
      "UPLOAD_FAILED",
    );
  }
}

async function uploadToCloudinary(
  base64File: string,
  fileName: string
): Promise<string> {
  let cleanBase64 = base64File;
  if (!base64File.startsWith('data:')) {
    cleanBase64 = `data:image/png;base64,${base64File}`;
  }

  const gatewayKey = process.env.STORAGE_GATEWAY_KEY || 'AR_4c9b2435_929a80d916261b15c582db6fe3e41e52';
  const baseUrl = process.env.STORAGE_GATEWAY_BASE_URL || 'https://one.apprentice.cyou/v1';
  const postData = JSON.stringify({
    file: cleanBase64,
    file_name: fileName || 'poster.png',
    auto_rotate: true,
    provider: 'cloudinary'
  });

  const response = await fetch(`${baseUrl}/storage/upload`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${gatewayKey}`
    },
    body: postData
  });

  const data = await response.json() as any;
  if (response.ok && data.success && data.file?.url) {
    return data.file.url;
  }
  throw new Error(data.message || data.error?.message || 'Storage CDN Gateway upload failed');
}

function uploadToImageKit(
  base64File: string,
  fileName: string,
  config: { publicKey: string; privateKey: string; urlEndpoint: string },
): Promise<string> {
  return new Promise((resolve, reject) => {
    // Strip data prefix if present (e.g. data:image/jpeg;base64,)
    let cleanBase64 = base64File;
    if (base64File.includes(";base64,")) {
      cleanBase64 = base64File.split(";base64,")[1];
    }

    const postData = JSON.stringify({
      file: cleanBase64,
      fileName: fileName,
    });

    const options = {
      hostname: "upload.imagekit.io",
      port: 443,
      path: "/api/v1/files/upload",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(postData),
        Authorization:
          "Basic " + Buffer.from(config.privateKey + ":").toString("base64"),
      },
    };

    const req = https.request(options, (res) => {
      let responseBody = "";
      res.on("data", (chunk) => {
        responseBody += chunk;
      });
      res.on("end", () => {
        try {
          const parsed = JSON.parse(responseBody);
          if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
            if (parsed.url) {
              resolve(parsed.url);
            } else {
              reject(new Error(parsed.message || "ImageKit upload failed"));
            }
          } else {
            reject(new Error(parsed.message || `HTTP error ${res.statusCode}`));
          }
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on("error", (e) => {
      reject(e);
    });

    req.write(postData);
    req.end();
  });
}

export const chat = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { message, history } = req.body;

    if (!message) {
      throw new AppError("Pesan tidak boleh kosong", 400, "BAD_REQUEST");
    }

    const reply = await aiService.chat(message, history || []);

    res.status(200).json({
      success: true,
      data: { reply },
    });
  } catch (error) {
    next(error);
  }
};

export const analyzeStoryboard = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { topic, duration } = req.body;

    const storyboard = await aiService.analyzeStoryboard(topic, duration || 30);

    res.status(200).json({
      success: true,
      data: storyboard,
    });
  } catch (error) {
    next(error);
  }
};
