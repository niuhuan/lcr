import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lcr/src/rust/api/backend.dart';
import 'package:lcr/src/rust/database/reader_settings.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../configs/image_filter.dart';

class ReaderConfigScreen extends StatefulWidget {
  final ReaderSettings globalSettings;
  final ReaderSettings? comicSettings;
  final ComicInfo? comic;

  const ReaderConfigScreen({
    super.key,
    required this.globalSettings,
    this.comicSettings,
    this.comic,
  });

  @override
  State<ReaderConfigScreen> createState() => _ReaderConfigScreenState();
}

class _ReaderConfigScreenState extends State<ReaderConfigScreen> {
  late final Signal<ReaderSettings> globalReaderSettings = signal(
    widget.globalSettings,
  );
  late final Signal<ReaderSettings?> comicReaderSettings = signal(
    widget.comicSettings,
  );

  late final readerType = signal("");
  late final readerDirection = signal("");
  late final touchType = signal("");
  late final Signal<int> backgroundColor = signal(0);
  late final imageFilter = signal("");

  _init() {
    var settings = comicReaderSettings.value ?? globalReaderSettings.value;
    readerType.value = settings.readerType;
    readerDirection.value = settings.readerDirection;
    touchType.value = settings.touchType;
    backgroundColor.value = settings.backgroundColor;
    imageFilter.value = settings.imageFilter;
  }

  Future<void> _saveReaderSettings() async {
    try {
      var settings = widget.comicSettings ?? widget.globalSettings;
      final updatedSettings = ReaderSettings(
        id: settings.id,
        settingsType: settings.settingsType,
        comicId: settings.comicId,
        templateName: settings.templateName,
        backgroundColor: backgroundColor.value,
        readerType: readerType.value,
        touchType: settings.touchType,
        readerDirection: settings.readerDirection,
        imageFilter: imageFilter.value,
        marginTop: settings.marginTop,
        marginBottom: settings.marginBottom,
        marginLeft: settings.marginLeft,
        marginRight: settings.marginRight,
        annotation: settings.annotation,
        scrollType: settings.scrollType,
        scrollPercent: settings.scrollPercent,
      );

      if (widget.comic != null && comicReaderSettings.value != null) {
        // Update comic-specific settings
        await updateComicReaderSettings(
          comicId: widget.comic!.id,
          settings: updatedSettings,
        );
        final crs = await readerSettings(comicId: widget.comic!.id);
        comicReaderSettings.value = crs;
      } else {
        // Update global settings
        await updateGlobalReaderSettings(settings: updatedSettings);
        final grs = await readerSettings(comicId: "");
        globalReaderSettings.value = grs!;
      }
    } catch (e) {
      // Handle error - could show a snackbar or dialog
      debugPrint('Error saving reader settings: $e');
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('reader.reader_config'))),
        body: ListView(
          children: [
            ListTile(
              title:
                  widget.comic != null
                      ? Text(widget.comic?.title ?? '')
                      : Text(tr('general.global_config')),
            ),
            if (widget.comic != null)
              ListTile(
                title: Text(tr('reader.current_config_type')),
                subtitle: Watch(
                  (context) => Text(
                    comicReaderSettings.value != null
                        ? tr('reader.comic_specific_config')
                        : tr('reader.global_config'),
                  ),
                ),
              ),
            if (widget.comic != null && comicReaderSettings.value == null)
              ListTile(
                title: Text(tr('reader.create_comic_config')),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(tr('reader.create_comic_config')),
                          content: Text(tr('reader.create_comic_config_confirm')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(tr('general.cancel')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(tr('general.confirm')),
                            ),
                          ],
                        ),
                  );
                  if (confirm != null && confirm) {
                    await copyGlobalReaderSettingsToComic(
                      comicId: widget.comic!.id,
                    );
                    final crs = await readerSettings(comicId: widget.comic!.id);
                    final grs = await readerSettings(comicId: "");
                    comicReaderSettings.value = crs;
                    globalReaderSettings.value = grs!;
                    _init();
                  }
                },
              ),
            if (widget.comic != null && comicReaderSettings.value != null)
              ListTile(
                title: Text(tr('reader.delete_comic_config_use_global')),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(
                            tr('reader.delete_comic_config_use_global'),
                          ),
                          content: Text(
                            tr('reader.delete_comic_config_use_global_confirm'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(tr('general.cancel')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(tr('general.confirm')),
                            ),
                          ],
                        ),
                  );
                  if (confirm != null && confirm) {
                    await deleteComicReaderSettings(comicId: widget.comic!.id);
                    final crs = await readerSettings(comicId: widget.comic!.id);
                    final grs = await readerSettings(comicId: "");
                    comicReaderSettings.value = crs;
                    globalReaderSettings.value = grs!;
                    _init();
                  }
                },
              ),
            // Reader Type Selection
            ListTile(
              title: Text(tr('reader.reader_type')),
              trailing: Watch(
                (context) => DropdownButton<String>(
                  value: readerType.value,
                  items: [
                    DropdownMenuItem(
                      value: "WebToon",
                      child: Text(tr('reader.webtoon')),
                    ),
                    DropdownMenuItem(
                      value: "Gallery",
                      child: Text(tr('reader.gallery')),
                    ),
                  ],
                  onChanged: (String? newValue) async {
                    if (newValue != null && newValue != readerType.value) {
                      readerType.value = newValue;
                      await _saveReaderSettings();
                    }
                  },
                ),
              ),
            ),
            ListTile(
              title: Text(tr('reader.background_color')),
              trailing: Watch((context) {
                return Icon(Icons.square, color: Color(backgroundColor.value));
              }),
              onTap: () async {
                Color pickerColor = Color(backgroundColor.value);
                final pickedColor = await showDialog<Color>(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: pickerColor,
                              onColorChanged: (Color color) {
                                setState(() => pickerColor = color);
                              },
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              child: const Text('Got it'),
                              onPressed:
                                  () => Navigator.of(context).pop(pickerColor),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
                if (pickedColor != null) {
                  backgroundColor.value = pickedColor.toARGB32();
                  await _saveReaderSettings();
                }
              },
            ),
            Watch((context) {
              return ListTile(
                title: Text(tr('settings.image_filter')),
                trailing: DropdownButton<String>(
                  value: imageFilter.value,
                  items: [
                    for (var filter in imageFilters)
                      DropdownMenuItem(
                        value: filter.code,
                        child: Text(filter.name),
                      ),
                  ],
                  onChanged: (String? newValue) async {
                    if (newValue != null && newValue != imageFilter.value) {
                      imageFilter.value = newValue;
                      await _saveReaderSettings();
                    }
                  },
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}
