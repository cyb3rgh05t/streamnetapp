import 'package:flutter/material.dart';
import 'package:streamnet_tv/l10n/app_localizations.dart';

class WatchHistoryScreen extends StatelessWidget {
  const WatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.history ?? 'Watch History')),
      body: const Center(child: Text('Watch History Content')),
    );
  }
}
