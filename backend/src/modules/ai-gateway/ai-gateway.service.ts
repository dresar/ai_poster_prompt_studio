import { GeminiClient } from './core/gemini-client';

import { ImageAnalyzerService } from './features/image-analyzer.service';
import { TopicAnalyzerService } from './features/topic-analyzer.service';
import { PromptGeneratorService } from './features/prompt-generator.service';
import { ChatAssistantService } from './features/chat-assistant.service';
import { ViralScoreService } from './features/viral-score.service';

export class AIGatewayService {
  public geminiClient = new GeminiClient();
  
  private imageAnalyzer = new ImageAnalyzerService(this.geminiClient);
  private topicAnalyzer = new TopicAnalyzerService(this.geminiClient);
  private promptGenerator = new PromptGeneratorService(this.geminiClient, this.imageAnalyzer);
  private chatAssistant = new ChatAssistantService(this.geminiClient);
  private viralScoreService = new ViralScoreService(this.geminiClient);

  async analyzeReferenceImage(imageUrl: string): Promise<string> {
    return await this.imageAnalyzer.analyzeReferenceImage(imageUrl);
  }

  async analyzeTopic(topic: string, category?: string): Promise<{
    description: string;
    keyPoints: string[];
    visualRecommendation: string;
    hook?: string;
    cta?: string;
  }> {
    return await this.topicAnalyzer.analyzeTopic(topic, category);
  }

  async generatePosterPrompts(formState: any): Promise<any> {
    return await this.promptGenerator.generatePrompt(formState);
  }

  async generateChatResponse(messages: Array<{ role: 'user' | 'assistant' | 'system'; content: string }>, systemInstruction?: string): Promise<string> {
    return await this.chatAssistant.generateResponse(messages, systemInstruction);
  }

  async evaluateViralScore(payload: any): Promise<any> {
    return await this.viralScoreService.evaluateScore(payload);
  }
}
