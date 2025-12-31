import 'package:flutter/material.dart';
import 'package:streamnet_tv/l10n/app_localizations.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.search ?? 'Search')),
      body: const Center(child: Text('Search Content')),
    );
  }
}
