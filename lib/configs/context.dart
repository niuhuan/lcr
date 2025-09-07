import 'package:flutter/material.dart';
import 'package:lcr/configs/app_settings.dart';

late String contextDir;

double get coverRadius => 5.0;

double get coverWidth => appSettings.coverWidth * 1.0;

double get coverHeight => appSettings.coverHeight * 1.0;

double get listGridGap => 20.0;

double get buttonFontSize => 16 * appSettings.fontScalePercent / 100;

double get cardIconSize => 18.0 * appSettings.fontScalePercent / 100;

double get cardIconMargin => 5.0 * appSettings.fontScalePercent / 100;

TextStyle cardTitleStyle(ThemeData theme) {
  var tf = theme.textTheme.titleMedium;
  return TextStyle(
    fontSize: (tf?.fontSize ?? 17.5) * appSettings.fontScalePercent / 100,
    fontWeight: tf?.fontWeight,
    color: tf?.color,
  );
}

TextStyle cardAuthorStyle(ThemeData theme) {
  var tf = theme.textTheme.labelLarge;
  return TextStyle(
    fontSize: (tf?.fontSize ?? 14) * appSettings.fontScalePercent / 100,
    fontWeight: tf?.fontWeight,
    color: tf?.color,
  );
}

TextStyle cardTagStyle(ThemeData theme) {
  var tf = theme.textTheme.labelMedium;
  return TextStyle(
    fontSize: (tf?.fontSize ?? 12) * appSettings.fontScalePercent / 100,
    fontWeight: tf?.fontWeight,
    color: tf?.color,
  );
}

TextStyle cardLogStyle(ThemeData theme) {
  var tf = theme.textTheme.labelSmall;
  return TextStyle(
    fontSize: (tf?.fontSize ?? 10) * appSettings.fontScalePercent / 100,
    fontWeight: tf?.fontWeight,
    color: tf?.color,
  );
}
