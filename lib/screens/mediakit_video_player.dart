import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../config/app_config.dart';
import '../widgets/cached_image.dart';

/// MediaKit-based video player for Desktop platforms (Windows, Linux, macOS)
/// Uses libmpv which supports all IPTV formats including HLS, MPEG-TS, RTMP, etc.
class MediaKitVideoPlayer extends StatefulWidget {
  final String streamUrl;
  final String title;
  final String? subtitle;
  final String? logoUrl;

  const MediaKitVideoPlayer({
    super.key,
    required this.streamUrl,
    required this.title,
    this.subtitle,
    this.logoUrl,
  });

  @override
  State<MediaKitVideoPlayer> createState() => _MediaKitVideoPlayerState();
}

class _MediaKitVideoPlayerState extends State<MediaKitVideoPlayer> {
  late final Player _player;
  late final VideoController _controller;
  bool _showControls = true;
  bool _isBuffering = true;
  double _volume = 100;
  double _playbackSpeed = 1.0;
  BoxFit _videoFit = BoxFit.contain;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

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
    _initializePlayer();
  }

  void _initializePlayer() {
    _player = Player();
    _controller = VideoController(_player);

    // Keep screen on while playing
    WakelockPlus.enable();

    // Enter fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Open the stream
    _player.open(Media(widget.streamUrl));

    // Listen for buffering state
    _player.stream.buffering.listen((buffering) {
      if (mounted) {
        setState(() => _isBuffering = buffering);
      }
    });

    // Listen for volume changes
    _player.stream.volume.listen((vol) {
      if (mounted) {
        setState(() => _volume = vol);
      }
    });

    // Listen for position changes
    _player.stream.position.listen((pos) {
      if (mounted) {
        setState(() => _position = pos);
      }
    });

    // Listen for duration changes
    _player.stream.duration.listen((dur) {
      if (mounted) {
        setState(() => _duration = dur);
      }
    });

    // Auto-hide controls
    _startControlsTimer();
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

  void _startControlsTimer() {
    Future.delayed(const Duration(seconds: 5), () {
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

  void _setPlaybackSpeed(double speed) {
    setState(() => _playbackSpeed = speed);
    _player.setRate(speed);
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

  @override
  void dispose() {
    _player.dispose();
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
      body: MouseRegion(
        onEnter: (_) => _showControlsTemporarily(),
        onHover: (_) => _showControlsTemporarily(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControls,
          onDoubleTap: () {
            // Double tap to play/pause
            _player.playOrPause();
          },
          child: Stack(
            children: [
              // Video - wrapped to not intercept taps
              Positioned.fill(
                child: IgnorePointer(
                  child: FittedBox(
                    fit: _videoFit,
                    child: SizedBox(
                      width: 1920,
                      height: 1080,
                      child: Video(
                        controller: _controller,
                        fill: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              // Buffering indicator
              if (_isBuffering)
                const Center(
                  child:
                      CircularProgressIndicator(color: AppConfig.primaryColor),
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
      ),
    );
  }

  void _showControlsTemporarily() {
    if (!_showControls) {
      setState(() => _showControls = true);
    }
    _startControlsTimer();
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
    return StreamBuilder<bool>(
      stream: _player.stream.playing,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rewind 10s
            IconButton(
              onPressed: () async {
                final position = await _player.stream.position.first;
                _player.seek(position - const Duration(seconds: 10));
              },
              icon: const Icon(Icons.replay_10, color: Colors.white),
              iconSize: 48,
            ),
            const SizedBox(width: 32),
            // Play/Pause
            IconButton(
              onPressed: () {
                _player.playOrPause();
                _startControlsTimer();
              },
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.white,
              ),
              iconSize: 72,
            ),
            const SizedBox(width: 32),
            // Forward 10s
            IconButton(
              onPressed: () async {
                final position = await _player.stream.position.first;
                _player.seek(position + const Duration(seconds: 10));
              },
              icon: const Icon(Icons.forward_10, color: Colors.white),
              iconSize: 48,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomControls() {
    final bool isVod = _duration.inSeconds > 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar for VOD content
          if (isVod) ...[
            Row(
              children: [
                Text(
                  _formatDuration(_position),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Expanded(
                  child: Slider(
                    value: _position.inSeconds
                        .toDouble()
                        .clamp(0, _duration.inSeconds.toDouble()),
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    activeColor: AppConfig.primaryColor,
                    inactiveColor: Colors.white24,
                    onChanged: (value) {
                      _player.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          // Control buttons row
          Row(
            children: [
              // Volume control
              IconButton(
                onPressed: () {
                  _player.setVolume(_volume > 0 ? 0 : 100);
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
                  onChanged: (value) {
                    _player.setVolume(value);
                  },
                ),
              ),

              const Spacer(),

              // Playback speed
              _buildSpeedButton(),

              // Aspect ratio
              _buildAspectRatioButton(),

              // Audio track selector
              IconButton(
                onPressed: () => _showAudioTrackDialog(),
                icon: const Icon(Icons.audiotrack, color: Colors.white),
                tooltip: 'Audio Track',
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
    final tracks = _player.state.tracks.audio;
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Track'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return ListTile(
                title:
                    Text(track.title ?? track.language ?? 'Track ${index + 1}'),
                subtitle: track.language != null ? Text(track.language!) : null,
                onTap: () {
                  _player.setAudioTrack(track);
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
    final tracks = _player.state.tracks.subtitle;
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subtitles'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tracks.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('Disable'),
                  onTap: () {
                    _player.setSubtitleTrack(SubtitleTrack.no());
                    Navigator.pop(context);
                  },
                );
              }
              final track = tracks[index - 1];
              return ListTile(
                title: Text(track.title ?? track.language ?? 'Subtitle $index'),
                subtitle: track.language != null ? Text(track.language!) : null,
                onTap: () {
                  _player.setSubtitleTrack(track);
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
