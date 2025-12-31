import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../config/app_config.dart';
import '../widgets/cached_image.dart';

class VideoPlayerWeb extends StatefulWidget {
  final String streamUrl;
  final String title;
  final String? subtitle;
  final String? logoUrl;

  const VideoPlayerWeb({
    super.key,
    required this.streamUrl,
    required this.title,
    this.subtitle,
    this.logoUrl,
  });

  @override
  State<VideoPlayerWeb> createState() => _VideoPlayerWebState();
}

class _VideoPlayerWebState extends State<VideoPlayerWeb> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.streamUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      await _controller.initialize();
      _controller.setVolume(1.0);
      _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      // Auto-hide controls
      _startControlsTimer();
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
      if (kDebugMode) {
        print('Video player error: $e');
      }
    }
  }

  void _startControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startControlsTimer();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video
            Center(
              child: _hasError
                  ? _buildErrorWidget()
                  : _isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : const CircularProgressIndicator(
                          color: AppConfig.primaryColor,
                        ),
            ),

            // Buffering indicator
            if (_isInitialized && _controller.value.isBuffering)
              const Center(
                child: CircularProgressIndicator(color: AppConfig.primaryColor),
              ),

            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildControlsOverlay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Failed to load video',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _hasError = false;
              _isInitialized = false;
            });
            _initializePlayer();
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    iconSize: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (widget.logoUrl != null)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CachedImage(
                        imageUrl: widget.logoUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
            ),

            // Center play/pause button
            if (_isInitialized)
              IconButton(
                onPressed: () {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                  setState(() {});
                  _startControlsTimer();
                },
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                ),
                iconSize: 72,
              ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Volume control
                  if (_isInitialized)
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            final currentVolume = _controller.value.volume;
                            _controller.setVolume(currentVolume > 0 ? 0 : 1.0);
                            setState(() {});
                          },
                          icon: Icon(
                            _controller.value.volume > 0
                                ? Icons.volume_up
                                : Icons.volume_off,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Slider(
                            value: _controller.value.volume,
                            min: 0,
                            max: 1.0,
                            activeColor: AppConfig.primaryColor,
                            inactiveColor: Colors.white24,
                            onChanged: (value) {
                              _controller.setVolume(value);
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),

                  const Spacer(),

                  // Fullscreen toggle (for non-mobile)
                  IconButton(
                    onPressed: () {
                      // Toggle fullscreen on desktop
                    },
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
