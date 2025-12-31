import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamnet_tv/config/app_config.dart';
import 'package:streamnet_tv/models/user_info.dart';
import 'package:streamnet_tv/models/category.dart';
import 'package:streamnet_tv/models/live_stream.dart';
import 'package:streamnet_tv/models/vod_stream.dart';
import 'package:streamnet_tv/models/series_stream.dart';

class ApiService {
  /// Authenticate with Xtream Codes API
  /// Uses hardcoded base URL from AppConfig
  static Future<UserInfo?> authenticate({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '${AppConfig.playerApiUrl}?username=$username&password=$password',
      );

      final response = await http.get(url).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if authentication was successful
        if (data['user_info'] != null) {
          return UserInfo.fromJson(data['user_info']);
        }
      }

      return null;
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  /// Get live stream categories
  static Future<List<Category>> getLiveCategories({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '${AppConfig.playerApiUrl}?username=$username&password=$password&action=get_live_categories',
      );

      final response = await http.get(url).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get live categories: $e');
    }
  }

  /// Get VOD categories
  static Future<List<Category>> getVodCategories({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '${AppConfig.playerApiUrl}?username=$username&password=$password&action=get_vod_categories',
      );

      final response = await http.get(url).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get VOD categories: $e');
    }
  }

  /// Get series categories
  static Future<List<Category>> getSeriesCategories({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '${AppConfig.playerApiUrl}?username=$username&password=$password&action=get_series_categories',
      );

      final response = await http.get(url).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get series categories: $e');
    }
  }

  /// Get live streams
  static Future<List<LiveStream>> getLiveStreams({
    required String username,
    required String password,
    String? categoryId,
  }) async {
    try {
      var urlString =
          '${AppConfig.playerApiUrl}?username=$username&password=$password&action=get_live_streams';
      if (categoryId != null) {
        urlString += '&category_id=$categoryId';
      }

      final url = Uri.parse(urlString);
      final response = await http.get(url).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LiveStream.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get live streams: $e');
    }
  }

  /// Get VOD streams
  static Future<List<VodStream>> getVodStreams({
    required String username,
    required String password,
    String? categoryId,
  }) async {
    try {
      var urlString =
          '${AppConfig.playerApiUrl}?username=$username&password=$password&action=get_vod_streams';
      if (categoryId != null) {
        urlString += '&category_id=$categoryId';
      }

      final url = Uri.parse(urlString);
      final response = await http.get(url).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VodStream.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get VOD streams: $e');
    }
  }

  /// Get series streams
  static Future<List<SeriesStream>> getSeriesStreams({
    required String username,
    required String password,
    String? categoryId,
  }) async {
    try {
      var urlString =
          '${AppConfig.playerApiUrl}?username=$username&password=$password&action=get_series';
      if (categoryId != null) {
        urlString += '&category_id=$categoryId';
      }

      final url = Uri.parse(urlString);
      final response = await http.get(url).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SeriesStream.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get series streams: $e');
    }
  }

  /// Get series info (seasons and episodes)
  static Future<Map<String, dynamic>?> getSeriesInfo({
    required String username,
    required String password,
    required int seriesId,
  }) async {
    try {
      final url = Uri.parse(
        '${AppConfig.playerApiUrl}?username=$username&password=$password&action=get_series_info&series_id=$seriesId',
      );

      final response = await http.get(url).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get series info: $e');
    }
  }

  /// Instance method for getSeriesInfo (for compatibility)
  Future<Map<String, dynamic>?> getSeriesInfoInstance(
    String username,
    String password,
    String seriesId,
  ) async {
    return getSeriesInfo(
      username: username,
      password: password,
      seriesId: int.parse(seriesId),
    );
  }

  /// Get VOD info
  static Future<Map<String, dynamic>?> getVodInfo({
    required String username,
    required String password,
    required int vodId,
  }) async {
    try {
      final url = Uri.parse(
        '${AppConfig.playerApiUrl}?username=$username&password=$password&action=get_vod_info&vod_id=$vodId',
      );

      final response = await http.get(url).timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get VOD info: $e');
    }
  }

  /// Build live stream URL
  static String buildLiveStreamUrl({
    required String username,
    required String password,
    required int streamId,
  }) {
    return AppConfig.liveStreamUrl(username, password, streamId);
  }

  /// Build movie stream URL
  static String buildMovieStreamUrl({
    required String username,
    required String password,
    required int streamId,
    required String extension,
  }) {
    return AppConfig.movieStreamUrl(username, password, streamId, extension);
  }

  /// Build series stream URL
  static String buildSeriesStreamUrl({
    required String username,
    required String password,
    required int streamId,
    required String extension,
  }) {
    return AppConfig.seriesStreamUrl(username, password, streamId, extension);
  }
}
