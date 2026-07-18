import { z } from 'zod';

export const PayloadSchema = z.object({
  meta: z.object({
    mode: z.string(),
    slideCount: z.number().int().min(1)
  }).optional(),
  systemInit: z.object({
    mission: z.string()
  }),
  ruleEngine: z.record(z.string()).optional(),
  contentPayload: z.object({
    topic: z.string(),
    targetAudience: z.string(),
    emotionalTrigger: z.string()
  }),
  designSystem: z.object({
    gridStructure: z.string(),
    whitespaceRatio: z.string(),
    colorPalette: z.string(),
    typographyHierarchy: z.string()
  }),
  visualBlueprint: z.object({
    coreVisualStyle: z.string(),
    compositionRules: z.string(),
    illustrationIconography: z.string()
  }),
  renderingBlueprint: z.object({
    renderStyle: z.string(),
    qualityParameters: z.string(),
    negativePrompt: z.string()
  }),
  brandingEngine: z.object({
    logoPlacement: z.string(),
    watermarkFooter: z.string()
  }),
  slidesContent: z.array(z.object({
    slideNumber: z.number().int(),
    headline: z.string(),
    description: z.string(),
    subject: z.string().optional(),
    sceneDescription: z.string().optional(),
    visualEmphasis: z.string().optional(),
    communicationGoal: z.string().optional(),
    educationalObjective: z.string().optional(),
    keyPoints: z.array(z.string()).optional(),
    supportingFacts: z.array(z.string()).optional(),
    calloutSuggestions: z.array(z.string()).optional(),
    storytellingSequence: z.string().optional()
  })),
  output: z.object({
    viralScore: z.number(),
    analysisShortcomings: z.string(),
    hooks: z.array(z.string()),
    logoExplanation: z.string(),
    socialMediaCaption: z.string(),
    slides: z.array(z.object({
      slideNumber: z.number().int(),
      prompt: z.string().optional()
    })).optional(),
    promptScore: z.number().optional(),
    detailScore: z.number().optional(),
    creativityScore: z.number().optional(),
    compositionScore: z.number().optional(),
    promptImprovement: z.string().optional(),
    aiSuggestions: z.array(z.string()).optional()
  })
});

export type Payload = z.infer<typeof PayloadSchema>;

export const VideoPayloadSchema = z.object({
  meta: z.object({
    mode: z.string(),
    duration: z.number().int().min(1)
  }).optional(),
  systemInit: z.object({
    mission: z.string()
  }),
  ruleEngine: z.record(z.string()).optional(),
  contentPayload: z.object({
    topic: z.string(),
    targetAudience: z.string(),
    emotionalTrigger: z.string()
  }),
  videoStyle: z.object({
    coreVisualStyle: z.string(),
    colorPalette: z.string(),
    cameraMovementStyle: z.string()
  }),
  renderingBlueprint: z.object({
    renderStyle: z.string(),
    qualityParameters: z.string(),
    negativePrompt: z.string()
  }),
  brandingEngine: z.object({
    watermarkFooter: z.string()
  }),
  segmentsContent: z.array(z.object({
    segmentNumber: z.number().int(),
    timestamp: z.string(),
    headline: z.string().optional(),
    description: z.string().optional(),
    visualPrompt: z.string(),
    motionPrompt: z.string(),
    transitionPrompt: z.string(),
    textOverlay: z.string().optional(),
    audioSuggestion: z.string().optional()
  })),
  output: z.object({
    viralScore: z.number(),
    analysisShortcomings: z.string(),
    hooks: z.array(z.string()),
    socialMediaCaption: z.string(),
    segments: z.array(z.object({
      segmentNumber: z.number().int(),
      prompt: z.string().optional()
    })).optional()
  })
});

export type VideoPayload = z.infer<typeof VideoPayloadSchema>;

export const AdvancedVideoPayloadSchema = z.object({
  meta: z.object({
    mode: z.string(),
    duration: z.number().int().min(1)
  }).optional(),
  projectSummary: z.object({
    title: z.string(),
    totalDuration: z.number(),
    description: z.string()
  }),
  storyBible: z.object({
    storyType: z.string(),
    narrative: z.string(),
    conflict: z.string(),
    resolution: z.string(),
    ending: z.string(),
    emotionalArc: z.string()
  }),
  characterBible: z.array(z.object({
    name: z.string(),
    age: z.string().optional(),
    height: z.string().optional(),
    face: z.string().optional(),
    skin: z.string().optional(),
    eyes: z.string().optional(),
    hair: z.string().optional(),
    clothes: z.string().optional(),
    accessories: z.string().optional(),
    expressionDefault: z.string().optional(),
    walkStyle: z.string().optional(),
    gesture: z.string().optional(),
    habits: z.string().optional(),
    personality: z.string().optional(),
    voiceTone: z.string().optional()
  })),
  environmentBible: z.array(z.object({
    location: z.string(),
    season: z.string().optional(),
    weather: z.string().optional(),
    time: z.string().optional(),
    colors: z.string().optional(),
    materials: z.string().optional(),
    atmosphere: z.string().optional(),
    objectDensity: z.string().optional(),
    fog: z.string().optional(),
    rain: z.string().optional(),
    wind: z.string().optional(),
    lighting: z.string().optional()
  })),
  cameraBible: z.object({
    shotSize: z.string(),
    movement: z.string(),
    focalLength: z.string().optional(),
    lens: z.string().optional(),
    depthOfField: z.string().optional(),
    cameraSpeed: z.string().optional(),
    stabilization: z.string().optional(),
    cameraDirection: z.string().optional()
  }),
  motionBible: z.object({
    characterMovement: z.string(),
    objectMovement: z.string(),
    gazeDirection: z.string().optional(),
    speedRhythm: z.string().optional()
  }),
  sceneBreakdown: z.array(z.object({
    sceneNumber: z.number().int(),
    title: z.string(),
    goal: z.string(),
    duration: z.number(),
    mainSubject: z.string(),
    action: z.string(),
    emotion: z.string(),
    camera: z.string(),
    lighting: z.string(),
    environment: z.string(),
    transition: z.string(),
    dialogue: z.string().optional(),
    soundEffect: z.string().optional(),
    musicMood: z.string().optional(),
    timelineBreakdown: z.array(z.object({
      timeRange: z.string(),
      action: z.string()
    })).optional(),
    continuity: z.object({
      startingState: z.string(),
      endingState: z.string(),
      rules: z.string()
    }).optional()
  })),
  continuityRules: z.string(),
  negativePrompt: z.string(),
  finalMasterPrompt: z.string(),
  optimizedPrompts: z.object({
    geminiVeo: z.string(),
    kling: z.string(),
    runway: z.string(),
    pika: z.string(),
    hailuo: z.string()
  }),
  analyzerReport: z.object({
    characterConsistency: z.string(),
    storyLogic: z.string(),
    cameraFlow: z.string(),
    lightingConsistency: z.string(),
    continuityEvaluation: z.string(),
    instructionConflicts: z.string(),
    qualityGrade: z.string(),
    recommendations: z.array(z.string())
  }).optional()
});

export type AdvancedVideoPayload = z.infer<typeof AdvancedVideoPayloadSchema>;

