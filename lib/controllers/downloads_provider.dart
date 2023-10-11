import 'package:flutter/cupertino.dart';

class DownloadsProvider extends ChangeNotifier {
  List<DownloadModel> downloads = [];

  DownloadModel? getDownload(int id) {
    for (int i = 0; i < downloads.length; i++) {
      if (downloads[i].id == id) {
        return downloads[i];
      }
    }
  }

  bool foundId(int id) {
    return downloads.any((model) => model.id == id);
  }

  void addCurrentBytes(int id, List<int> currentBytes) {
    for (int i = 0; i < downloads.length; i++) {
      if (downloads[i].id == id) {
        downloads[i].addToCurrentBytes(currentBytes);
        notifyListeners();
        break;
      }
    }
  }

  void addDownload(
      {required int id,
      required int? contentLength,
      required String path,
      Stream<List<int>>? stream,
      List<int>? currentBytes}) {
    downloads.add(DownloadModel(id, contentLength, path,
        stream: stream, currentBytes: currentBytes));
    notifyListeners();
  }

  void addDownloadModel(DownloadModel model) {
    downloads.add(model);
    notifyListeners();
  }

  void removeModel(int id) {
    downloads.removeWhere((model) => model.id == id);
    notifyListeners();
  }
}

class DownloadModel {
  final int id;
  Stream<List<int>>? stream;
  final int? contentLength;
  List<int>? currentBytes = [];
  final String path;
  double? currentProgress;

  DownloadModel(this.id, this.contentLength, this.path,
      {this.stream, this.currentBytes});

  void addToCurrentBytes(List<int> newBytes) {
    print("add ${newBytes.length} to currentBytes: ${currentBytes?.length}");
    currentBytes?.addAll(newBytes);
    if (currentBytes != null &&
        contentLength != null &&
        contentLength! > currentBytes!.length) {
      currentProgress = currentBytes!.length.toDouble() / (contentLength!);
    }
  }

  // double currentProgress() {
  //   return currentBytes?.length.toDouble() ?? 0 / (contentLength ?? 1);
  // }

  @override
  String toString() {
    return "id: $id, contentLength: $contentLength, currentBytes: ${currentBytes?.length} ";
  }
}
