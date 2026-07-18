CREATE TABLE "AppSetting" (
	"id" text PRIMARY KEY NOT NULL,
	"key" text NOT NULL,
	"value" jsonb NOT NULL,
	CONSTRAINT "AppSetting_key_unique" UNIQUE("key")
);
--> statement-breakpoint
CREATE TABLE "Character" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"description" text NOT NULL,
	"imageUrl" text,
	"promptConsistency" text NOT NULL,
	"characterBible" jsonb,
	"positivePrompt" text,
	"negativePrompt" text,
	"masterPrompt" text,
	"category" text DEFAULT 'general' NOT NULL,
	"isActive" boolean DEFAULT true NOT NULL,
	"createdAt" timestamp (3) DEFAULT now() NOT NULL,
	"updatedAt" timestamp (3) DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "ContentIdeaCategory" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"isActive" boolean DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE TABLE "ContentIdea" (
	"id" text PRIMARY KEY NOT NULL,
	"userId" text NOT NULL,
	"category" text NOT NULL,
	"idea" text NOT NULL,
	"createdAt" timestamp (3) DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "DeveloperApiKey" (
	"id" text PRIMARY KEY NOT NULL,
	"userId" text NOT NULL,
	"name" text DEFAULT 'Default Key' NOT NULL,
	"apiKey" text NOT NULL,
	"isActive" boolean DEFAULT true NOT NULL,
	"createdAt" timestamp (3) DEFAULT now() NOT NULL,
	CONSTRAINT "DeveloperApiKey_apiKey_unique" UNIQUE("apiKey")
);
--> statement-breakpoint
CREATE TABLE "DropdownOption" (
	"id" text PRIMARY KEY NOT NULL,
	"groupKey" text NOT NULL,
	"label" text NOT NULL,
	"value" text NOT NULL,
	"helperText" text,
	"icon" text,
	"isActive" boolean DEFAULT true NOT NULL,
	"sortOrder" integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
CREATE TABLE "FormDescription" (
	"id" text PRIMARY KEY NOT NULL,
	"featureKey" text NOT NULL,
	"title" text NOT NULL,
	"description" text NOT NULL,
	"updatedAt" timestamp (3) DEFAULT now() NOT NULL,
	CONSTRAINT "FormDescription_featureKey_unique" UNIQUE("featureKey")
);
--> statement-breakpoint
CREATE TABLE "GeminiApiKey" (
	"id" text PRIMARY KEY NOT NULL,
	"keyEncrypted" text NOT NULL,
	"isEncrypted" boolean DEFAULT false NOT NULL,
	"isActive" boolean DEFAULT true NOT NULL,
	"priority" integer DEFAULT 0 NOT NULL,
	"usageCount" integer DEFAULT 0 NOT NULL,
	"lastUsedAt" timestamp (3),
	"healthStatus" text DEFAULT 'healthy' NOT NULL,
	"provider" text DEFAULT 'gemini' NOT NULL
);
--> statement-breakpoint
CREATE TABLE "HookPattern" (
	"id" text PRIMARY KEY NOT NULL,
	"pattern" text NOT NULL,
	"category" text NOT NULL,
	"isActive" boolean DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE TABLE "LicenseKey" (
	"id" text PRIMARY KEY NOT NULL,
	"key" text NOT NULL,
	"days" integer DEFAULT 30 NOT NULL,
	"credits" integer DEFAULT 300 NOT NULL,
	"isUsed" boolean DEFAULT false NOT NULL,
	"usedBy" text,
	"usedAt" timestamp (3),
	"createdAt" timestamp (3) DEFAULT now() NOT NULL,
	CONSTRAINT "LicenseKey_key_unique" UNIQUE("key")
);
--> statement-breakpoint
CREATE TABLE "Log" (
	"id" text PRIMARY KEY NOT NULL,
	"userId" text,
	"action" text NOT NULL,
	"detail" jsonb NOT NULL,
	"createdAt" timestamp (3) DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "PromptTemplate" (
	"id" text PRIMARY KEY NOT NULL,
	"category" text NOT NULL,
	"template" text NOT NULL,
	"isActive" boolean DEFAULT true NOT NULL,
	"previewImageUrl" text,
	"viralScore" integer,
	"viralBreakdown" jsonb,
	"payloadJson" jsonb,
	"hooks" text[],
	"analysis" text
);
--> statement-breakpoint
CREATE TABLE "Prompt" (
	"id" text PRIMARY KEY NOT NULL,
	"userId" text NOT NULL,
	"mode" text NOT NULL,
	"topic" text NOT NULL,
	"payloadJson" jsonb NOT NULL,
	"promptFinal" text NOT NULL,
	"referenceImageUrl" text,
	"referenceImageUrls" jsonb DEFAULT '[]'::jsonb,
	"category" text,
	"hooks" text[],
	"viralScore" integer,
	"isFavorite" boolean DEFAULT false NOT NULL,
	"isShared" boolean DEFAULT false NOT NULL,
	"schemaVersion" text DEFAULT 'v1' NOT NULL,
	"createdAt" timestamp (3) DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "User" (
	"id" text PRIMARY KEY NOT NULL,
	"email" text NOT NULL,
	"passwordHash" text NOT NULL,
	"role" text DEFAULT 'USER' NOT NULL,
	"subscriptionStatus" text DEFAULT 'FREE' NOT NULL,
	"subscriptionExpiresAt" timestamp (3),
	"credits" integer DEFAULT 10 NOT NULL,
	"imagekitPublicKey" text,
	"imagekitPrivateKey" text,
	"imagekitUrlEndpoint" text,
	"createdAt" timestamp (3) DEFAULT now() NOT NULL,
	CONSTRAINT "User_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "VisualStyle" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"promptTemplate" text NOT NULL,
	"previewImageUrl" text,
	"isActive" boolean DEFAULT true NOT NULL,
	"createdAt" timestamp (3) DEFAULT now() NOT NULL
);
