import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLoading => _isLoading;

  // Initialize with SharedPreferences instance
  ThemeProvider(SharedPreferences? prefs) {
    if (prefs != null) {
      _loadThemeMode(prefs);
    } else {
      _loadThemeModeAsync();
    }
  }

  // Synchronous loading if prefs is provided
  void _loadThemeMode(SharedPreferences prefs) {
    try {
      final savedTheme = prefs.getString(_themeKey);
      if (savedTheme != null) {
        // Parse the saved theme string
        if (savedTheme == 'ThemeMode.dark') {
          _themeMode = ThemeMode.dark;
        } else if (savedTheme == 'ThemeMode.light') {
          _themeMode = ThemeMode.light;
        } else if (savedTheme == 'ThemeMode.system') {
          _themeMode = ThemeMode.system;
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _themeMode = ThemeMode.light;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Async loading as fallback
  Future<void> _loadThemeModeAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      if (savedTheme != null) {
        if (savedTheme == 'ThemeMode.dark') {
          _themeMode = ThemeMode.dark;
        } else if (savedTheme == 'ThemeMode.light') {
          _themeMode = ThemeMode.light;
        } else if (savedTheme == 'ThemeMode.system') {
          _themeMode = ThemeMode.system;
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _themeMode = ThemeMode.light;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      // Store as readable string
      String themeString;
      switch (mode) {
        case ThemeMode.dark:
          themeString = 'ThemeMode.dark';
          break;
        case ThemeMode.light:
          themeString = 'ThemeMode.light';
          break;
        case ThemeMode.system:
          themeString = 'ThemeMode.system';
          break;
      }
      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      // Handle error silently
      debugPrint('Error saving theme preference: $e');
    }
  }

  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

