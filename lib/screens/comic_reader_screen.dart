import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lcr/screens/components/comic_image_provider.dart';
import 'package:lcr/screens/components/keyboard_controller.dart';
import 'package:lcr/screens/select_chapter_screen.dart';
import 'package:lcr/src/rust/api/backend.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:signals/signals_flutter.dart';

import '../configs/app_settings.dart';
import '../configs/image_filter.dart';
import '../src/rust/database/comic_chapter.dart';
import '../src/rust/database/comic_image.dart';
import '../src/rust/database/reader_settings.dart';
import 'reader_config_screen.dart';

class ComicReaderScreen extends StatefulWidget {
  final ComicInfo comic;

  const ComicReaderScreen({super.key, required this.comic});

  @override
  State<ComicReaderScreen> createState() => _ComicReaderScreenState();
}

class _ComicReaderScreenState extends State<ComicReaderScreen> {
  //
  final Signal<bool> errorFlagNoChapters = signal(false);

  //
  final Signal<ReaderSettings?> globalReaderSettings = signal(null);
  final Signal<ReaderSettings?> comicReaderSettings = signal(null);
  final Signal<List<ComicChapter>?> chapters = signal(null);
  final Signal<List<ComicImage>?> images = signal(null);

  final Signal<ComicChapter?> currentChapter = signal(null);
  final Signal<int> imgIndex = signal(0);
  final Signal<bool> fullScreen = signal(false);

  ReaderSettings? get effectiveReaderSettings {
    return comicReaderSettings.value ?? globalReaderSettings.value;
  }

  Future<void> _init() async {
    final crs = await readerSettings(comicId: widget.comic.id);
    final grs = await readerSettings(comicId: "");
    comicReaderSettings.value = crs;
    globalReaderSettings.value = grs;
    final chapters = await chapterList(comicId: widget.comic.id);
    this.chapters.value = chapters;
    if (chapters.isEmpty) {
      errorFlagNoChapters.value = true;
      return;
    }
    var c = chapters
        .where((c) => c.id == widget.comic.lastReadChapterId)
        .firstOrNull;
    if (c == null) {
      currentChapter.value = chapters.first;
      c = chapters.first;
    } else {
      currentChapter.value = c;
      imgIndex.value = widget.comic.lastReadPageIndex;
    }
    final images = await imageList(chapterId: c.id);
    this.images.value = images;
    updateComicRead(
      comicId: widget.comic.id,
      chapterId: c.id,
      chapterTitle: c.title,
      pageIndex: imgIndex.value,
    );
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    if (appSettings.fullScreenRemoveBars) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }
    super.dispose();
  }

  Future _goToChapter(ComicChapter chapter) async {
    images.value = null;
    currentChapter.value = chapter;
    imgIndex.value = 0;
    images.value = await imageList(chapterId: chapter.id);
    updateComicRead(
      comicId: widget.comic.id,
      chapterId: chapter.id,
      chapterTitle: chapter.title,
      pageIndex: imgIndex.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (errorFlagNoChapters.value) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.comic.title)),
          body: Center(child: Text("No chapters available.")),
        );
      }
      var settings = effectiveReaderSettings;
      if (settings == null ||
          chapters.value == null ||
          this.images.value == null) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.comic.title)),
          body: Center(child: CircularProgressIndicator()),
        );
      }
      final chapter = currentChapter.value!;
      final images = this.images.value!;
      final fullScreen = this.fullScreen.value;
      final key = Key(
        "${settings.readerType}:${settings.readerDirection}:${settings.imageFilter}:${chapter.id}",
      );
      return Scaffold(
        backgroundColor: Color(settings.backgroundColor),
        body: Reader(
          key: key,
          settings: settings,
          images: images,
          fullScreen: fullScreen,
          comic: widget.comic,
          switchFullScreen: () {
            this.fullScreen.value = !this.fullScreen.value;
            if (appSettings.fullScreenRemoveBars) {
              if (this.fullScreen.value) {
                SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.manual,
                  overlays: [],
                );
              } else {
                SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.edgeToEdge,
                  overlays: SystemUiOverlay.values,
                );
              }
            }
          },
          onIndex: (index) async {
            if (imgIndex.value != index) {
              imgIndex.value = index;
              updateComicRead(
                comicId: widget.comic.id,
                chapterId: chapter.id,
                chapterTitle: chapter.title,
                pageIndex: index,
              );
            }
          },
          initIndex: imgIndex.value,
          onSettings: () async {
            await Navigator.push(
              context,
              mixRoute(
                builder: (context) => ReaderConfigScreen(
                  comic: widget.comic,
                  globalSettings: globalReaderSettings.value!,
                  comicSettings: comicReaderSettings.value,
                ),
              ),
            );
            final crs = await readerSettings(comicId: widget.comic.id);
            final grs = await readerSettings(comicId: "");
            comicReaderSettings.value = crs;
            globalReaderSettings.value = grs;
          },
          nextChapter: () async {
            final chapters = this.chapters.value!;
            var currentIndex = chapters.indexWhere((c) => c.id == chapter.id);
            currentIndex += 1;
            final nextChapter = chapters[currentIndex];
            _goToChapter(nextChapter);
          },
          onSelectChapter: () async {
            final selectedChapter = await Navigator.push<ComicChapter>(
              context,
              mixRoute(
                builder: (context) => SelectChapterScreen(
                  chapters: chapters.value!,
                  currentChapter: chapter,
                ),
              ),
            );
            if (selectedChapter != null) {
              _goToChapter(selectedChapter);
            }
          },
        ),
      );
    });
  }
}

class Reader extends StatefulWidget {
  final ReaderSettings settings;
  final List<ComicImage> images;
  final bool fullScreen;
  final ComicInfo comic;
  final VoidCallback switchFullScreen;
  final ValueChanged<int> onIndex;
  final int initIndex;
  final VoidCallback onSettings;
  final VoidCallback nextChapter;
  final VoidCallback onSelectChapter;

  const Reader({
    super.key,
    required this.settings,
    required this.images,
    required this.fullScreen,
    required this.comic,
    required this.switchFullScreen,
    required this.onIndex,
    required this.initIndex,
    required this.onSettings,
    required this.nextChapter,
    required this.onSelectChapter,
  });

  @override
  State<Reader> createState() {
    switch (settings.readerType) {
      case "WebToon":
        return _WebtoonReaderState();
      case "Gallery":
        return _GalleryReaderState();
      default:
        return _GalleryReaderState();
    }
  }
}

abstract class _ReaderState extends State<Reader> {
  late Signal<int> sliderValue = signal(widget.initIndex);
  Signal<int?> sliding = signal(null);

  late final horizontal =
      widget.settings.readerDirection == "LeftToRight" ||
      widget.settings.readerDirection == "RightToLeft";

  @override
  void initState() {
    super.initState();
    if (appSettings.enableVolumeControl) {
      addVolumeListen();
      readerControllerEvent.subscribe(_onController);
    }
  }

  @override
  void dispose() {
    if (appSettings.enableVolumeControl) {
      delVolumeListen();
      readerControllerEvent.unsubscribe(_onController);
    }
    super.dispose();
  }

  void _onController(ReaderControllerEventArgs args) {
    if (args.key == "UP") {
      onPrevious();
    } else if (args.key == "DOWN") {
      onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final filter = imageFilterFromString(widget.settings.imageFilter);
      return Stack(
        children: [
          filter.process(buildContent()),
          if (widget.settings.touchType == "TouchNextDoubleFullScreen")
            _touchNextDoubleFullScreen(),
          if (!widget.fullScreen) _appbar(),
          if (!widget.fullScreen) _slideBar(),
          if (sliding.value != null)
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${(sliding.value ?? 0) + 1} / ${widget.images.length}",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _touchNextDoubleFullScreen() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        onNext();
      },
      onDoubleTap: () {
        widget.switchFullScreen();
      },
      child: Container(),
    );
  }

  Widget _appbar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        title: Text(widget.comic.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              widget.onSettings();
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () {
              widget.onSelectChapter();
            },
            icon: Icon(Icons.menu_open),
          ),
        ],
      ),
    );
  }

  Widget _slideBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(color: Colors.black54),
        child: SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 5),
            child: Slider(
              value: sliding.value?.toDouble() ?? sliderValue.value.toDouble(),
              min: 0,
              max: widget.images.length.toDouble() - 1,
              onChangeStart: (double value) {
                sliding.value = value.toInt();
              },
              onChanged: (double value) {
                sliding.value = value.toInt();
              },
              onChangeEnd: (double value) {
                sliding.value = null;
                sliderValue.value = value.toInt();
                jumpTo(value.toInt());
                this.onIndex(value.toInt());
              },
            ),
          ),
        ),
      ),
    );
  }

  double appBarHeightAndStateBarHeight() {
    final mediaQuery = MediaQuery.of(context);
    return kToolbarHeight + mediaQuery.padding.top;
  }

  void onIndex(int index) {
    if (index >= widget.images.length) {
      index = widget.images.length - 1;
    }
    sliderValue.value = index;
    widget.onIndex(index);
    for (var i = index - 2; i <= index + 2; i++) {
      if (i < 0 || i >= widget.images.length) {
        continue;
      }
      var imageData = widget.images[i];
      if (imageData.status != "READY") {
        continue;
      }
      precacheImage(
        comicImageProvider(comicId: imageData.comicId, path: imageData.path),
        context,
      );
    }
  }

  var _endTime = 0;

  FutureOr<dynamic> onScrollEnd() {
    var now = DateTime.now().millisecondsSinceEpoch;
    if (_endTime + 2500 > now) {
      _endTime = 0;
      widget.nextChapter();
    } else {
      _endTime = now;
    }
  }

  Widget buildContent();

  FutureOr<dynamic> onPrevious();

  FutureOr<dynamic> onNext();

  FutureOr<dynamic> jumpTo(int index);
}

class _WebtoonReaderState extends _ReaderState {
  var _imageLens = <double>[];
  var _maxWidth = 0.0;
  var _maxHeight = 0.0;

  var _scrollControllerInitialized = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  _onScroll() {
    var currentIndex = this.currentIndex();
    super.onIndex(currentIndex);
  }

  @override
  Widget buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final marginLeft = widget.settings.marginLeft.toDouble();
        final marginRight = widget.settings.marginRight.toDouble();
        final marginTop = horizontal
            ? (widget.settings.marginTop).toDouble()
            : (widget.settings.marginTop + appBarHeightAndStateBarHeight());
        final marginBottom = horizontal
            ? (widget.settings.marginBottom).toDouble()
            : (widget.settings.marginBottom + appBarHeightAndStateBarHeight());
        List<Widget> images = [];
        List<double> imageLens = [];
        for (var imageData in widget.images) {
          if (horizontal) {
            var imageHeight = maxHeight - marginTop - marginBottom;
            if (imageData.status == "READY") {
              var rawImageWidth = imageData.width;
              var rawImageHeight = imageData.height;
              var imageWidth = imageHeight * rawImageWidth / rawImageHeight;
              images.add(
                Image(
                  image: comicImageProvider(
                    comicId: imageData.comicId,
                    path: imageData.path,
                  ),
                  width: imageWidth,
                  height: imageHeight,
                ),
              );
              imageLens.add(imageHeight);
            } else {
              images.add(
                SizedBox(
                  width: imageHeight,
                  height: imageHeight,
                  child: Icon(Icons.error_outline_outlined),
                ),
              );
              imageLens.add(imageHeight);
            }
          } else {
            var imageWidth = maxWidth - marginLeft - marginRight;
            if (imageData.status == "READY") {
              var rawImageWidth = imageData.width;
              var rawImageHeight = imageData.height;
              var imageHeight = imageWidth * rawImageHeight / rawImageWidth;
              images.add(
                Image(
                  image: comicImageProvider(
                    comicId: imageData.comicId,
                    path: imageData.path,
                  ),
                  width: imageWidth,
                  height: imageHeight,
                ),
              );
              imageLens.add(imageHeight);
            } else {
              images.add(
                SizedBox(
                  width: imageWidth,
                  height: imageWidth,
                  child: Icon(Icons.error_outline_outlined),
                ),
              );
              imageLens.add(imageWidth);
            }
          }
        }
        images.add(SafeArea(top: false, child: Container()));
        _imageLens = imageLens;
        _maxWidth = maxWidth;
        _maxHeight = maxHeight;
        if (_scrollControllerInitialized == false) {
          _scrollControllerInitialized = true;
          double initialScrollOffset = 0;
          if (super.sliderValue.value > 0) {
            final v = super.sliderValue.value;
            for (var i = 0; i < imageLens.length && i < v; i++) {
              initialScrollOffset += imageLens[v];
            }
            final maxScroll = imageLens.reduce((a, b) => a + b) - maxHeight;
            initialScrollOffset = min(initialScrollOffset, maxScroll - 1);
          }
          print("initialScrollOffset: ${initialScrollOffset}");
          _scrollController = ScrollController(
            initialScrollOffset: initialScrollOffset,
          );
          _scrollController.addListener(_onScroll);
        }
        return ListView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
          reverse: widget.settings.readerDirection == "RightToLeft",
          padding: EdgeInsets.only(
            left: marginLeft,
            right: marginRight,
            top: marginTop,
            bottom: marginBottom,
          ),
          children: images,
        );
      },
    );
  }

  @override
  Future onPrevious() async {
    final currentScroll = _scrollController.offset;
    if (currentScroll <= 0) {
      return;
    }
    if ("Screen" == widget.settings.scrollType) {
      var target =
          currentScroll -
          (horizontal ? _maxWidth : _maxHeight) *
              widget.settings.scrollPercent /
              100;
      target = max(target, 0);
      if (widget.settings.annotation) {
        _scrollController.animateTo(
          target,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    }
    if ("Page" == widget.settings.scrollType) {
      var currentIndex = 0;
      var acc = 0.0;
      for (var i = 0; i < _imageLens.length; i++) {
        acc += _imageLens[i];
        if (acc >= currentScroll + 0.1) {
          currentIndex = i;
          break;
        }
      }
      if (currentIndex <= 0) {
        return;
      }
      var targetIndex =
          currentIndex - (widget.settings.scrollPercent > 0 ? 1 : 0);
      targetIndex = max(targetIndex, 0);
      var target = 0.0;
      for (var i = 0; i < targetIndex; i++) {
        target += _imageLens[i];
      }
      if (widget.settings.annotation) {
        _scrollController.animateTo(
          target,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    }

  }

  @override
  Future onNext() async {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll - 1) {
      await super.onScrollEnd();
      return;
    }
    if ("Screen" == widget.settings.scrollType) {
      var target =
          currentScroll +
          (horizontal ? _maxWidth : _maxHeight) *
              widget.settings.scrollPercent /
              100;
      target = min(target, maxScroll - 1);
      if (widget.settings.annotation) {
        _scrollController.animateTo(
          target,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    }
    if ("Page" == widget.settings.scrollType) {
      var currentIndex = 0;
      var acc = 0.0;
      for (var i = 0; i < _imageLens.length; i++) {
        acc += _imageLens[i];
        if (acc >= currentScroll + 0.1) {
          currentIndex = i;
          break;
        }
      }
      if (currentIndex >= _imageLens.length - 1) {
        await super.onScrollEnd();
        return;
      }
      var targetIndex =
          currentIndex + (widget.settings.scrollPercent > 0 ? 1 : 0);
      targetIndex = min(targetIndex, _imageLens.length - 1);
      var target = 0.0;
      for (var i = 0; i < targetIndex; i++) {
        target += _imageLens[i];
      }
      if (widget.settings.annotation) {
        _scrollController.animateTo(
          target,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    }
  }

  int currentIndex() {
    var current = _scrollController.offset;
    var acc = 0.0;
    for (var i = 0; i < _imageLens.length; i++) {
      acc += _imageLens[i];
      if (acc >= current + 0.1) {
        return i;
      }
    }
    return _imageLens.length - 1;
  }

  @override
  Future jumpTo(int index) async {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (index < 0 || index >= widget.images.length) {
      return;
    }
    var target = 0.0;
    for (var i = 0; i < index; i++) {
      target += _imageLens[i];
    }
    target = min(target, maxScroll - 1);
    if (widget.settings.annotation) {
      _scrollController.animateTo(
        target,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }
}

class _GalleryReaderState extends _ReaderState {
  late final _controller = PageController(initialPage: widget.initIndex);
  final List<PhotoViewGalleryPageOptions> _options = [];

  @override
  void initState() {
    for (var imageData in widget.images) {
      if (imageData.status == "READY") {
        _options.add(
          PhotoViewGalleryPageOptions(
            imageProvider: comicImageProvider(
              comicId: imageData.comicId,
              path: imageData.path,
            ),
            filterQuality: FilterQuality.high,
          ),
        );
      } else {
        _options.add(
          PhotoViewGalleryPageOptions.customChild(child: Icon(Icons.error)),
        );
      }
    }
    super.initState();
  }

  @override
  Widget buildContent() {
    var horizontal =
        widget.settings.readerDirection == "LeftToRight" ||
        widget.settings.readerDirection == "RightToLeft";
    return PhotoViewGallery(
      pageController: _controller,
      scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
      reverse: widget.settings.readerDirection == "RightToLeft",
      pageOptions: _options,
      onPageChanged: _onPageChanged,
      backgroundDecoration: BoxDecoration(
        color: Color(widget.settings.backgroundColor),
      ),
    );
  }

  _onPageChanged(int index) {
    super.onIndex(index);
  }

  @override
  Future onPrevious() async {
    if (sliderValue.value <= 0) {
      return;
    }
    if (widget.settings.annotation) {
      _controller.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _controller.jumpToPage(sliderValue.value - 1);
    }
  }

  @override
  Future onNext() async {
    if (sliderValue.value >= widget.images.length - 1) {
      await super.onScrollEnd();
      return;
    }
    if (widget.settings.annotation) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _controller.jumpToPage(sliderValue.value + 1);
    }
  }

  @override
  Future jumpTo(int index) async {
    _controller.jumpToPage(index);
  }
}
