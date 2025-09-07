

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lcr/src/rust/database/comic_chapter.dart';

class SelectChapterScreen extends StatefulWidget {
  final List<ComicChapter> chapters;
  final ComicChapter currentChapter;
  const SelectChapterScreen({super.key, required this.chapters, required this.currentChapter});

  @override
  State<StatefulWidget> createState() => _SelectChapterScreenState();

}

class _SelectChapterScreenState extends State<SelectChapterScreen> {
  late ComicChapter _selectedChapter;

  @override
  void initState() {
    _selectedChapter = widget.currentChapter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('reader.select_chapter')),
      ),
      body: ListView.builder(
        itemCount: widget.chapters.length,
        itemBuilder: (context, index) {
          final chapter = widget.chapters[index];
          return ListTile(
            title: Text(chapter.title),
            subtitle: Text("Pages: ${chapter.imageCount}"),
            trailing: _selectedChapter.id == chapter.id
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              Navigator.of(context).pop(chapter);
            },
          );
        },
      ),
    );
  }
}