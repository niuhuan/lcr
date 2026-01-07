import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lcr/configs/app_settings.dart';
import 'package:lcr/configs/context.dart';
import 'package:lcr/src/rust/api/backend.dart';
import 'package:lcr/src/rust/frb_generated.dart';
import 'package:lcr/configs/theme.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path_provider/path_provider.dart' as pp;

import 'screens/app_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ja', 'JP'),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('ko', 'KR'),
      ],
      path: 'lib/assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      // 监听 appSettings 变化
      final settings = appSettingsSignal.value;
      return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: getTheme(settings.theme),
        darkTheme: getTheme(settings.darkTheme),
        home: InitialScreen(),
      );
    });
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (Platform.isIOS || Platform.isAndroid) {
      contextDir = (await pp.getApplicationSupportDirectory()).path;
    } else {
      contextDir = await desktopRoot();
    }
    if (kDebugMode) {
      print("contextDir: $contextDir");
    }
    await initBackend(applicationSupportPath: contextDir);
    await initializeAppSettings();
    if (!mounted) {
      return;
    }
    Navigator.pushReplacement(
      context,
      mixRoute(builder: (context) => AppScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(tr("general.initializing"))));
  }
}
