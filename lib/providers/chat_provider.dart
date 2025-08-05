import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? currentSessionId;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.currentSessionId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? currentSessionId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSessionId: currentSessionId ?? this.currentSessionId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  ChatNotifier() : super(ChatState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    final history = await _storageService.loadHistory();
    state = state.copyWith(messages: history);
  }

  Future<void> sendMessage({
    required String message,
    String? context,
    String? pdfName,
    String? extractedText,
  }) async {
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
      pdfName: pdfName,
      extractedText: extractedText,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Create session if it doesn't exist
      String? sessionId = state.currentSessionId;
      if (sessionId == null) {
        sessionId = await SupabaseService.createChatSession();
        state = state.copyWith(currentSessionId: sessionId);
      }

      // Send message to Supabase
      final response = await SupabaseService.sendMessage(
        message: message,
        sessionId: sessionId,
      );

      // Get updated messages from Supabase
      final messages = await SupabaseService.getMessages(sessionId);
      
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );

      await _storageService.saveHistory(messages);

      // If animation is being generated, start polling for updates
      final lastMessage = messages.last;
      if (lastMessage.status == 'generating' || lastMessage.status == 'pending') {
        _startPollingForVideo(sessionId, lastMessage.id);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _startPollingForVideo(String sessionId, String messageId) {
    print('🔄 [POLLING] ==========================================');
    print('🔄 [POLLING] STARTING VIDEO POLLING');
    print('🔄 [POLLING] ==========================================');
    print('🔄 [POLLING] Session ID: $sessionId');
    print('🔄 [POLLING] Message ID: $messageId');
    int pollCount = 0;
    const maxPolls = 40; // 2 minutes max polling
    
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        pollCount++;
        print('🔄 [POLLING] Poll attempt $pollCount/$maxPolls for message $messageId');
        
        final messages = await SupabaseService.getMessages(sessionId);
        final targetMessage = messages.firstWhere(
          (msg) => msg.id == messageId,
          orElse: () => throw Exception('Message not found'),
        );
        
        print('🔄 [POLLING] Update for message ${targetMessage.id}:');
        print('🔄 [POLLING]   - Status: ${targetMessage.status}');
        print('🔄 [POLLING]   - Video URL: ${targetMessage.videoUrl}');
        print('🔄 [POLLING]   - Video URL length: ${targetMessage.videoUrl?.length ?? 0}');
        print('🔄 [POLLING]   - Video URL valid: ${targetMessage.videoUrl?.startsWith('http') ?? false}');
        print('🔄 [POLLING]   - Animation prompt present: ${targetMessage.animationPrompt != null}');
        
        if (targetMessage.status == 'completed' && targetMessage.videoUrl != null) {
          // Video is ready, update the state
          print('🎉 [POLLING] ==========================================');
          print('🎉 [POLLING] 🚀 VIDEO IS READY! 🚀');
          print('🎉 [POLLING] ==========================================');
          print('🎉 [POLLING] Message ID: ${targetMessage.id}');
          print('🎉 [POLLING] Full Video URL: ${targetMessage.videoUrl}');
          print('🎉 [POLLING] URL Length: ${targetMessage.videoUrl!.length}');
           try {
             final uri = Uri.parse(targetMessage.videoUrl!);
             print('🎉 [POLLING] URL Protocol: ${uri.scheme}');
             print('🎉 [POLLING] URL Host: ${uri.host}');
             print('🎉 [POLLING] URL Path: ${uri.path}');
           } catch (e) {
             print('🎉 [POLLING] URL parsing error: $e');
           }
          print('🎉 [POLLING] URL Valid: ${targetMessage.videoUrl!.startsWith('http')}');
          print('🎉 [POLLING] Status: ${targetMessage.status}');
          print('🎉 [POLLING] Updating UI state...');
           print('🎉 [POLLING] ==========================================');
           print('🎉 [POLLING] 📺 TERMINAL VIDEO URL DISPLAY:');
           print('🎉 [POLLING] ${targetMessage.videoUrl}');
           print('🎉 [POLLING] ==========================================');
          state = state.copyWith(messages: messages);
          await _storageService.saveHistory(messages);
          print('🎉 [POLLING] UI state updated! Video should now be visible.');
          timer.cancel(); // Stop polling
        } else if (targetMessage.status == 'failed') {
          // Animation failed, stop polling
          print('❌ [POLLING] Animation failed for message: $messageId');
          state = state.copyWith(messages: messages);
          await _storageService.saveHistory(messages);
          timer.cancel();
        } else if (pollCount >= maxPolls) {
          // Timeout after max polls
          print('⏰ [POLLING] Timeout after $maxPolls attempts for message: $messageId');
          timer.cancel();
        } else {
          // Update state even while generating to show progress
          state = state.copyWith(messages: messages);
          print('⏳ [POLLING] Still ${targetMessage.status}... continuing to poll ($pollCount/$maxPolls attempts)');
        }
      } catch (e) {
        print('❌ [POLLING] Error (attempt $pollCount): $e');
        if (pollCount >= maxPolls) {
          timer.cancel();
        }
      }
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> clearHistory() async {
    await _storageService.clearHistory();
    state = state.copyWith(messages: []);
  }

  // Manual refresh method
  Future<void> refreshMessages() async {
    if (state.currentSessionId != null) {
      try {
        final messages = await SupabaseService.getMessages(state.currentSessionId!);
        state = state.copyWith(messages: messages);
        await _storageService.saveHistory(messages);
      } catch (e) {
        state = state.copyWith(error: e.toString());
      }
    }
  }
}