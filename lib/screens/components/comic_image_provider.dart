import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lcr/configs/context.dart';

ImageProvider comicImageProvider({
  required String comicId,
  required String path,
  double scale = 1.0,
}) {
  return FileImage(File("$contextDir/comic/$comicId/$path"), scale: scale);
}
