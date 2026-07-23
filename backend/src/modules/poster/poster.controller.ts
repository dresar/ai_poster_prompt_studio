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
import { renderDSL, compileFinalPrompt, compileFinalVideoPrompt, compileEdukasiMasterPrompt } from "./dslRenderer";
import { repairJson } from "../../utils/jsonRepair";
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
    const { topic, category } = req.body;
    if (!topic) {
      throw new AppError("Topic is required", 400, "BAD_REQUEST");
    }

    const analysis = await aiService.analyzeTopic(topic, category);
    res.status(200).json({ success: true, data: analysis });
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
    const { category, slideCount } = req.query;
    const userId = req.user!.id;
    const ideas = await aiService.generateContentIdeas(
      userId,
      String(category),
      slideCount ? Number(slideCount) : undefined,
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

// Core upload logic — Cloudinary (via Storage Gateway) → user ImageKit → admin ImageKit → local storage
async function performUpload(
  image: string,
  fileName: string,
  userId: string,
  req: Request,
): Promise<{
  url: string;
  isFallback: boolean;
  storageType: "storage_gateway" | "user_imagekit" | "admin_imagekit" | "local";
}> {
  // 1. Try Storage CDN Gateway (Cloudinary Provider) upload first
  try {
    const url = await uploadToCloudinary(image, fileName);
    return { url, isFallback: false, storageType: "storage_gateway" };
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

function uploadToCloudinary(
  base64File: string,
  fileName: string
): Promise<string> {
  return new Promise((resolve, reject) => {
    let cleanBase64 = base64File;
    if (!base64File.startsWith('data:')) {
      cleanBase64 = `data:image/png;base64,${base64File}`;
    }

    const gatewayKey = env.STORAGE_GATEWAY_KEY;
    const baseUrl = env.STORAGE_GATEWAY_BASE_URL;

    const postData = JSON.stringify({
      file: cleanBase64,
      file_name: fileName || 'poster.png',
      auto_rotate: true,
      provider: 'cloudinary'
    });

    try {
      const parsedUrl = new URL(`${baseUrl}/storage/upload`);
      const options = {
        hostname: parsedUrl.hostname,
        port: parsedUrl.port || 443,
        path: parsedUrl.pathname + parsedUrl.search,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData),
          'Authorization': `Bearer ${gatewayKey}`
        }
      };

      const req = https.request(options, (res) => {
        let responseBody = '';
        res.on('data', (chunk) => {
          responseBody += chunk;
        });
        res.on('end', () => {
          try {
            const data = JSON.parse(responseBody);
            if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
              if (data.success && data.file?.url) {
                resolve(data.file.url);
              } else {
                reject(new Error(data.message || 'Storage CDN Gateway upload failed'));
              }
            } else {
              reject(new Error(data.message || `HTTP error ${res.statusCode}`));
            }
          } catch (e) {
            reject(e);
          }
        });
      });

      req.on('error', (e) => {
        reject(e);
      });

      req.write(postData);
      req.end();
    } catch (err) {
      reject(err);
    }
  });
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

export const importExternalPrompt = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      throw new AppError("Unauthorized access", 401);
    }

    const formState = req.body;
    await checkQuota(userId);

    // 1. Robust parse & repair external JSON content
    let payloadJson: any;
    try {
      if (typeof formState.externalJson === "string") {
        payloadJson = repairJson(formState.externalJson);
      } else {
        payloadJson = formState.externalJson;
      }
    } catch (e: any) {
      throw new AppError(`Gagal membaca atau memperbaiki JSON: ${e.message}`, 400);
    }

    if (!payloadJson || typeof payloadJson !== "object") {
      throw new AppError("Format JSON tidak valid atau kosong.", 400);
    }

    // 2. Validate & normalize payload structure
    let schema: any = PayloadSchema;
    if (formState.feature === "video") schema = VideoPayloadSchema;
    else if (formState.feature === "advanced_video") schema = AdvancedVideoPayloadSchema;

    const parsedData = schema.safeParse(payloadJson);
    if (parsedData.success) {
      payloadJson = parsedData.data;
    } else {
      logger.warn(`External JSON soft validation notice: ${parsedData.error.message}. Normalizing structure...`);
      
      // Auto-fallback structure normalization if schema has missing fields
      if (!payloadJson.systemInit) payloadJson.systemInit = { mission: `Materi ${formState.feature || 'visual'}` };
      if (!payloadJson.contentPayload) payloadJson.contentPayload = { topic: formState.topic || 'Untitled' };
      if (!payloadJson.contentPayload.topic) payloadJson.contentPayload.topic = formState.topic || 'Untitled';
      
      if (!payloadJson.slidesContent && payloadJson.slides) {
        payloadJson.slidesContent = payloadJson.slides;
      }
      if (!payloadJson.segmentsContent && payloadJson.segments) {
        payloadJson.segmentsContent = payloadJson.segments;
      }
      if (!payloadJson.output) payloadJson.output = { viralScore: 90 };
    }

    // 3. Resolve visual and layout options
    const getDropdownHelperText = async (value: string | undefined): Promise<string> => {
      if (!value || value === "auto" || value === "random") return "";
      const optionArr = await db
        .select({ helperText: dropdownOptions.helperText })
        .from(dropdownOptions)
        .where(and(eq(dropdownOptions.value, value), eq(dropdownOptions.isActive, true)))
        .limit(1);
      return optionArr[0]?.helperText || value;
    };

    const resolvedColorPalette = await getDropdownHelperText(formState.colorPalette);
    const resolvedMood = await getDropdownHelperText(formState.mood || formState.theme);
    const resolvedAspectRatio = await getDropdownHelperText(formState.aspectRatio);
    const resolvedLayout = await getDropdownHelperText(formState.layout);
    const resolvedTextRule = await getDropdownHelperText(formState.textRule || formState.textRules);
    const resolvedCta = await getDropdownHelperText(formState.cta || formState.callToAction);

    const dropdownSpecs: string[] = [];
    if (resolvedColorPalette) dropdownSpecs.push(`Color Palette: ${resolvedColorPalette}.`);
    if (resolvedMood) dropdownSpecs.push(`Mood/Vibe: ${resolvedMood}.`);
    if (resolvedAspectRatio) dropdownSpecs.push(`Aspect Ratio: ${resolvedAspectRatio}.`);
    if (resolvedLayout) dropdownSpecs.push(`Layout Format: ${resolvedLayout}.`);
    if (resolvedTextRule) dropdownSpecs.push(`Typography/Text Rule: ${resolvedTextRule}.`);
    if (resolvedCta) dropdownSpecs.push(`Call-to-Action (CTA) Rule: ${resolvedCta}.`);
    const resolvedDropdownPrompt = dropdownSpecs.join(" ");

    // Resolve visual style template
    let styleTemplate = "";
    if (formState.style && formState.style !== "auto") {
      const visualStyleObjArr = await db
        .select()
        .from(visualStyles)
        .where(and(eq(visualStyles.name, formState.style), eq(visualStyles.isActive, true)))
        .limit(1);
      const visualStyleObj = visualStyleObjArr[0];
      if (visualStyleObj) {
        styleTemplate = visualStyleObj.promptTemplate;
      }
    }

    // Resolve character focus prompt consistency
    let resolvedCharacterPrompt = "";
    if (formState.characterFocus && !["auto", "random", "product_only"].includes(formState.characterFocus)) {
      const characterObjArr = await db
        .select()
        .from(characters)
        .where(and(eq(characters.id, formState.characterFocus), eq(characters.isActive, true)))
        .limit(1);
      const characterObj = characterObjArr[0];
      if (characterObj) {
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

    // Build watermark instruction
    const watermarkText = (formState.watermark || "").trim();
    let watermarkInstruction = "";
    if (watermarkText) {
      watermarkInstruction = `Tampilkan teks watermark berikut secara rapi di bagian bawah gambar: "${watermarkText}"`;
    }

    // 4. Compile final prompt
    let promptFinal = "";
    const isEdukasi = formState.feature === "edukasi" || formState.mode === "edukasi" || formState.category === "edukasi";
    const isVideo = formState.feature === "video";

    if (isEdukasi) {
      promptFinal = compileEdukasiMasterPrompt(
        payloadJson,
        { aspectRatio: formState.aspectRatio || "3:4" },
        styleTemplate,
        resolvedCharacterPrompt,
        resolvedDropdownPrompt,
        watermarkInstruction
      );
    } else if (isVideo) {
      promptFinal = compileFinalVideoPrompt(
        payloadJson,
        1, // Default active segment 1
        styleTemplate,
        resolvedCharacterPrompt,
        resolvedDropdownPrompt,
        "veo"
      );
    } else {
      promptFinal = compileFinalPrompt(
        payloadJson,
        1, // Default active slide 1
        styleTemplate,
        resolvedCharacterPrompt,
        resolvedDropdownPrompt,
        "flux"
      );
    }

    // Dynamic prompt compilation for each slide/segment on import
    if (payloadJson.slidesContent) {
      payloadJson.slidesContent = payloadJson.slidesContent.map((s: any) => {
        const slidePrompt = isEdukasi
          ? compileEdukasiMasterPrompt(
              payloadJson,
              { aspectRatio: formState.aspectRatio || "3:4" },
              styleTemplate,
              resolvedCharacterPrompt,
              resolvedDropdownPrompt,
              watermarkInstruction
            )
          : compileFinalPrompt(
              payloadJson,
              s.slideNumber,
              styleTemplate,
              resolvedCharacterPrompt,
              resolvedDropdownPrompt,
              "flux"
            );
        return {
          ...s,
          prompt: slidePrompt
        };
      });

      if (!payloadJson.output) payloadJson.output = {};
      payloadJson.output.slides = payloadJson.slidesContent.map((s: any) => ({
        slideNumber: s.slideNumber,
        prompt: s.prompt
      }));
    }

    if (payloadJson.segmentsContent) {
      payloadJson.segmentsContent = payloadJson.segmentsContent.map((s: any) => ({
        ...s,
        prompt: compileFinalVideoPrompt(
          payloadJson,
          s.segmentNumber,
          styleTemplate,
          resolvedCharacterPrompt,
          resolvedDropdownPrompt,
          "veo"
        )
      }));

      if (!payloadJson.output) payloadJson.output = {};
      payloadJson.output.segments = payloadJson.segmentsContent.map((s: any) => ({
        segmentNumber: s.segmentNumber,
        prompt: s.prompt
      }));
    }

    // 5. Calculate viral score & hooks
    const viralData = await aiService.scoreViral(promptFinal);
    const generatedHooks = payloadJson.output?.hooks || [];
    const fallbackHooks = await aiService.generateHooks(formState.topic);
    const finalHooks = generatedHooks.length > 0 ? generatedHooks : fallbackHooks;

    if (!payloadJson.output) payloadJson.output = {};
    payloadJson.output = {
      ...payloadJson.output,
      promptFinal,
      viralScore: viralData.score,
      viralBreakdown: viralData.breakdown,
      hooks: finalHooks,
    };
    payloadJson.viralBreakdown = viralData.breakdown;

    // 6. Save prompt to DB
    const promptId = crypto.randomUUID();
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
        schemaVersion: "v2",
      })
      .returning();

    // 7. Decrement credits
    const foundUsers = await db
      .select()
      .from(users)
      .where(eq(users.id, userId))
      .limit(1);
    const user = foundUsers[0];
    if (user && user.role !== "ADMIN") {
      const currentCredits = user.credits ?? 0;
      if (currentCredits > 0) {
        await db
          .update(users)
          .set({ credits: currentCredits - 1 })
          .where(eq(users.id, userId));
      }
    }

    if (req.body.draftId) {
      try {
        const [existingDraft] = await db
          .select()
          .from(prompts)
          .where(eq(prompts.id, req.body.draftId))
          .limit(1);

        if (existingDraft) {
          const currentPayload = (existingDraft.payloadJson as Record<string, any>) || {};
          await db
            .update(prompts)
            .set({
              payloadJson: {
                ...currentPayload,
                isImported: true,
                importedPromptId: savedPrompt.id,
                importedPromptData: savedPrompt,
              },
            })
            .where(eq(prompts.id, req.body.draftId));
        }
      } catch (e) {
        console.error("Error updating draft import status:", e);
      }
    }

    res.status(200).json({
      success: true,
      data: savedPrompt,
    });
  } catch (error) {
    next(error);
  }
};

export const saveExternalDraft = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    const userId = req.user!.id;
    const { draftId, formState, instructionsText } = req.body;

    const topic = formState.topic || 'Draf Prompt Eksternal';
    const category = formState.feature || 'poster';

    let savedPrompt: any;

    if (draftId) {
      const existing = await db
        .select()
        .from(prompts)
        .where(and(eq(prompts.id, draftId), eq(prompts.userId, userId)))
        .limit(1);

      if (existing.length > 0) {
        const [updated] = await db
          .update(prompts)
          .set({
            topic,
            category,
            promptFinal: instructionsText,
            payloadJson: {
              formState,
              instructionsText,
              isImported: false,
            },
          })
          .where(eq(prompts.id, draftId))
          .returning();
        savedPrompt = updated;
      }
    }

    if (!savedPrompt) {
      const newId = draftId || crypto.randomUUID();
      const [inserted] = await db
        .insert(prompts)
        .values({
          id: newId,
          userId,
          mode: 'external_draft',
          topic,
          category,
          promptFinal: instructionsText,
          payloadJson: {
            formState,
            instructionsText,
            isImported: false,
          },
          schemaVersion: 'v2',
        })
        .returning();
      savedPrompt = inserted;
    }

    res.status(200).json({
      success: true,
      message: 'Draf prompt eksternal berhasil disimpan',
      data: savedPrompt,
    });
  } catch (error) {
    next(error);
  }
};

export const suggestCharacter = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const prompt = `Generate 1 unique, creative, high-quality character concept in JSON format.
Return ONLY raw JSON with keys:
"nama": (unique creative name in Indonesian, e.g. "Astra si Kucing Astronot", "Mimi si Kelinci Botanis"),
"spesies": (specific species description in Indonesian),
"jenis": (Hewan, Manusia, Makhluk Fantasi, or Robot),
"kategori": (Maskot Brand, Karakter Edukasi, Tokoh Cerita, Karakter Game, or Influencer Virtual),
"gaya": (3D Pixar Disney Style, 3D Cute Isometric, 2D Flat Vector, Anime Chibi Style, or Claymation 3D),
"usia": (Anak-anak, Remaja, Dewasa, or Lansia),
"kepribadian": (3 adjectives, e.g. "Ceria, Energik, Ramah"),
"warna": (auto, Kuning & Biru, Merah & Oranye, Hijau Tropis, or Ungu Pastel & Pink),
"platform": (Poster, Logo, Banner & Video, Poster Edukasi, Logo & Brand Mascot, Banner 16:9, or YouTube 16:9 Widescreen),
"desc": (detailed description of outfit, accessories, and distinct visual features in 2-3 short Indonesian sentences).`;

    try {
      const rawRes = await (aiService as any).geminiClient.generateChatCompletion([
        { role: 'system', content: 'Kamu adalah asisten AI pembuat karakter visual kreatif.' },
        { role: 'user', content: prompt }
      ]);

      const cleanJson = (aiService as any).geminiClient.sanitizeJson(rawRes);
      const parsed = JSON.parse(cleanJson);
      return res.status(200).json({
        success: true,
        data: parsed,
      });
    } catch (aiErr) {
      logger.warn('AI suggest character API fallback: ' + (aiErr as any)?.message);
    }

    const fallbackIdeas = [
      {
        nama: 'Astra si Kucing Astronot',
        spesies: 'Kucing Persia Putih Salju',
        jenis: 'Hewan',
        kategori: 'Maskot Brand',
        gaya: '3D Pixar Disney Style',
        usia: 'Anak-anak',
        kepribadian: 'Pemberani, Cerdas, Ceria',
        warna: 'Kuning & Biru',
        platform: 'Poster, Logo, Banner & Video',
        desc: 'Kucing putih imut memakai baju astronot futuristik perak bertransparansi kaca helmet, membawa bendera bintang emas.',
      },
    ];

    const pick = fallbackIdeas[Math.floor(Math.random() * fallbackIdeas.length)];
    res.status(200).json({ success: true, data: pick });
  } catch (error) {
    next(error);
  }
};

export const suggestVisualStyle = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const prompt = `Generate 1 unique creative visual design system concept in JSON format.
Return ONLY raw JSON with keys:
"nama": (unique style name, e.g. "Cyberpunk Glassmorphism 2026", "Minimalist Earthy Terracotta"),
"kategori": (Modern Minimalis, Cyberpunk Neon, Retro Vintage, Organic Nature, Luxury Gold, or Pixel Art Gaming),
"mood": (Elegan & Profesional, Energetik & Dynamic, Misterius & Atmospheric, Soft & Calming Pastel, or Bold & Impactful),
"medium": (3D Studio Render, 2D Swiss Vector Grid, Hyperrealistic Photography, Oil Painting Fine Art, or Collage Paper Cutout),
"warna": (Dark Mode & Neon Accent, Light Mode Monochrome, Vibrant Pastel, Warm Earth Tone, or Deep Ocean Cyan),
"cahaya": (Cinematic Studio Light, Natural Golden Hour, Volumetric Rim Light, or Studio Rim Neon Glow),
"tekstur": (Smooth Glassmorphism & Matte, Rough Paper & Grain, Metallic Chrome Reflection, or Soft Clay Fabric),
"desc": (detailed description of visual aesthetic and grid layout in 2 short Indonesian sentences),
"extra": (additional visual notes in 1 short sentence).`;

    try {
      const rawRes = await (aiService as any).geminiClient.generateChatCompletion([
        { role: 'system', content: 'Kamu adalah asisten AI perancang gaya visual desainer.' },
        { role: 'user', content: prompt }
      ]);

      const cleanJson = (aiService as any).geminiClient.sanitizeJson(rawRes);
      const parsed = JSON.parse(cleanJson);
      return res.status(200).json({
        success: true,
        data: parsed,
      });
    } catch (aiErr) {
      logger.warn('AI suggest visual style API fallback: ' + (aiErr as any)?.message);
    }

    const fallbackStyles = [
      {
        nama: 'Cyberpunk Glassmorphism 2026',
        kategori: 'Cyberpunk Neon',
        mood: 'Bold & Impactful',
        medium: '3D Studio Render',
        warna: 'Dark Mode & Neon Accent',
        cahaya: 'Studio Rim Neon Glow',
        tekstur: 'Smooth Glassmorphism & Matte',
        desc: 'Perpaduan grid tipografi Swiss kontemporer dengan efek kaca frosting miring dan aksen neon cyan. Memberikan kesan sangat futuristik dan mewah.',
        extra: 'Tipografi san-serif bold presisi tinggi dengan bayangan neon lembut.',
      },
    ];

    const pick = fallbackStyles[Math.floor(Math.random() * fallbackStyles.length)];
    res.status(200).json({ success: true, data: pick });
  } catch (error) {
    next(error);
  }
};


