

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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // 延迟执行滚动，确保ListView已经构建完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedChapter();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedChapter() {
    final currentIndex = widget.chapters.indexWhere(
      (chapter) => chapter.id == widget.currentChapter.id,
    );
    
    if (currentIndex == -1) return;

    final itemHeight = 72.0; // ListTile的默认高度
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    final availableHeight = screenHeight - appBarHeight;
    
    // 计算目标位置，使选中项尽量在屏幕中间
    final targetOffset = (currentIndex * itemHeight) - (availableHeight / 2) + (itemHeight / 2);
    
    // 确保滚动位置在有效范围内
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScrollExtent);
    
    _scrollController.jumpTo(clampedOffset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('reader.select_chapter')),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: widget.chapters.length,
        itemBuilder: (context, index) {
          final chapter = widget.chapters[index];
          return ListTile(
            title: Text(chapter.title),
            subtitle: Text("Pages: ${chapter.imageCount}"),
            trailing: widget.currentChapter.id == chapter.id
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