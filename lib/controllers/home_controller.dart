import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isLoading = false;

  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String getPageTitle(
    int index, {
    String? history,
    String? liveTV,
    String? movies,
    String? series,
    String? settings,
  }) {
    switch (index) {
      case 0:
        return history ?? 'History';
      case 1:
        return liveTV ?? 'Live TV';
      case 2:
        return movies ?? 'Movies';
      case 3:
        return series ?? 'Series';
      case 4:
        return settings ?? 'Settings';
      default:
        return 'StreamNet TV';
    }
  }
}
