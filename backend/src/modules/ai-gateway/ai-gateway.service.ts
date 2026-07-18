import { db } from '../../config/db';
import { appSettings } from '../../db/schema';
import { eq } from 'drizzle-orm';

import { GeminiClient } from './core/gemini-client';
import { GroqClient } from './core/groq-client';

import { ImageAnalyzerService } from './features/image-analyzer.service';
import { TopicAnalyzerService } from './features/topic-analyzer.service';
import { PromptGeneratorService } from './features/prompt-generator.service';
import { ChatAssistantService } from './features/chat-assistant.service';
import { ViralScoreService } from './features/viral-score.service';

export class AIGatewayService {
  private geminiClient = new GeminiClient();
  private groqClient = new GroqClient();
  
  private imageAnalyzer = new ImageAnalyzerService(this.geminiClient, this.groqClient);
  private topicAnalyzer = new TopicAnalyzerService(this.geminiClient, this.groqClient);
  private promptGenerator = new PromptGeneratorService(this.geminiClient, this.groqClient, this.imageAnalyzer);
  private chatAssistant = new ChatAssistantService(this.geminiClient, this.groqClient);
  private viralScoreService = new ViralScoreService(this.geminiClient, this.groqClient);

  private async getProvider(): Promise<'gemini' | 'groq'> {
    try {
      const settingsArr = await db.select().from(appSettings).where(eq(appSettings.key, 'system_settings')).limit(1);
      const settings = settingsArr[0];
      const val = settings?.value as any;
      // Default to gemini if not explicitly set to groq
      return val?.defaultAIProvider === 'groq' ? 'groq' : 'gemini';
    } catch {
      return 'gemini';
    }
  }

  async analyzeReferenceImage(imageUrl: string): Promise<string> {
    const provider = await this.getProvider();
    try {
      return await this.imageAnalyzer.analyzeReferenceImage(imageUrl, provider);
    } catch (e) {
      console.error(`${provider} failed, falling back:`, e);
      const fallback = provider === 'groq' ? 'gemini' : 'groq';
      return await this.imageAnalyzer.analyzeReferenceImage(imageUrl, fallback);
    }
  }

  async analyzeTopic(topic: string): Promise<{
    description: string;
    keyPoints: string[];
    visualRecommendation: string;
  }> {
    const provider = await this.getProvider();
    try {
      return await this.topicAnalyzer.analyzeTopic(topic, provider);
    } catch (e) {
      console.error(`${provider} failed, falling back:`, e);
      const fallback = provider === 'groq' ? 'gemini' : 'groq';
      return await this.topicAnalyzer.analyzeTopic(topic, fallback);
    }
  }

  async analyzeStoryboard(topic: string, duration: number): Promise<any> {
    const provider = await this.getProvider();
    try {
      return await this.topicAnalyzer.generateStoryboard(topic, duration, provider);
    } catch (e) {
      console.error(`${provider} failed, falling back:`, e);
      const fallback = provider === 'groq' ? 'gemini' : 'groq';
      return await this.topicAnalyzer.generateStoryboard(topic, duration, fallback);
    }
  }

  async generatePrompt(fullFormState: any, previousError?: string): Promise<{
    payloadJson: any;
    promptFinal: string;
  }> {
    const provider = await this.getProvider();
    try {
      return await this.promptGenerator.generatePrompt(fullFormState, previousError, provider);
    } catch (e) {
      console.error(`${provider} failed, falling back:`, e);
      const fallback = provider === 'groq' ? 'gemini' : 'groq';
      return await this.promptGenerator.generatePrompt(fullFormState, previousError, fallback);
    }
  }

  async generateContentIdeas(userId: string, category: string): Promise<string[]> {
    const provider = await this.getProvider();
    try {
      return await this.chatAssistant.generateContentIdeas(userId, category, provider);
    } catch (e) {
      console.error(`${provider} failed, falling back:`, e);
      const fallback = provider === 'groq' ? 'gemini' : 'groq';
      return await this.chatAssistant.generateContentIdeas(userId, category, fallback);
    }
  }

  async generateHooks(topic: string): Promise<string[]> {
    const provider = await this.getProvider();
    try {
      return await this.topicAnalyzer.generateHooks(topic, provider);
    } catch (e) {
      console.error(`${provider} failed, falling back:`, e);
      const fallback = provider === 'groq' ? 'gemini' : 'groq';
      return await this.topicAnalyzer.generateHooks(topic, fallback);
    }
  }

  async improvePrompt(promptDraft: string): Promise<string> {
    const provider = await this.getProvider();
    try {
      return await this.promptGenerator.improvePrompt(promptDraft, provider);
    } catch (e) {
      console.error(`${provider} failed, falling back:`, e);
      const fallback = provider === 'groq' ? 'gemini' : 'groq';
      return await this.promptGenerator.improvePrompt(promptDraft, fallback);
    }
  }

  async generateEnhancePrompt(imageUrl: string, enhanceStyle: string, changeLevel: string, notes: string): Promise<{
    payloadJson: any;
    promptFinal: string;
  }> {
    const provider = await this.getProvider();
    try {
      return await this.promptGenerator.generateEnhancePrompt(imageUrl, enhanceStyle, changeLevel, notes, provider);
    } catch (e) {
      console.error(`${provider} failed, falling back:`, e);
      const fallback = provider === 'groq' ? 'gemini' : 'groq';
      return await this.promptGenerator.generateEnhancePrompt(imageUrl, enhanceStyle, changeLevel, notes, fallback);
    }
  }

  async scoreViral(promptFinal: string): Promise<{
    score: number;
    breakdown: {
      hook: number;
      visual: number;
      education: number;
      engagement: number;
    };
  }> {
    const provider = await this.getProvider();
    try {
      return await this.viralScoreService.scoreViral(promptFinal, provider);
    } catch (e) {
      console.error(`${provider} failed, falling back:`, e);
      const fallback = provider === 'groq' ? 'gemini' : 'groq';
      return await this.viralScoreService.scoreViral(promptFinal, fallback);
    }
  }

  async chat(message: string, history: any[]): Promise<string> {
    const provider = await this.getProvider();
    try {
      return await this.chatAssistant.chat(message, history, provider);
    } catch (e) {
      console.error(`${provider} failed, falling back:`, e);
      const fallback = provider === 'groq' ? 'gemini' : 'groq';
      return await this.chatAssistant.chat(message, history, fallback);
    }
  }

  async generatePromptTemplate(category: string, idea: string): Promise<{
    template: string;
    analysis: string;
    hooks: string[];
    payloadJson: any;
    viralScore: number;
    viralBreakdown: {
      hook: number;
      visual: number;
      education: number;
      engagement: number;
    };
  }> {
    const provider = await this.getProvider();
    try {
      return await this.promptGenerator.generatePromptTemplate(category, idea, provider);
    } catch (e) {
      console.error(`${provider} failed, falling back:`, e);
      const fallback = provider === 'groq' ? 'gemini' : 'groq';
      return await this.promptGenerator.generatePromptTemplate(category, idea, fallback);
    }
  }
}
