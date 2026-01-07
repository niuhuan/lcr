import 'package:flutter/material.dart';
import 'package:lcr/src/rust/api/backend.dart';
import 'package:lcr/src/rust/database/app_settings.dart';
import 'package:signals/signals.dart';

// 使用 signal 来存储 appSettings，实现响应式更新
final appSettingsSignal = signal<AppSettings>(
  AppSettings(
    id: 0,
    theme: '',
    darkTheme: '',
    copySkipConfirm: false,
    copyComicTitleTemplate: '',
    autoFullScreenIntoReader: false,
    bookListType: '',
    fontScalePercent: 0,
    coverWidth: 100,
    coverHeight: 150,
    annotation: true,
    fullScreenRemoveBars: false,
    enableVolumeControl: false,
  ),
);

Future<void> initializeAppSettings() async {
  final settings = await loadAppSettings();
  appSettingsSignal.value = settings;
}

// 便捷的 getter 方法
AppSettings get appSettings => appSettingsSignal.value;

Route<T> mixRoute<T>({required WidgetBuilder builder}) {
  if (!appSettings.annotation) {
    return PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => builder.call(context),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
  return MaterialPageRoute(builder: builder);
}
