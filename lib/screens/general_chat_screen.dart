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
      color: Colors.transparent,
      child: Column(
        children: [
          // Clean header without unnecessary buttons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: const Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Main Content Area
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildPerplexityEmptyState(context)
                : _buildChatList(context, chatState, chatNotifier),
          ),
          // Loading indicator
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
          // Error display
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
          // Perplexity-style input (left-aligned)
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
                // Search icon (left side like Perplexity)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Input field (expanded to take most space)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
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
                        // Microphone icon (inside input like Perplexity)
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.mic,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Send button (right side, circular like Perplexity)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: IconButton(
                    onPressed: () {
                      final message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        chatNotifier.sendMessage(message: message);
                        _messageController.clear();
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_forward,
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

  Widget _buildPerplexityEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Perplexity-style geometric logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(40),
            ),
            child: CustomPaint(
              painter: PerplexityLogoPainter(),
            ),
          ),
          const SizedBox(height: 32),
          // Perplexity's exact tagline style
          const Text(
            'Where\nknowledge\nbegins',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w300,
              height: 1.2,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
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

// Custom painter for Perplexity-style geometric logo
class PerplexityLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw geometric pattern similar to Perplexity
    // Outer circle
    canvas.drawCircle(center, radius, paint);
    
    // Inner geometric lines
    final innerRadius = radius * 0.6;
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final startX = center.dx + innerRadius * 0.3 * (i % 2 == 0 ? 1 : -1);
      final startY = center.dy + innerRadius * 0.3 * (i % 2 == 0 ? -1 : 1);
      final endX = center.dx + innerRadius * (i % 2 == 0 ? 1 : -1);
      final endY = center.dy + innerRadius * (i % 2 == 0 ? -1 : 1);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}