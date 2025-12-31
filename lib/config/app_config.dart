import 'package:flutter/material.dart';

/// StreamNet TV Application Configuration
///
/// This file contains all hardcoded configuration values for the app.
/// The DNS/URL is hardcoded as requested to work exclusively with
/// the StreamNet XtreamCodes panel.

class AppConfig {
  // App Identity
  static const String appName = 'StreamNet TV';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.streamnet.tv';

  // Hardcoded Xtream Codes Panel URL
  // This is the ONLY server the app will connect to
  static const String baseUrl = 'https://xui.streamnet.live';

  // API Endpoints (Xtream Codes standard)
  static String get playerApiUrl => '$baseUrl/player_api.php';
  static String get panelApiUrl => '$baseUrl/panel_api.php';

  // Theme Colors
  static const Color primaryColor = Color(0xFFE5A00D);
  static const Color buttonColor = Color(0xFFCC7B19);

  // Stream URL Builders (used by video player screen)
  static String buildLiveStreamUrl(
    String username,
    String password,
    String streamId,
  ) => '$baseUrl/live/$username/$password/$streamId.ts';

  static String buildVodStreamUrl(
    String username,
    String password,
    String streamId,
    String extension,
  ) => '$baseUrl/movie/$username/$password/$streamId.$extension';

  static String buildSeriesStreamUrl(
    String username,
    String password,
    String streamId,
    String extension,
  ) => '$baseUrl/series/$username/$password/$streamId.$extension';

  // Legacy stream URL methods (for backward compatibility)
  static String liveStreamUrl(String username, String password, int streamId) =>
      '$baseUrl/live/$username/$password/$streamId.ts';

  static String movieStreamUrl(
    String username,
    String password,
    int streamId,
    String extension,
  ) => '$baseUrl/movie/$username/$password/$streamId.$extension';

  static String seriesStreamUrl(
    String username,
    String password,
    int streamId,
    String extension,
  ) => '$baseUrl/series/$username/$password/$streamId.$extension';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Cache Settings
  static const Duration cacheExpiration = Duration(hours: 24);

  // UI Settings
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Pagination
  static const int itemsPerPage = 50;
  static const int categoriesPerPage = 20;
}
