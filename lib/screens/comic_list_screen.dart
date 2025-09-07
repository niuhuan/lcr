import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lcr/configs/context.dart';
import 'package:lcr/screens/comic_info_editor_screen.dart';
import 'package:lcr/screens/comic_reader_screen.dart';
import 'package:lcr/screens/components/comic_card.dart';
import 'package:lcr/src/rust/api/backend.dart';
import 'package:signals/signals_flutter.dart';
import '../configs/app_settings.dart';
import 'app_settings_screen.dart';
import 'components/comic_image_provider.dart';
import 'import_comic_screen.dart';

class ComicListScreen extends StatefulWidget {
  const ComicListScreen({super.key});

  @override
  State<ComicListScreen> createState() => _ComicListScreenState();
}

class _ComicListScreenState extends State<ComicListScreen> {
  final _list = signal(<ComicInfo>[]);
  late final _comicFuture = futureSignal(() => _loadComics());

  Future<void> _loadComics() async {
    _list.value = await listReadyComic();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("general.appName")),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                mixRoute(builder: (context) => AppSettingsScreen()),
              );
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                mixRoute(builder: (context) => ImportComicScreen()),
              );
              _comicFuture.refresh();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Watch((context) {
        return _comicFuture.value.map(
          data: (data) {
            return _buildList(_list.value);
          },
          error: (e, s) {
            if (_list.value.isNotEmpty) {
              return _buildList(_list.value);
            }
            return Center(child: Text("加载失败"));
          },
          loading: () {
            if (_list.value.isNotEmpty) {
              return _buildList(_list.value);
            }
            return Center(child: CircularProgressIndicator());
          },
        );
      }),
    );
  }

  Widget _buildList(List<ComicInfo> data) {
    if (data.isEmpty) {
      return Center(child: Text(tr("general.empty")));
    }
    if (appSettings.bookListType == "LIST_CARD") {
      return _listCard(data);
    }
    if (appSettings.bookListType == "GRID_COVER_TITLE") {
      return _gridCoverTitle(data);
    }
    return _listCard(data);
  }

  Widget _gridCoverTitle(List<ComicInfo> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var maxWidth = constraints.maxWidth;
        var imageWidth = coverWidth;
        var crossAxisCount = maxWidth ~/ (imageWidth + listGridGap);
        imageWidth =
            (maxWidth - (crossAxisCount - 1) * listGridGap) / crossAxisCount;
        var imageHeight = imageWidth * coverHeight / coverWidth;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final comic = data[index];
            return Column(
              children: [
                Image(
                  key: Key("COMIC_COVER_${comic.id}"),
                  fit: BoxFit.cover,
                  width: imageWidth,
                  height: imageHeight,
                  image: comicImageProvider(
                    comicId: comic.id,
                    path: comic.cover,
                  ),
                ),
                Text(comic.title),
              ],
            );
          },
        );
      },
    );
  }

  Widget _listCard(List<ComicInfo> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final comic = data[index];
        return ComicCard(
          comic: comic,
          onPressCard: _viewComic,
          onEdit: _editComic,
          onStarModify: _starModifyComic,
          onLongPress: _deleteConfirm,
        );
      },
    );
  }

  Future<void> _viewComic(ComicInfo comic) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ComicReaderScreen(comic: comic)),
    );
    var replace = await findComicById(comicId: comic.id);
    _list.value = [
      for (final c in _list.value)
        if (c.id == comic.id) replace! else c,
    ];
  }

  Future<void> _editComic(ComicInfo comic) async {
    var updated = await Navigator.push(
      context,
      mixRoute(builder: (context) => ComicInfoEditorScreen(source: comic)),
    );
    if (updated != null) {
      var replace = await findComicById(comicId: comic.id);
      _list.value = [
        for (final c in _list.value)
          if (c.id == comic.id) replace! else c,
      ];
    }
  }

  Future<void> _starModifyComic(ComicInfo comic) async {
    await modifyComicStar(comicId: comic.id, star: !comic.star);
    var replace = await findComicById(comicId: comic.id);
    _list.value = [
      for (final c in _list.value)
        if (c.id == comic.id) replace! else c,
    ];
  }

  Future<void> _deleteConfirm(ComicInfo comic) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr("general.delete")),
          content: Text(comic.title),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr("general.cancel")),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(tr("general.confirm")),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      await deleteComic(comicId: comic.id);
      _list.value = _list.value.where((c) => c.id != comic.id).toList();
    }
  }
}
