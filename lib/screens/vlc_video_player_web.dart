import 'package:flutter/material.dart';
import 'video_player_web.dart';

/// Stub for VLC player on web platform
/// Web uses HTML5 video player instead
class VlcVideoPlayer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // On web, redirect to web player
    return VideoPlayerWeb(
      streamUrl: streamUrl,
      title: title,
      subtitle: subtitle,
      logoUrl: logoUrl,
    );
  }
}
