import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lcr/configs/app_settings.dart';
import 'package:lcr/src/rust/api/backend.dart';
import 'package:signals/signals_flutter.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('general.app_settings'))),
        body: ListView(
          children: [
            SwitchListTile(
              title: Text(tr('settings.ui_annotation')),
              value: appSettings.annotation,
              onChanged: (value) async {
                appSettingsSignal.value = appSettings.copyWith(
                  annotation: value,
                );
                await saveAppSettings(appSettings: appSettingsSignal.value);
              },
            ),
            ListTile(
              title: Text(tr('settings.theme')),
              trailing: Watch((context) {
                return DropdownButton<String>(
                  value: appSettings.theme,
                  items: [
                    DropdownMenuItem(
                      value: "LIGHT",
                      child: Text(tr('theme.light')),
                    ),
                    DropdownMenuItem(
                      value: "DARK",
                      child: Text(tr('theme.dark')),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    appSettingsSignal.value = appSettings.copyWith(
                      theme: value,
                    );
                    await saveAppSettings(appSettings: appSettingsSignal.value);
                  },
                );
              }),
            ),
            ListTile(
              title: Text(tr('settings.dark_theme')),
              trailing: Watch((context) {
                return DropdownButton<String>(
                  value: appSettings.darkTheme,
                  items: [
                    DropdownMenuItem(
                      value: "LIGHT",
                      child: Text(tr('theme.light')),
                    ),
                    DropdownMenuItem(
                      value: "DARK",
                      child: Text(tr('theme.dark')),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    appSettingsSignal.value = appSettings.copyWith(
                      darkTheme: value,
                    );
                    await saveAppSettings(appSettings: appSettingsSignal.value);
                  },
                );
              }),
            ),
            if (Platform.isAndroid)
              SwitchListTile(
                title: Text(tr('settings.full_screen_remove_bars')),
                value: appSettings.fullScreenRemoveBars,
                onChanged: (value) async {
                  appSettingsSignal.value = appSettings.copyWith(
                    fullScreenRemoveBars: value,
                  );
                  await saveAppSettings(appSettings: appSettingsSignal.value);
                },
              ),
          ],
        ),
      );
    });
  }
}
