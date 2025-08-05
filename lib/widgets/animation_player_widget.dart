import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class AnimationPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final String? textContent; // AI response text for TTS

  const AnimationPlayerWidget({
    super.key,
    required this.videoUrl,
    this.title,
    this.textContent,
  });

  @override
  State<AnimationPlayerWidget> createState() => _AnimationPlayerWidgetState();
}

class _AnimationPlayerWidgetState extends State<AnimationPlayerWidget>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  FlutterTts? _flutterTts;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isAudioMuted = false;
  bool _isAudioPlaying = false;
  double _playbackSpeed = 1.0;
  bool _showSpeedControls = false;
  bool _showTranscript = false;
  List<String> _transcriptSentences = [];
  int _currentSentenceIndex = 0;
  bool _isAutoScrollEnabled = true;
  bool _isFullScreen = false;
  bool _isBuffering = false;

  // Available playback speeds optimized for mobile
  final List<double> _availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideoPlayer();
    _initializeTTS();
    _prepareTranscript();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle for better mobile performance
    if (_videoPlayerController != null) {
      if (state == AppLifecycleState.paused) {
        _videoPlayerController!.pause();
        _stopTTS();
      } else if (state == AppLifecycleState.resumed) {
        // Video will resume when user taps play
      }
    }
  }

  void _prepareTranscript() {
    if (widget.textContent != null) {
      final text = widget.textContent!
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      
      final sentences = text
          .split(RegExp(r'[.!?]+'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
      
      setState(() {
        _transcriptSentences = sentences;
      });
    }
  }

  Future<void> _initializeTTS() async {
    _flutterTts = FlutterTts();

    await _flutterTts!.setLanguage("en-US");
    await _flutterTts!.setSpeechRate(0.5);
    await _flutterTts!.setVolume(1.0);
    await _flutterTts!.setPitch(0.8);

    _flutterTts!.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      _updateTranscriptProgress(text, startOffset, endOffset);
    });

    _flutterTts!.setCompletionHandler(() {
      setState(() {
        _isAudioPlaying = false;
        _currentSentenceIndex = 0;
      });
    });

    _flutterTts!.setErrorHandler((msg) {
      print('TTS Error: $msg');
      setState(() {
        _isAudioPlaying = false;
        _currentSentenceIndex = 0;
      });
    });
  }

  void _updateTranscriptProgress(String text, int startOffset, int endOffset) {
    if (_transcriptSentences.isNotEmpty) {
      int totalLength = 0;
      for (int i = 0; i < _transcriptSentences.length; i++) {
        final sentenceLength = _transcriptSentences[i].length;
        if (startOffset >= totalLength && startOffset < totalLength + sentenceLength) {
          if (_currentSentenceIndex != i) {
            setState(() {
              _currentSentenceIndex = i;
            });
          }
          break;
        }
        totalLength += sentenceLength + 1;
      }
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      print('🎬 [MOBILE_VIDEO] Initializing mobile-optimized video player');
      print('🎬 [MOBILE_VIDEO] Video URL: ${widget.videoUrl}');

      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      if (widget.videoUrl.isEmpty || !widget.videoUrl.startsWith('http')) {
        throw Exception('Invalid video URL: ${widget.videoUrl}');
      }

      // Test URL accessibility with timeout
      try {
        final testResponse = await http.head(
          Uri.parse(widget.videoUrl),
        ).timeout(const Duration(seconds: 10));
        print('🎬 [MOBILE_VIDEO] URL test response: ${testResponse.statusCode}');
      } catch (e) {
        print('🎬 [MOBILE_VIDEO] URL test failed: $e');
      }

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false, // Better audio control on mobile
          allowBackgroundPlayback: false,
        ),
      );

      // Add buffering listener
      _videoPlayerController!.addListener(_onVideoStateChanged);

      await _videoPlayerController!.initialize();

      if (!mounted) return;

      // Mobile-optimized Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false, // Don't autoplay on mobile to save data
        looping: true,
        aspectRatio: _calculateOptimalAspectRatio(),
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showControlsOnInitialize: true,
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget(errorMessage);
        },
        placeholder: _buildLoadingPlaceholder(),
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).primaryColor,
          handleColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey.shade800,
          bufferedColor: Colors.grey.shade600,
        ),
        // Mobile-specific options
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        systemOverlaysAfterFullScreen: SystemUiOverlay.values,
        hideControlsTimer: const Duration(seconds: 3),
      );

      setState(() {
        _isLoading = false;
      });

      print('✅ [MOBILE_VIDEO] Video player initialized successfully');
    } catch (e) {
      print('❌ [MOBILE_VIDEO] Initialization failed: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  double _calculateOptimalAspectRatio() {
    if (_videoPlayerController?.value.isInitialized == true) {
      final videoAspectRatio = _videoPlayerController!.value.aspectRatio;
      // Ensure reasonable aspect ratio for mobile
      if (videoAspectRatio > 0 && videoAspectRatio < 3.0) {
        return videoAspectRatio;
      }
    }
    return 16 / 9; // Default mobile-friendly aspect ratio
  }

  void _onVideoStateChanged() {
    if (_videoPlayerController != null && mounted) {
      final value = _videoPlayerController!.value;
      
      // Handle buffering state
      if (value.isBuffering != _isBuffering) {
        setState(() {
          _isBuffering = value.isBuffering;
        });
      }

      // Handle TTS synchronization
      if (value.isPlaying && !_isAudioPlaying && !_isAudioMuted && widget.textContent != null) {
        _startTTS();
      } else if (!value.isPlaying && _isAudioPlaying) {
        _stopTTS();
      }
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Video Error',
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _initializeVideoPlayer,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startTTS() async {
    if (_flutterTts != null && widget.textContent != null && !_isAudioMuted) {
      setState(() {
        _isAudioPlaying = true;
        _currentSentenceIndex = 0;
      });

      await _updateTTSSpeed();
      await _flutterTts!.speak(widget.textContent!);
    }
  }

  Future<void> _stopTTS() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
      setState(() {
        _isAudioPlaying = false;
        _currentSentenceIndex = 0;
      });
    }
  }

  Future<void> _updateTTSSpeed() async {
    if (_flutterTts != null) {
      double ttsRate = 0.5 * _playbackSpeed;
      ttsRate = ttsRate.clamp(0.1, 1.0);
      await _flutterTts!.setSpeechRate(ttsRate);
    }
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    if (_videoPlayerController != null) {
      setState(() {
        _playbackSpeed = speed;
        _showSpeedControls = false;
      });

      await _videoPlayerController!.setPlaybackSpeed(speed);

      if (_isAudioPlaying) {
        await _updateTTSSpeed();
      }
    }
  }

  Future<void> _toggleAudioMute() async {
    setState(() {
      _isAudioMuted = !_isAudioMuted;
    });

    if (_isAudioMuted) {
      await _stopTTS();
    } else if (_videoPlayerController?.value.isPlaying == true) {
      await _startTTS();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoPlayerController?.removeListener(_onVideoStateChanged);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _flutterTts?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with mobile-optimized controls
          if (widget.title != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mathematical Animation',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Mobile-optimized control buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Speed control
                      _buildMobileControlChip(
                        icon: Icons.speed,
                        label: '${_playbackSpeed}x',
                        isActive: _playbackSpeed != 1.0,
                        onTap: () {
                          setState(() {
                            _showSpeedControls = !_showSpeedControls;
                          });
                        },
                      ),
                      // Audio control
                      if (widget.textContent != null)
                        _buildMobileControlChip(
                          icon: _isAudioMuted ? Icons.volume_off : Icons.volume_up,
                          label: _isAudioMuted ? 'Muted' : 'Audio',
                          isActive: !_isAudioMuted && _isAudioPlaying,
                          onTap: _toggleAudioMute,
                        ),
                      // Transcript control
                      if (widget.textContent != null)
                        _buildMobileControlChip(
                          icon: Icons.subtitles,
                          label: 'Transcript',
                          isActive: _showTranscript,
                          onTap: () {
                            setState(() {
                              _showTranscript = !_showTranscript;
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),

          // Speed controls (mobile-optimized)
          if (_showSpeedControls)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Playback Speed',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableSpeeds.map((speed) {
                      final isSelected = speed == _playbackSpeed;
                      return GestureDetector(
                        onTap: () => _setPlaybackSpeed(speed),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            '${speed}x',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Video Player (mobile-optimized)
          if (_isLoading)
            Container(
              height: isTablet ? 300 : 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: _buildLoadingPlaceholder(),
            )
          else if (_hasError)
            Container(
              height: isTablet ? 300 : 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: _buildErrorWidget('Failed to load video'),
            )
          else if (_chewieController != null)
            Container(
              height: isTablet ? 300 : 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: _calculateOptimalAspectRatio(),
                        child: Chewie(controller: _chewieController!),
                      ),
                    ),
                    // Buffering indicator
                    if (_isBuffering)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    // Status indicator
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _isBuffering 
                                    ? Colors.orange 
                                    : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isBuffering ? 'Buffering' : 'Ready',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Mobile-optimized transcript
          if (_showTranscript && widget.textContent != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.subtitles,
                        size: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Transcript',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (_transcriptSentences.isNotEmpty)
                        Text(
                          '${_currentSentenceIndex + 1}/${_transcriptSentences.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 120,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: _transcriptSentences.isNotEmpty
                        ? ListView.builder(
                            itemCount: _transcriptSentences.length,
                            itemBuilder: (context, index) {
                              final isCurrentSentence = index == _currentSentenceIndex && _isAudioPlaying;
                              
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isCurrentSentence
                                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: isCurrentSentence
                                      ? Border.all(
                                          color: Theme.of(context).primaryColor.withOpacity(0.4),
                                        )
                                      : null,
                                ),
                                child: Text(
                                  _transcriptSentences[index],
                                  style: TextStyle(
                                    color: isCurrentSentence
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.7),
                                    fontSize: 13,
                                    height: 1.4,
                                    fontWeight: isCurrentSentence
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No transcript available',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                              ),
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

  Widget _buildMobileControlChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor.withOpacity(0.4)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.white.withOpacity(0.8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}