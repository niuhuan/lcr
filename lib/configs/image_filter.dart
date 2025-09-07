import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ImageFilter {
  final String name;
  final String code;
  final Widget Function(Widget widget) process;

  ImageFilter(this.name, this.code, this.process);
}

ImageFilter imageFilterFromString(String string) {
  for (var value in imageFilters) {
    if (string == value.code) {
      return value;
    }
  }
  return imageFilters[0];
}

List<ImageFilter> get imageFilters => [
  ImageFilter(tr("reader.image_filter.normal"), "NONE", (child) {
    return child;
  }),
  ImageFilter(tr("reader.image_filter.grayscale"), "GRAYSCALE", (child) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.color),
      child: child,
    );
  }),
  ImageFilter(tr("reader.image_filter.brown"), "BROWN", (child) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.393,
        0.769,
        0.189,
        0,
        0,
        0.349,
        0.686,
        0.168,
        0,
        0,
        0.272,
        0.534,
        0.131,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]),
      child: child,
    );
  }),
  ImageFilter(tr("reader.image_filter.srgbToLinearGamma"), "SRGB_TO_LINEAR_GAMMA", (child) {
    return ColorFiltered(
      colorFilter: const ColorFilter.srgbToLinearGamma(),
      child: child,
    );
  }),
  ImageFilter(tr("reader.image_filter.linearToSrgbGamma"), "LINEAR_TO_SRGB_GAMMA", (child) {
    return ColorFiltered(
      colorFilter: const ColorFilter.linearToSrgbGamma(),
      child: child,
    );
  }),
];

