import 'package:flutter/material.dart';

ThemeData lightTheme() => ThemeData.light().copyWith(
  textTheme: TextTheme(
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black),
    bodySmall: TextStyle(fontSize: 12.0, color: Colors.black),
    titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    titleSmall: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    labelLarge: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      color: Colors.blue.shade800,
    ),
    labelMedium: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade700,
    ),
    labelSmall: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold,
      color: Colors.grey.shade700,
    ),
    headlineLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.black),
    headlineMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.black),
    headlineSmall: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.black),
    displayLarge: TextStyle(fontSize: 16.0, color: Colors.black),
    displayMedium: TextStyle(fontSize: 14.0, color: Colors.black),
    displaySmall: TextStyle(fontSize: 12.0, color: Colors.black),
  ),
  appBarTheme: AppBarTheme(
    elevation: 0.0,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    color: Colors.grey.shade50,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
  ),
  scaffoldBackgroundColor: Colors.white,
  buttonTheme: ButtonThemeData(
    colorScheme: ColorScheme.light(
      primary: Color(0xff34a8fc),
      onPrimary: Colors.white,
    ),
    textTheme: ButtonTextTheme.primary,
  ),
  iconButtonTheme: IconButtonThemeData(),
  sliderTheme: SliderThemeData(
    activeTrackColor: Color(0xff34a8fc),
    inactiveTrackColor: Colors.grey.shade300,
    thumbColor: Color(0xff34a8fc),
    overlayColor: Color(0x2934a8fc),
    valueIndicatorColor: Color(0xff34a8fc),
    inactiveTickMarkColor: Colors.transparent,
    activeTickMarkColor: Colors.transparent,
  ),
);


ThemeData darkTheme() => ThemeData.dark().copyWith(
  textTheme: TextTheme(
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
    bodySmall: TextStyle(fontSize: 12.0, color: Colors.white),
    titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleSmall: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    labelLarge: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      color: Colors.blueAccent.shade100,
    ),
    labelMedium: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade300,
    ),
    labelSmall: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold,
      color: Colors.grey.shade400,
    ),
    headlineLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.white),
    headlineMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white),
    headlineSmall: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.white),
    displayLarge: TextStyle(fontSize: 16.0, color: Colors.white),
    displayMedium: TextStyle(fontSize: 14.0, color: Colors.white),
    displaySmall: TextStyle(fontSize: 12.0, color: Colors.white),
  ),
  appBarTheme: AppBarTheme(
    elevation: 0.0,
    // backgroundColor: Colors.black,
    // foregroundColor: Colors.white,
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
  ),
  // scaffoldBackgroundColor: Colors.white,
  buttonTheme: ButtonThemeData(
    colorScheme: ColorScheme.light(
      primary: Color(0xff34a8fc),
      onPrimary: Colors.white,
    ),
    textTheme: ButtonTextTheme.primary,
  ),
  iconButtonTheme: IconButtonThemeData(),
  sliderTheme: SliderThemeData(
    activeTrackColor: Color(0xff34a8fc),
    inactiveTrackColor: Colors.grey.shade300,
    thumbColor: Color(0xff34a8fc),
    overlayColor: Color(0x2934a8fc),
    valueIndicatorColor: Color(0xff34a8fc),
    inactiveTickMarkColor: Colors.transparent,
    activeTickMarkColor: Colors.transparent,
  ),
);

typedef ThemeDataConstructor = ThemeData Function();

var _themeMap = <String, ThemeDataConstructor>{
  "LIGHT" : lightTheme,
  "DARK" : darkTheme,
};

ThemeData getTheme(String themeCode) {
  ThemeDataConstructor fun = _themeMap[themeCode] ?? lightTheme;
  return fun.call();
}
