import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // Gradient Colors
  List<Color> get gradientColors {
    return [
      const Color(0xFF1D2671),
      const Color(0xFF0A0E21),
    ];
  }

  // Profile Gradient - matching Home Screen for consistency
  List<Color> get profileGradient {
    return [
      const Color(0xFF1D2671),
      const Color(0xFF0A0E21),
    ];
  }

  Color get textColor => _isDarkMode ? Colors.white : Colors.white;
  Color get subtitleColor => _isDarkMode ? Colors.white70 : Colors.white70;

  // Card/Tile Background
  Color get cardColor => _isDarkMode ? const Color(0xFF16213E) : Colors.white;

  // Text on Cards
  Color get cardTextColor => _isDarkMode ? Colors.white : Colors.grey.shade900;
  Color get cardSubtitleColor =>
      _isDarkMode ? Colors.white70 : Colors.grey.shade600;

  // Icon Colors
  Color get iconColor =>
      _isDarkMode ? Colors.blueAccent : Colors.deepPurple.shade700;

  Color get iconBgColor =>
      _isDarkMode ? const Color(0xFF0F3460) : Colors.deepPurple.shade100;
}
