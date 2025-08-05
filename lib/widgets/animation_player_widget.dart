import 'package:flutter/material.dart';
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

class _AnimationPlayerWidgetState extends State<AnimationPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  FlutterTts? _flutterTts;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isAudioMuted = false;
  bool _isAudioPlaying = false;
  double _playbackSpeed = 1.0; // Default speed
  bool _showSpeedControls = false;

  // Available playback speeds
  final List<double> _availableSpeeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    _flutterTts = FlutterTts();

    // Configure TTS for male voice
    await _flutterTts!.setLanguage("en-US");
    await _flutterTts!
        .setSpeechRate(0.5); // Base rate, will be adjusted with speed
    await _flutterTts!.setVolume(1.0);
    await _flutterTts!.setPitch(0.8); // Slightly lower pitch for male voice

    // Set completion handler
    _flutterTts!.setCompletionHandler(() {
      setState(() {
        _isAudioPlaying = false;
      });
    });

    // Set error handler
    _flutterTts!.setErrorHandler((msg) {
      print('TTS Error: $msg');
      setState(() {
        _isAudioPlaying = false;
      });
    });
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      print('🎬 [VIDEO_PLAYER] ==========================================');
      print('🎬 [VIDEO_PLAYER] INITIALIZING VIDEO PLAYER');
      print('🎬 [VIDEO_PLAYER] ==========================================');
      print('🎬 [VIDEO_PLAYER] Video URL: ${widget.videoUrl}');
      print('🎬 [VIDEO_PLAYER] URL Length: ${widget.videoUrl.length}');
      print(
          '🎬 [VIDEO_PLAYER] URL starts with http: ${widget.videoUrl.startsWith('http')}');
      print(
          '🎬 [VIDEO_PLAYER] URL starts with https: ${widget.videoUrl.startsWith('https')}');

      try {
        final uri = Uri.parse(widget.videoUrl);
        print('🎬 [VIDEO_PLAYER] Full URL breakdown:');
        print('🎬 [VIDEO_PLAYER]   - Protocol: ${uri.scheme}');
        print('🎬 [VIDEO_PLAYER]   - Host: ${uri.host}');
        print('🎬 [VIDEO_PLAYER]   - Path: ${uri.path}');
        print('🎬 [VIDEO_PLAYER]   - Query: ${uri.query}');
      } catch (e) {
        print('🎬 [VIDEO_PLAYER] URL parsing error: $e');
      }

      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Validate URL format
      if (widget.videoUrl.isEmpty) {
        throw Exception('Empty video URL');
      }

      if (!widget.videoUrl.startsWith('http')) {
        throw Exception(
            'Invalid video URL format (must start with http): ${widget.videoUrl}');
      }

      // Test URL accessibility
      print('🎬 [VIDEO_PLAYER] Testing URL accessibility...');
      try {
        final testResponse = await http.head(Uri.parse(widget.videoUrl));
        print(
            '🎬 [VIDEO_PLAYER] URL test response: ${testResponse.statusCode}');
        print(
            '🎬 [VIDEO_PLAYER] Content-Type: ${testResponse.headers['content-type']}');
        print(
            '🎬 [VIDEO_PLAYER] Content-Length: ${testResponse.headers['content-length']}');
      } catch (e) {
        print('🎬 [VIDEO_PLAYER] URL accessibility test failed: $e');
      }
      print('🎬 [VIDEO_PLAYER] Creating VideoPlayerController...');
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      print('🎬 [VIDEO_PLAYER] Initializing video controller...');
      await _videoPlayerController!.initialize();

      print('✅ [VIDEO_PLAYER] ==========================================');
      print('✅ [VIDEO_PLAYER] VIDEO CONTROLLER INITIALIZED SUCCESSFULLY!');
      print('✅ [VIDEO_PLAYER] ==========================================');
      print(
          '✅ [VIDEO_PLAYER] Video duration: ${_videoPlayerController!.value.duration}');
      print(
          '✅ [VIDEO_PLAYER] Video size: ${_videoPlayerController!.value.size}');
      print(
          '✅ [VIDEO_PLAYER] Aspect ratio: ${_videoPlayerController!.value.aspectRatio}');
      print(
          '✅ [VIDEO_PLAYER] Is initialized: ${_videoPlayerController!.value.isInitialized}');
      print(
          '✅ [VIDEO_PLAYER] Has error: ${_videoPlayerController!.value.hasError}');
      if (_videoPlayerController!.value.hasError) {
        print(
            '❌ [VIDEO_PLAYER] Error message: ${_videoPlayerController!.value.errorDescription}');
      }

      print('🎬 [VIDEO_PLAYER] Creating ChewieController...');
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showControlsOnInitialize: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading video...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).primaryColor,
          handleColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade300,
        ),
      );

      // Add listener for video state changes
      _videoPlayerController!.addListener(_onVideoStateChanged);

      setState(() {
        _isLoading = false;
      });
      print('✅ [VIDEO_PLAYER] ==========================================');
      print('✅ [VIDEO_PLAYER] COMPLETE VIDEO PLAYER SETUP FINISHED!');
      print('✅ [VIDEO_PLAYER] ==========================================');
      print('✅ [VIDEO_PLAYER] Widget is ready to display video');
      print(
          '✅ [VIDEO_PLAYER] ChewieController created: ${_chewieController != null}');
    } catch (e) {
      print('❌ [VIDEO_PLAYER] ==========================================');
      print('❌ [VIDEO_PLAYER] CRITICAL: VIDEO PLAYER INITIALIZATION FAILED');
      print('❌ [VIDEO_PLAYER] ==========================================');
      print('❌ [VIDEO_PLAYER] Error: $e');
      print('❌ [VIDEO_PLAYER] Error type: ${e.runtimeType}');
      print('❌ [VIDEO_PLAYER] Video URL that failed: ${widget.videoUrl}');
      print('❌ [VIDEO_PLAYER] Stack trace: ${StackTrace.current}');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _onVideoStateChanged() {
    if (_videoPlayerController != null) {
      final isPlaying = _videoPlayerController!.value.isPlaying;

      // Start TTS when video starts playing
      if (isPlaying &&
          !_isAudioPlaying &&
          !_isAudioMuted &&
          widget.textContent != null) {
        _startTTS();
      }

      // Stop TTS when video stops
      if (!isPlaying && _isAudioPlaying) {
        _stopTTS();
      }
    }
  }

  Future<void> _startTTS() async {
    if (_flutterTts != null && widget.textContent != null && !_isAudioMuted) {
      setState(() {
        _isAudioPlaying = true;
      });

      // Adjust TTS speed based on video playback speed
      await _updateTTSSpeed();
      await _flutterTts!.speak(widget.textContent!);
    }
  }

  Future<void> _stopTTS() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
      setState(() {
        _isAudioPlaying = false;
      });
    }
  }

  Future<void> _updateTTSSpeed() async {
    if (_flutterTts != null) {
      // Base rate is 0.5, adjust based on playback speed
      double ttsRate = 0.5 * _playbackSpeed;
      // Clamp TTS rate to reasonable bounds (0.1 to 1.0)
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

      // Update video speed
      await _videoPlayerController!.setPlaybackSpeed(speed);

      // Update TTS speed if currently playing
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
    _videoPlayerController?.removeListener(_onVideoStateChanged);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _flutterTts?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          if (widget.title != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
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
                        const SizedBox(height: 2),
                        Text(
                          'Mathematical Animation Player',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Speed control button
                  Container(
                    decoration: BoxDecoration(
                      color: _playbackSpeed != 1.0
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _playbackSpeed != 1.0
                            ? Theme.of(context).primaryColor.withOpacity(0.3)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _showSpeedControls = !_showSpeedControls;
                        });
                      },
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.speed,
                            size: 18,
                            color: _playbackSpeed != 1.0
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade600,
                          ),
                          if (_playbackSpeed != 1.0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${_playbackSpeed}x',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                      tooltip: 'Playback Speed: ${_playbackSpeed}x',
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: const Size(40, 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // URL display for debugging
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Video URL:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.videoUrl,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Audio control button
                  if (widget.textContent != null)
                    Container(
                      decoration: BoxDecoration(
                        color: _isAudioMuted
                            ? Colors.red.shade50
                            : (_isAudioPlaying
                                ? Colors.green.shade50
                                : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isAudioMuted
                              ? Colors.red.shade200
                              : (_isAudioPlaying
                                  ? Colors.green.shade200
                                  : Colors.grey.shade200),
                        ),
                      ),
                      child: IconButton(
                        onPressed: _toggleAudioMute,
                        icon: Icon(
                          _isAudioMuted
                              ? Icons.volume_off
                              : (_isAudioPlaying
                                  ? Icons.volume_up
                                  : Icons.volume_up),
                          size: 18,
                          color: _isAudioMuted
                              ? Colors.red.shade600
                              : (_isAudioPlaying
                                  ? Colors.green.shade600
                                  : Colors.grey.shade600),
                        ),
                        tooltip: _isAudioMuted ? 'Unmute Audio' : 'Mute Audio',
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: const Size(40, 40),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Speed controls dropdown with enhanced styling
          if (_showSpeedControls)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Playback Speed',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableSpeeds.map((speed) {
                      final isSelected = speed == _playbackSpeed;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _setPlaybackSpeed(speed),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${speed}x',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          if (_isLoading)
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'URL: ${widget.videoUrl}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_hasError)
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF2D1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load video',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _initializeVideoPlayer,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'URL: ${widget.videoUrl}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_chewieController != null)
            Container(
              height: 300,
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
                    // Video Player
                    Center(
                      child: AspectRatio(
                        aspectRatio:
                            _videoPlayerController!.value.aspectRatio > 0
                                ? _videoPlayerController!.value.aspectRatio
                                : 16 / 9,
                        child: Chewie(controller: _chewieController!),
                      ),
                    ),
                    // Debug overlay (top-right corner)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LOADED',
                          style: TextStyle(
                            color: Colors.green.shade400,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
