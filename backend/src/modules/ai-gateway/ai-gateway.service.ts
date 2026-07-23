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

  async generatePrompt(formState: any, previousError?: string): Promise<any> {
    return await this.promptGenerator.generatePrompt(formState, previousError);
  }

  async generateEnhancePrompt(imageUrl: string, enhanceStyle: string, changeLevel: string, notes: string): Promise<any> {
    return await this.promptGenerator.generateEnhancePrompt(imageUrl, enhanceStyle, changeLevel, notes);
  }

  async generatePromptTemplate(category: string, idea: string): Promise<any> {
    return await this.promptGenerator.generatePromptTemplate(category, idea);
  }

  async generateContentIdeas(userId: string, category: string, slideCount?: number): Promise<string[]> {
    return await this.chatAssistant.generateContentIdeas(userId, category, slideCount);
  }

  async chat(message: string, history: any[]): Promise<string> {
    return await this.chatAssistant.chat(message, history);
  }

  async generateChatResponse(messages: Array<{ role: 'user' | 'assistant' | 'system'; content: string }>, systemInstruction?: string): Promise<string> {
    return await this.chatAssistant.generateResponse(messages, systemInstruction);
  }

  async generateHooks(topic: string): Promise<string[]> {
    return await this.topicAnalyzer.generateHooks(topic);
  }

  async scoreViral(promptFinal: string): Promise<any> {
    return await this.viralScoreService.evaluateScore(promptFinal);
  }

  async evaluateViralScore(payload: any): Promise<any> {
    return await this.viralScoreService.evaluateScore(payload);
  }

  async improvePrompt(promptDraft: string): Promise<string> {
    return await this.chatAssistant.generateResponse([
      { role: 'system', content: 'Kamu adalah AI Prompt Improver. Perbaiki dan tingkatkan prompt berikut agar lebih detail, spesifik, dan estetik.' },
      { role: 'user', content: promptDraft }
    ]);
  }

  async analyzeStoryboard(topic: string, duration: number): Promise<any> {
    return await this.promptGenerator.generatePrompt({ topic, duration, feature: 'video' });
  }
}
