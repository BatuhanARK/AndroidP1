import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _themeData;
  String _fontFamily;

  ThemeNotifier(this._themeData, this._fontFamily);

  ThemeData get themeData => _themeData;
  String get fontFamily => _fontFamily;

  void setTheme(Color color) {
    _themeData = ThemeData(
      primaryColor: color,
      colorScheme: ColorScheme.fromSeed(seedColor: color, primary: color),
      appBarTheme: AppBarTheme(
        backgroundColor: color,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          fontFamily: _fontFamily,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: color,
      ),
      textTheme: _themeData.textTheme.apply(fontFamily: _fontFamily),
    );
    notifyListeners();
  }

  void setFontFamily(String fontFamily) {
    _fontFamily = fontFamily;
    _themeData = _themeData.copyWith(
      textTheme: _themeData.textTheme.apply(fontFamily: fontFamily),
      appBarTheme: _themeData.appBarTheme.copyWith(
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
        ),
      ),
    );
    notifyListeners();
  }
}
