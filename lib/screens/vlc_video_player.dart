import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../config/app_config.dart';
import '../widgets/cached_image.dart';

/// VLC-based video player for native platforms (Android, iOS)
/// Supports all IPTV formats including HLS, MPEG-TS, RTMP, etc.
class VlcVideoPlayer extends StatefulWidget {
  final String streamUrl;
  final String title;
  final String? subtitle;
  final String? logoUrl;

  const VlcVideoPlayer({
    super.key,
    required this.streamUrl,
    required this.title,
    this.subtitle,
    this.logoUrl,
  });

  @override
  State<VlcVideoPlayer> createState() => _VlcVideoPlayerState();
}

class _VlcVideoPlayerState extends State<VlcVideoPlayer> {
  late VlcPlayerController _controller;
  bool _showControls = true;
  bool _isPlaying = false;
  bool _isBuffering = true;
  bool _hasError = false;
  String? _errorMessage;
  double _volume = 100;
  double _sliderValue = 0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;
  BoxFit _videoFit = BoxFit.contain;

  final List<double> _speedOptions = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0
  ];
  final List<BoxFit> _fitOptions = [
    BoxFit.contain,
    BoxFit.cover,
    BoxFit.fill,
    BoxFit.fitWidth,
    BoxFit.fitHeight
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('VLC Player: Initializing with URL: ${widget.streamUrl}');
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // Keep screen on while playing
    WakelockPlus.enable();

    // Enter fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    debugPrint('VLC Player: Creating controller for ${widget.streamUrl}');

    _controller = VlcPlayerController.network(
      widget.streamUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(10000),
          VlcAdvancedOptions.liveCaching(3000),
          VlcAdvancedOptions.fileCaching(5000),
        ]),
        extras: [
          '--http-user-agent=VLC/3.0.20 LibVLC/3.0.20',
          '--no-drop-late-frames',
          '--no-skip-frames',
          '--avcodec-fast',
          '--network-caching=10000',
          '--live-caching=3000',
        ],
        subtitle: VlcSubtitleOptions([
          VlcSubtitleOptions.boldStyle(true),
          VlcSubtitleOptions.fontSize(24),
        ]),
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
    );

    _controller.addListener(_onPlayerStateChanged);

    // Auto-hide controls
    _startControlsTimer();
  }

  void _onPlayerStateChanged() {
    if (!mounted) return;

    final isPlaying = _controller.value.isPlaying;
    final isBuffering = _controller.value.isBuffering;
    final duration = _controller.value.duration;
    final position = _controller.value.position;
    final hasError = _controller.value.hasError;
    final errorDescription = _controller.value.errorDescription;

    if (hasError) {
      debugPrint('VLC Player Error: $errorDescription');
    }

    debugPrint(
        'VLC Player State: playing=$isPlaying, buffering=$isBuffering, hasError=$hasError');

    setState(() {
      _isPlaying = isPlaying;
      _isBuffering = isBuffering;
      _hasError = hasError;
      _errorMessage = errorDescription;
      _duration = duration;
      _position = position;

      if (_duration.inSeconds > 0) {
        _sliderValue = _position.inSeconds / _duration.inSeconds;
      }
    });
  }

  void _startControlsTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _showControls && _isPlaying) {
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

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
    _startControlsTimer();
  }

  Future<void> _setVolume(double value) async {
    setState(() => _volume = value);
    await _controller.setVolume(value.toInt());
  }

  Future<void> _seekTo(double value) async {
    final position = Duration(seconds: (_duration.inSeconds * value).toInt());
    await _controller.seekTo(position);
  }

  void _setPlaybackSpeed(double speed) async {
    setState(() => _playbackSpeed = speed);
    await _controller.setPlaybackSpeed(speed);
  }

  void _setVideoFit(BoxFit fit) {
    setState(() => _videoFit = fit);
  }

  String _getFitName(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return 'Anpassen';
      case BoxFit.cover:
        return 'Ausfüllen';
      case BoxFit.fill:
        return 'Strecken';
      case BoxFit.fitWidth:
        return 'Breite';
      case BoxFit.fitHeight:
        return 'Höhe';
      default:
        return 'Anpassen';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerStateChanged);
    _controller.dispose();
    WakelockPlus.disable();

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
            // VLC Video Player
            Center(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: _videoFit,
                  child: SizedBox(
                    width: 1920,
                    height: 1080,
                    child: VlcPlayer(
                      controller: _controller,
                      aspectRatio: 16 / 9,
                      placeholder: const Center(
                        child: CircularProgressIndicator(
                            color: AppConfig.primaryColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Buffering indicator
            if (_isBuffering && !_hasError)
              const Center(
                child: CircularProgressIndicator(color: AppConfig.primaryColor),
              ),

            // Error display
            if (_hasError)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Playback Error',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage ?? 'Unknown error',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.streamUrl,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _isBuffering = true;
                          });
                          _controller.play();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: _buildControlsOverlay(),
              ),
            ),
          ],
        ),
      ),
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
            _buildTopBar(),

            // Center play/pause button
            _buildCenterControls(),

            // Bottom controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
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
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rewind 10s
        IconButton(
          onPressed: () async {
            final newPosition = _position - const Duration(seconds: 10);
            await _controller.seekTo(newPosition);
          },
          icon: const Icon(Icons.replay_10, color: Colors.white),
          iconSize: 48,
        ),
        const SizedBox(width: 32),
        // Play/Pause
        IconButton(
          onPressed: _togglePlayPause,
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: Colors.white,
          ),
          iconSize: 72,
        ),
        const SizedBox(width: 32),
        // Forward 10s
        IconButton(
          onPressed: () async {
            final newPosition = _position + const Duration(seconds: 10);
            await _controller.seekTo(newPosition);
          },
          icon: const Icon(Icons.forward_10, color: Colors.white),
          iconSize: 48,
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar (only for VOD, not live streams)
          if (_duration.inSeconds > 0)
            Row(
              children: [
                Text(
                  _formatDuration(_position),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Expanded(
                  child: Slider(
                    value: _sliderValue.clamp(0.0, 1.0),
                    onChanged: (value) {
                      setState(() => _sliderValue = value);
                    },
                    onChangeEnd: _seekTo,
                    activeColor: AppConfig.primaryColor,
                    inactiveColor: Colors.white24,
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),

          // Volume and other controls
          Row(
            children: [
              // Volume control
              IconButton(
                onPressed: () {
                  _setVolume(_volume > 0 ? 0 : 100);
                },
                icon: Icon(
                  _volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 100,
                child: Slider(
                  value: _volume,
                  min: 0,
                  max: 100,
                  activeColor: AppConfig.primaryColor,
                  inactiveColor: Colors.white24,
                  onChanged: _setVolume,
                ),
              ),

              const Spacer(),

              // Playback speed button
              _buildSpeedButton(),

              // Aspect ratio button
              _buildAspectRatioButton(),

              // Audio track selector
              IconButton(
                onPressed: () => _showAudioTrackDialog(),
                icon: const Icon(Icons.audiotrack, color: Colors.white),
                tooltip: 'Audio Spur',
              ),

              // Subtitle selector
              IconButton(
                onPressed: () => _showSubtitleDialog(),
                icon: const Icon(Icons.subtitles, color: Colors.white),
                tooltip: 'Untertitel',
              ),

              // Settings menu
              IconButton(
                onPressed: () => _showSettingsDialog(),
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: 'Einstellungen',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton() {
    return PopupMenuButton<double>(
      initialValue: _playbackSpeed,
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed, color: Colors.white, size: 20),
          const SizedBox(width: 4),
          Text(
            '${_playbackSpeed}x',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
      tooltip: 'Geschwindigkeit',
      onSelected: _setPlaybackSpeed,
      itemBuilder: (context) => _speedOptions.map((speed) {
        return PopupMenuItem<double>(
          value: speed,
          child: Row(
            children: [
              if (_playbackSpeed == speed)
                const Icon(Icons.check, color: AppConfig.primaryColor, size: 18)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text('${speed}x'),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAspectRatioButton() {
    return PopupMenuButton<BoxFit>(
      initialValue: _videoFit,
      icon: const Icon(Icons.aspect_ratio, color: Colors.white),
      tooltip: 'Seitenverhältnis',
      onSelected: _setVideoFit,
      itemBuilder: (context) => _fitOptions.map((fit) {
        return PopupMenuItem<BoxFit>(
          value: fit,
          child: Row(
            children: [
              if (_videoFit == fit)
                const Icon(Icons.check, color: AppConfig.primaryColor, size: 18)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(_getFitName(fit)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _showSettingsDialog() async {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Player Einstellungen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Playback Speed
              ListTile(
                leading: const Icon(Icons.speed, color: AppConfig.primaryColor),
                title: const Text('Wiedergabegeschwindigkeit',
                    style: TextStyle(color: Colors.white)),
                subtitle: Text('${_playbackSpeed}x',
                    style: const TextStyle(color: Colors.white70)),
                onTap: () {
                  Navigator.pop(context);
                  _showSpeedPickerDialog();
                },
              ),

              // Aspect Ratio
              ListTile(
                leading: const Icon(Icons.aspect_ratio,
                    color: AppConfig.primaryColor),
                title: const Text('Seitenverhältnis',
                    style: TextStyle(color: Colors.white)),
                subtitle: Text(_getFitName(_videoFit),
                    style: const TextStyle(color: Colors.white70)),
                onTap: () {
                  Navigator.pop(context);
                  _showAspectRatioDialog();
                },
              ),

              // Audio Track
              ListTile(
                leading:
                    const Icon(Icons.audiotrack, color: AppConfig.primaryColor),
                title: const Text('Audio Spur',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showAudioTrackDialog();
                },
              ),

              // Subtitles
              ListTile(
                leading:
                    const Icon(Icons.subtitles, color: AppConfig.primaryColor),
                title: const Text('Untertitel',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showSubtitleDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSpeedPickerDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Wiedergabegeschwindigkeit',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _speedOptions.length,
            itemBuilder: (context, index) {
              final speed = _speedOptions[index];
              return ListTile(
                leading: _playbackSpeed == speed
                    ? const Icon(Icons.check, color: AppConfig.primaryColor)
                    : const SizedBox(width: 24),
                title: Text('${speed}x',
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  _setPlaybackSpeed(speed);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAspectRatioDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Seitenverhältnis',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _fitOptions.length,
            itemBuilder: (context, index) {
              final fit = _fitOptions[index];
              return ListTile(
                leading: _videoFit == fit
                    ? const Icon(Icons.check, color: AppConfig.primaryColor)
                    : const SizedBox(width: 24),
                title: Text(_getFitName(fit),
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  _setVideoFit(fit);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAudioTrackDialog() async {
    final audioTracks = await _controller.getAudioTracks();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Track'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: audioTracks.length,
            itemBuilder: (context, index) {
              final trackId = audioTracks.keys.elementAt(index);
              final trackName = audioTracks[trackId] ?? 'Track $index';
              return ListTile(
                title: Text(trackName),
                onTap: () {
                  _controller.setAudioTrack(trackId);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSubtitleDialog() async {
    final subtitleTracks = await _controller.getSpuTracks();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subtitles'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: subtitleTracks.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('Disable'),
                  onTap: () {
                    _controller.setSpuTrack(-1);
                    Navigator.pop(context);
                  },
                );
              }
              final trackId = subtitleTracks.keys.elementAt(index - 1);
              final trackName = subtitleTracks[trackId] ?? 'Subtitle $index';
              return ListTile(
                title: Text(trackName),
                onTap: () {
                  _controller.setSpuTrack(trackId);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
