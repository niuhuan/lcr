import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lcr/screens/components/comic_card.dart';
import 'package:signals/signals_flutter.dart';
import '../src/rust/api/backend.dart';
import 'components/buttons.dart';

class ImportComicScreen extends StatefulWidget {
  const ImportComicScreen({super.key});

  @override
  State<ImportComicScreen> createState() => _ImportComicScreenState();
}

class _ImportComicScreenState extends State<ImportComicScreen> {
  final _loading = signal<bool>(false);
  final _message = signal<String>("");
  final _successIdList = signal<List<ComicInfo>>([]);
  final _failFileList = signal<Map<String, String>>({});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return Scaffold(
        appBar: AppBar(title: Text(tr("import.title")), actions: [
          if (!_loading.value && (_successIdList.value.isNotEmpty || _failFileList.value.isNotEmpty))
            IconButton(
              onPressed: () {
                _message.value = "";
                _successIdList.value = [];
                _failFileList.value = {};
              },
              icon: Icon(Icons.add),
            )
        ],),
        body: _body(),
      );
    });
  }

  Widget _body() {
    final loading = _loading.value;
    if (loading) {
      return Center(child: _loadingWidget());
    }
    if (_successIdList.value.isNotEmpty || _failFileList.value.isNotEmpty) {
      return _resultWidget();
    }
    return Center(child: _buttons());
  }

  Widget _loadingWidget() {
    final message = _message.value;
    var content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text(message),
        Spacer(),
      ],
    );
    return PopScope(canPop: false, child: content);
  }

  Widget _buttons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        _importFilesButton(),
        SizedBox(height: 20),
        _importFolderButton(),
        Spacer(),
      ],
    );
  }

  Widget _importFilesButton() {
    return CapsuleButton(
      onPressed: () async {
        var result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ["cbz", "zip", "epub"],
          allowMultiple: true,
        );
        if (result != null) {
          if (result.files.isEmpty) {
            return;
          }
          await _importFiles(result.files.map((e) => e.path!).toList());
        }
      },
      text: tr("import.import_files_button"),
    );
  }

  Widget _importFolderButton() {
    return CapsuleButton(
      onPressed: () async {
        var result = await FilePicker.platform.getDirectoryPath();
        if (result != null) {
          await _importFiles([result]);
        }
      },
      text: tr("import.import_folder_button"),
    );
  }

  Future _importFiles(List<String> filePaths) async {
    _loading.value = true;
    var successIdList = <String>[];
    var failFileMap = <String, String>{};
    for (var filePath in filePaths) {
      var completeFuture = Completer<void>();
      var filename = filePath.split("/").last;
      _message.value = filename;
      var sk = importComic(path: filePath);
      try {
        sk.listen(
          (message) async {
            const prefix = "IMPORT_FINISH_COMIC_ID:";
            if (message.startsWith(prefix)) {
              var id = message.substring(prefix.length);
              successIdList.add(id);
            } else {
              _message.value = message;
            }
          },
          onDone: () {
            if (!completeFuture.isCompleted) {
              completeFuture.complete();
            }
          },
          onError: (error) {
            var errorMessage = _extractErrorMessage(error);
            print("导入失败: $filename - $errorMessage");
            failFileMap[filename] = errorMessage;
            if (!completeFuture.isCompleted) {
              completeFuture.complete();
            }
          },
        );
        await completeFuture.future;
      } catch (e) {
        var errorMessage = _extractErrorMessage(e);
        print("导入失败: $filename - $errorMessage");
        failFileMap[filename] = errorMessage;
      }
    }
    _message.value = tr("general.loading");
    for (var id in successIdList) {
      var comic = await findComicById(comicId: id);
      if (comic != null) {
        _successIdList.value = [..._successIdList.value, comic];
      }
    }
    _failFileList.value = {..._failFileList.value, ...failFileMap};
    _loading.value = false;
  }

  String _extractErrorMessage(dynamic error) {
    var errorStr = error.toString();
    return errorStr;
  }

  Widget _resultWidget() {
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        if (_successIdList.value.isNotEmpty) ...[
          Text(
            tr("import.import_success_comic"),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._successIdList.value.map((e) => ComicCard(comic: e)),
          SizedBox(height: 20),
        ],
        if (_failFileList.value.isNotEmpty) ...[
          Text(
            tr("import.import_fail_file"),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._failFileList.value.entries.map((e) => ExpansionTile(
                title: Text(e.key),
                subtitle: Text(
                  e.value.length > 50 ? "${e.value.substring(0, 50)}..." : e.value,
                  style: TextStyle(color: Colors.red),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      e.value,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              )),
        ],
        SizedBox(height: 40),
      ],
    );
  }
}
