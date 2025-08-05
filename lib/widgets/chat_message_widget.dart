import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import 'animation_player_widget.dart';
import 'rich_text_widget.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;

  const ChatMessageWidget({
    super.key,
    required this.message,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget>
    with TickerProviderStateMixin {
  bool _isCodeExpanded = false;
  bool _isVideoExpanded = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _updateAnimation();
  }

  @override
  void didUpdateWidget(ChatMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.status != widget.message.status) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.message.status == 'pending') {
      _pulseController.repeat(reverse: true);
      _rotateController.stop();
      _shimmerController.stop();
    } else if (widget.message.status == 'generating') {
      _pulseController.stop();
      _rotateController.repeat();
      _shimmerController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _rotateController.stop();
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(
                Icons.smart_toy,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: widget.message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Response text with rich formatting
                      if (widget.message.isUser)
                        Text(
                          widget.message.content,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        )
                      else
                        RichTextWidget(
                          text: widget.message.content,
                          baseStyle: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),

                      // Animation Status and Video Display Section
                      if (!widget.message.isUser) ...[
                        const SizedBox(height: 16),
                        _buildAnimationSection(),
                      ],

                      // Manim Code (collapsible for AI responses with animation prompts)
                      if (!widget.message.isUser &&
                          widget.message.animationPrompt != null) ...[
                        const SizedBox(height: 12),
                        _buildCodeSection(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: widget.message.isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(widget.message.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                    if (widget.message.source != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Text(
                          widget.message.source!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: widget.message.source == 'PDF Document'
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (widget.message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimationSection() {
    print(
        '🔍 [ANIMATION_SECTION] Debug info for message ${widget.message.id}:');
    print('🔍   - Status: ${widget.message.status}');
    print('🔍   - Video URL: ${widget.message.videoUrl}');
    print('🔍   - Video URL Length: ${widget.message.videoUrl?.length ?? 0}');
    print(
        '🔍   - Video URL Valid: ${widget.message.videoUrl?.startsWith('http') ?? false}');
    print(
        '🔍   - Animation Prompt: ${widget.message.animationPrompt != null ? "Present" : "Null"}');
    print('🔍   - Is User: ${widget.message.isUser}');
    print('🔍   - Message Content Length: ${widget.message.content.length}');

    // Show video if it has a video URL (regardless of status)
    if (widget.message.videoUrl != null &&
        widget.message.videoUrl!.isNotEmpty &&
        widget.message.videoUrl!.startsWith('http')) {
      print('🎬 [VIDEO_FOUND] ✅ VIDEO URL DETECTED!');
      print('🎬   - Message ID: ${widget.message.id}');
      print('🎬   - Full Video URL: ${widget.message.videoUrl}');
      print('🎬   - URL Length: ${widget.message.videoUrl!.length}');
      print(
          '🎬   - URL Protocol: ${widget.message.videoUrl!.split('://').first}');
      print('🎬   - Status: ${widget.message.status}');
      print('🎬   - Creating video player widget...');

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video header with toggle button
            InkWell(
              onTap: () {
                setState(() {
                  _isVideoExpanded = !_isVideoExpanded;
                });
              },
              child: Row(
                children: [
                  Icon(
                    Icons.video_library,
                    size: 16,
                    color: Colors.green.shade400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mathematical Animation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade400,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Status: ${widget.message.status ?? "unknown"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade300,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isVideoExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: Colors.green.shade400,
                  ),
                ],
              ),
            ),
            // Collapsible video content
            if (_isVideoExpanded) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                width: double.infinity,
                child: AnimationPlayerWidget(
                  videoUrl: widget.message.videoUrl!,
                  title: 'Mathematical Animation',
                  textContent: widget.message.content,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Show animation prompt even without video for debugging
    if (widget.message.animationPrompt != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue.shade400,
                ),
                const SizedBox(width: 8),
                Text(
                  'Animation Debug Info',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${widget.message.status ?? "null"}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              'Video URL: ${widget.message.videoUrl ?? "null"}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              'Has Animation Prompt: ${widget.message.animationPrompt != null}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Show pending status
    if (widget.message.status == 'pending') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.hourglass_empty,
                      size: 20,
                      color: Colors.orange.shade600,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video Generation Queued',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your animation is in the queue and will start generating soon...',
                    style: TextStyle(
                      color: Colors.orange.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Show generating status with enhanced loading animation
    if (widget.message.status == 'generating') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation.value * 2 * 3.14159,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creating Mathematical Animation',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generating your Manim visualization...',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Enhanced progress bar with shimmer effect
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // Animated progress
                      FractionallySizedBox(
                        widthFactor: 0.7,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                              ],
                              stops: [
                                (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                                _shimmerAnimation.value,
                                (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      // Shimmer overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: [
                                (_shimmerAnimation.value - 0.1).clamp(0.0, 1.0),
                                _shimmerAnimation.value,
                                (_shimmerAnimation.value + 0.1).clamp(0.0, 1.0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'This may take 30-60 seconds...',
                  style: TextStyle(
                    color: Colors.blue.shade500,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                // Animated dots
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.3;
                        final opacity =
                            ((_shimmerAnimation.value + delay) % 1.0 > 0.5)
                                ? 1.0
                                : 0.3;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade500.withOpacity(opacity),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Show failed status
    if (widget.message.status == 'failed') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.error_outline,
                size: 20,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video Generation Failed',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'There was an error during video generation. Please try again.',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Return empty container if no animation-related status
    return const SizedBox.shrink();
  }

  Widget _buildCodeSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle button
          InkWell(
            onTap: () {
              setState(() {
                _isCodeExpanded = !_isCodeExpanded;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.code,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Manim Code',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isCodeExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          // Collapsible code content
          if (_isCodeExpanded) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.message.animationPrompt!,
                style: const TextStyle(
                  color: Colors.green,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
