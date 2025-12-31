import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'video_player_web.dart';
// Conditional imports for platform-specific players
import 'vlc_video_player.dart'
    if (dart.library.html) 'vlc_video_player_web.dart';
import 'mediakit_video_player.dart'
    if (dart.library.html) 'mediakit_video_player_web.dart';

/// Video Player Screen - Routes to the appropriate player based on platform
/// - Android/iOS: VLC Player (best codec support for mobile)
/// - Windows/Linux/macOS: MediaKit Player (libmpv-based, great codec support)
/// - Web: HTML5 Video Player (limited format support)
class VideoPlayerScreen extends StatelessWidget {
  final String streamUrl;
  final String title;
  final String? subtitle;
  final String? logoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.streamUrl,
    required this.title,
    this.subtitle,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Web platform - use HTML5 video player
    if (kIsWeb) {
      return VideoPlayerWeb(
        streamUrl: streamUrl,
        title: title,
        subtitle: subtitle,
        logoUrl: logoUrl,
      );
    }

    // Desktop platforms (Windows, Linux, macOS) - use MediaKit (libmpv)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return MediaKitVideoPlayer(
        streamUrl: streamUrl,
        title: title,
        subtitle: subtitle,
        logoUrl: logoUrl,
      );
    }

    // Mobile platforms (Android, iOS) - use VLC Player
    return VlcVideoPlayer(
      streamUrl: streamUrl,
      title: title,
      subtitle: subtitle,
      logoUrl: logoUrl,
    );
  }
}
