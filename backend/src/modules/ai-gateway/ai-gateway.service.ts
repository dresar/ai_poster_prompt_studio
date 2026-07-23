import { GeminiClient } from './core/gemini-client';
import { GroqClient } from './core/groq-client';

import { ImageAnalyzerService } from './features/image-analyzer.service';
import { TopicAnalyzerService } from './features/topic-analyzer.service';
import { PromptGeneratorService } from './features/prompt-generator.service';
import { ChatAssistantService } from './features/chat-assistant.service';
import { ViralScoreService } from './features/viral-score.service';

export class AIGatewayService {
  public geminiClient = new GeminiClient();
  private groqClient = new GroqClient();
  
  private imageAnalyzer = new ImageAnalyzerService(this.geminiClient, this.groqClient);
  private topicAnalyzer = new TopicAnalyzerService(this.geminiClient, this.groqClient);
  private promptGenerator = new PromptGeneratorService(this.geminiClient, this.groqClient, this.imageAnalyzer);
  private chatAssistant = new ChatAssistantService(this.geminiClient, this.groqClient);
  private viralScoreService = new ViralScoreService(this.geminiClient, this.groqClient);

  private async getProvider(): Promise<'gemini'> {
    return 'gemini'; // PURE GEMINI ALWAYS
  }

  async analyzeReferenceImage(imageUrl: string): Promise<string> {
    return await this.imageAnalyzer.analyzeReferenceImage(imageUrl, 'gemini');
  }

  async analyzeTopic(topic: string, category?: string): Promise<{
    description: string;
    keyPoints: string[];
    visualRecommendation: string;
    hook?: string;
    cta?: string;
  }> {
    return await this.topicAnalyzer.analyzeTopic(topic, category, 'gemini');
  }

  async generatePosterPrompts(formState: any): Promise<{
    payloadJson: any;
    dslCode: string;
    finalPrompt: string;
    viralScore: number;
    analysisShortcomings: string;
    hooks: string[];
    logoExplanation: string;
    socialMediaCaption: string;
    promptScore: number;
    detailScore: number;
    creativityScore: number;
    compositionScore: number;
    promptImprovement: string;
    aiSuggestions: string[];
  }> {
    return await this.promptGenerator.generatePosterPrompts(formState, 'gemini');
  }

  async generateChatResponse(messages: Array<{ role: 'user' | 'assistant' | 'system'; content: string }>, systemInstruction?: string): Promise<string> {
    return await this.chatAssistant.generateChatResponse(messages, 'gemini', systemInstruction);
  }

  async evaluateViralScore(payload: any): Promise<{
    viralScore: number;
    breakdown: { hook: number; visual: number; education: number; engagement: number };
    recommendations: string[];
  }> {
    return await this.viralScoreService.evaluateViralScore(payload, 'gemini');
  }
}
