import 'package:flutter/material.dart';

/// Stub for MediaKit Video Player on Web platform
/// Web doesn't support MediaKit, so we redirect to the HTML5 video player
class MediaKitVideoPlayer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // This stub should never be called directly on web
    // The VideoPlayerScreen redirects to VideoPlayerWeb for web platform
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            const Text(
              'MediaKit is not available on Web',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Stream: $streamUrl',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
