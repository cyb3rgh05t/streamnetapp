import 'package:flutter/material.dart';
import 'package:streamnet_tv/models/user_info.dart';
import 'package:streamnet_tv/models/category.dart';
import 'package:streamnet_tv/models/live_stream.dart';
import 'package:streamnet_tv/models/vod_stream.dart';
import 'package:streamnet_tv/models/series_stream.dart';
import 'package:streamnet_tv/services/auth_service.dart';
import 'package:streamnet_tv/services/api_service.dart';

class AuthController extends ChangeNotifier {
  UserInfo? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Content
  List<Category> _liveCategories = [];
  List<Category> _vodCategories = [];
  List<Category> _seriesCategories = [];
  List<LiveStream> _liveStreams = [];
  List<VodStream> _vodStreams = [];
  List<SeriesStream> _seriesStreams = [];

  // Getters
  UserInfo? get currentUser => _currentUser;
  UserInfo? get userInfo => _currentUser; // Alias for compatibility
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  List<Category> get liveCategories => _liveCategories;
  List<Category> get vodCategories => _vodCategories;
  List<Category> get seriesCategories => _seriesCategories;
  List<LiveStream> get liveStreams => _liveStreams;
  List<VodStream> get vodStreams => _vodStreams;
  List<SeriesStream> get seriesStreams => _seriesStreams;

  /// Login with username and password
  /// Uses hardcoded DNS from AppConfig
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.authenticate(
        username: username,
        password: password,
      );

      if (result != null) {
        _currentUser = result;
        await AuthService.saveCredentials(username, password);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout and clear all data
  Future<void> logout() async {
    await AuthService.clearCredentials();
    _currentUser = null;
    _liveCategories = [];
    _vodCategories = [];
    _seriesCategories = [];
    _liveStreams = [];
    _vodStreams = [];
    _seriesStreams = [];
    notifyListeners();
  }

  /// Load user info
  Future<void> loadUserInfo() async {
    try {
      final credentials = await AuthService.getCredentials();
      if (credentials != null) {
        _currentUser = await ApiService.authenticate(
          username: credentials['username']!,
          password: credentials['password']!,
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to load user info: $e');
    }
  }

  /// Load categories
  Future<void> loadCategories() async {
    try {
      final credentials = await AuthService.getCredentials();
      if (credentials == null) throw Exception('Not authenticated');

      _liveCategories = await ApiService.getLiveCategories(
        username: credentials['username']!,
        password: credentials['password']!,
      );

      _vodCategories = await ApiService.getVodCategories(
        username: credentials['username']!,
        password: credentials['password']!,
      );

      _seriesCategories = await ApiService.getSeriesCategories(
        username: credentials['username']!,
        password: credentials['password']!,
      );

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Load live channels
  Future<void> loadLiveChannels() async {
    try {
      final credentials = await AuthService.getCredentials();
      if (credentials == null) throw Exception('Not authenticated');

      _liveStreams = await ApiService.getLiveStreams(
        username: credentials['username']!,
        password: credentials['password']!,
      );

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load live channels: $e');
    }
  }

  /// Load movies
  Future<void> loadMovies() async {
    try {
      final credentials = await AuthService.getCredentials();
      if (credentials == null) throw Exception('Not authenticated');

      _vodStreams = await ApiService.getVodStreams(
        username: credentials['username']!,
        password: credentials['password']!,
      );

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load movies: $e');
    }
  }

  /// Load series
  Future<void> loadSeries() async {
    try {
      final credentials = await AuthService.getCredentials();
      if (credentials == null) throw Exception('Not authenticated');

      _seriesStreams = await ApiService.getSeriesStreams(
        username: credentials['username']!,
        password: credentials['password']!,
      );

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load series: $e');
    }
  }

  /// Get live streams by category
  List<LiveStream> getLiveStreamsByCategory(String categoryId) {
    return _liveStreams
        .where((stream) => stream.categoryId == categoryId)
        .toList();
  }

  /// Get VOD streams by category
  List<VodStream> getVodStreamsByCategory(String categoryId) {
    return _vodStreams
        .where((stream) => stream.categoryId == categoryId)
        .toList();
  }

  /// Get series by category
  List<SeriesStream> getSeriesByCategory(String categoryId) {
    return _seriesStreams
        .where((stream) => stream.categoryId == categoryId)
        .toList();
  }
}
