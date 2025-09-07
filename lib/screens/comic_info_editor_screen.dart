import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lcr/configs/context.dart';

import '../src/rust/api/backend.dart';
import 'components/comic_image_provider.dart';

class ComicInfoEditorScreen extends StatefulWidget {
  final ComicInfo source;

  const ComicInfoEditorScreen({super.key, required this.source});

  @override
  State<ComicInfoEditorScreen> createState() => _ComicInfoEditorScreenState();
}

class _ComicInfoEditorScreenState extends State<ComicInfoEditorScreen> {
  late final id = widget.source.id;

  late var cover = ValueNotifier<String>(widget.source.cover);

  late var newCover = ValueNotifier<String>("");

  late var title = TextEditingController(text: widget.source.title);

  late var author = TextEditingController(text: widget.source.author);

  late var tags = TextEditingController(text: widget.source.tags.join(", "));

  late var description = TextEditingController(text: widget.source.description);

  late var publishedDate = TextEditingController(
    text: widget.source.publishedDate,
  );

  late var star = ValueNotifier<bool>(widget.source.star);

  @override
  dispose() {
    title.dispose();
    author.dispose();
    tags.dispose();
    description.dispose();
    star.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('edit_comic_info.title')),
        actions: [IconButton(onPressed: _onSave, icon: Icon(Icons.save))],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ValueListenableBuilder<String?>(
                    valueListenable: newCover,
                    builder: (context, value, child) {
                      Widget displayCover;
                      if (newCover.value.isNotEmpty) {
                        displayCover = Image(
                          fit: BoxFit.cover,
                          width: coverWidth,
                          height: coverHeight,
                          image: FileImage(File(newCover.value)),
                        );
                      } else {
                        displayCover = Image(
                          fit: BoxFit.cover,
                          width: coverWidth,
                          height: coverHeight,
                          image: comicImageProvider(
                            comicId: id,
                            path: cover.value,
                          ),
                        );
                      }
                      displayCover = ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(coverRadius),
                        ),
                        child: displayCover,
                      );
                      return GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            if (Platform.isAndroid || Platform.isIOS) {
                              CroppedFile? croppedFile = await ImageCropper()
                                  .cropImage(
                                    sourcePath: image.path,
                                    uiSettings: [
                                      AndroidUiSettings(
                                        toolbarTitle: 'Cropper',
                                        toolbarColor: Colors.deepOrange,
                                        toolbarWidgetColor: Colors.white,
                                        aspectRatioPresets: [
                                          CropAspectRatioPreset.original,
                                          CropAspectRatioPreset.square,
                                        ],
                                      ),
                                      IOSUiSettings(
                                        title: 'Cropper',
                                        aspectRatioPresets: [
                                          CropAspectRatioPreset.original,
                                          CropAspectRatioPreset.square,
                                        ],
                                      ),
                                    ],
                                  );
                              if (croppedFile != null) {
                                newCover.value = croppedFile.path;
                              }
                            } else {
                              newCover.value = image.path;
                            }
                          }
                        },
                        child: displayCover,
                      );
                    },
                  ),
                ),
                TextField(
                  controller: title,
                  decoration: InputDecoration(labelText: tr('general.title')),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: author,
                  decoration: InputDecoration(labelText: tr('general.author')),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: tags,
                  decoration: InputDecoration(labelText: tr('general.tags')),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: description,
                  decoration: InputDecoration(
                    labelText: tr('general.description'),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: publishedDate,
                  decoration: InputDecoration(
                    labelText: tr('general.published_date'),
                  ),
                ),
                SizedBox(height: 16),
                ValueListenableBuilder<bool>(
                  valueListenable: star,
                  builder: (context, value, child) {
                    return CheckboxListTile(
                      title: Text(tr('general.star')),
                      value: value,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          star.value = newValue;
                        }
                      },
                    );
                  },
                ),
                SizedBox(height: 24),
                SafeArea(top: false, child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _onSave() async {
    final updatedComicModel = ComicInfo(
      id: id,
      title: title.text,
      author: author.text,
      description: description.text,
      cover: widget.source.cover,
      chapterCount: widget.source.chapterCount,
      imageCount: widget.source.imageCount,
      publishedDate: publishedDate.text,
      importTime: widget.source.importTime,
      lastReadTime: widget.source.lastReadTime,
      lastReadChapterId: widget.source.lastReadChapterId,
      lastReadChapterTitle: widget.source.lastReadChapterTitle,
      lastReadPageIndex: widget.source.lastReadPageIndex,
      star: star.value,
      status: widget.source.status,
      tags:
          tags.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
    );
    await updateComic(comicInfo: updatedComicModel);
    if (newCover.value.isNotEmpty) {
      await updateComicCover(comicId: id, source: newCover.value);
    }
    Navigator.of(context).pop(updatedComicModel);
  }
}
