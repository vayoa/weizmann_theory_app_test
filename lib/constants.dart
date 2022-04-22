import 'package:flutter/material.dart';

abstract class Constants {
  static const Color titleBarColor = Color.fromARGB(255, 196, 196, 196);
  static const Color buttonBackgroundColor = Color.fromARGB(255, 227, 227, 227);
  static const Color buttonUnfocusedColor = Color.fromARGB(255, 192, 192, 192);
  static const Color buttonUnfocusedTextColor =
      Color.fromARGB(255, 138, 138, 138);
  static const Color rangeSelectColor = Color.fromARGB(255, 206, 206, 206);
  static const Color rangeSelectTransparentColor =
      Color.fromARGB(100, 206, 206, 206);
  static const Color selectedColor = Color.fromARGB(255, 187, 187, 187);
  static const Color measureColor = Color.fromARGB(255, 171, 171, 171);
  static const Color playedValueColor = Colors.blue;
  static const double measureWidth = 315;
  static const double measureHeight = 66;
  static const double measureSpacing = measureHeight / 2;
  static const double measurePadding = 10;
  static const double measureFontSize = 26;
  static const double measurePatternFontSize = measureFontSize * 0.74;
  static const double minButtonWidth = 54;
  static const double minButtonHeight = 29;
  static const double borderRadius = 10;
  static const TextStyle valueTextStyle =
      TextStyle(fontSize: Constants.measureFontSize);
  static const TextStyle valuePatternTextStyle =
      TextStyle(fontSize: Constants.measurePatternFontSize);
  static const TextStyle boldedValuePatternTextStyle = TextStyle(
      fontSize: Constants.measurePatternFontSize, fontWeight: FontWeight.bold);
  static const double libraryEntryWidth = 340;
  static const double libraryEntryHeight = 40;
  static const Color libraryEntryColor = Color.fromARGB(255, 163, 163, 163);
}
