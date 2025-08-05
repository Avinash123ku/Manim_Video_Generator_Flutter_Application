import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_message_widget.dart';

class GeneralChatScreen extends ConsumerWidget {
  const GeneralChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GeneralChatScreenStateful();
  }
}

class _GeneralChatScreenStateful extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GeneralChatScreenStateful> createState() =>
      _GeneralChatScreenStatefulState();
}

class _GeneralChatScreenStatefulState
    extends ConsumerState<_GeneralChatScreenStateful> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);

    return Container(
      color: Colors.transparent, // Transparent to show background pattern
      child: Column(
        children: [
          // Section Header (like Perplexity)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => chatNotifier.refreshMessages(),
                  tooltip: 'Refresh Messages',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.clear_all,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => chatNotifier.clearHistory(),
                  tooltip: 'Clear Chat',
                ),
                // Debug button for testing video display
                IconButton(
                  icon: const Icon(
                    Icons.video_library,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    print('🧪 [DEBUG] Test video generation button pressed');
                    // Send a test message that should generate a video
                    const testMessage =
                        'Generate a video showing the graph of y = sin(x) with animation';
                    print('🧪 [DEBUG] Test message sent: "$testMessage"');
                    chatNotifier.sendMessage(message: testMessage);
                    print(
                        '🧪 [DEBUG] Message should trigger video generation...');
                  },
                  tooltip: 'Test Video Generation',
                ),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState(context)
                : _buildChatList(context, chatState, chatNotifier),
          ),
          // Loading and Error States
          if (chatState.isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          if (chatState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Text(
                chatState.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          // Perplexity-style Chat Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Camera Icon (like Perplexity)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Input Field (like Perplexity)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Ask anything...',
                              hintStyle: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (message) {
                              if (message.trim().isNotEmpty) {
                                chatNotifier.sendMessage(message: message);
                                _messageController.clear();
                              }
                            },
                          ),
                        ),
                        // Microphone Icon (like Perplexity)
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Send Button (like Perplexity)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      final message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        print('💬 [CHAT] Sending message: "$message"');
                        chatNotifier.sendMessage(message: message);
                        _messageController.clear();
                        print('💬 [CHAT] Message sent and input cleared');
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Perplexity-style Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          // Tagline (like Perplexity)
          const Text(
            'Ask me anything!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation by typing below.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(
    BuildContext context,
    dynamic chatState,
    dynamic chatNotifier,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        return ChatMessageWidget(message: message);
      },
    );
  }
}
