import 'package:hive_flutter/hive_flutter.dart';
import 'package:university_app/cache/cache_settIngs.dart';
import 'package:university_app/controllers/downloads_provider.dart';

import 'cache.dart';
import '../../models/cache/lecture/lecture.dart' as cl;
import '../../models/lectures.dart' as l;
import 'package:path/path.dart' as p;

class CacheLectures extends Cache {
  static final CacheLectures _instance = CacheLectures._internal();

  factory CacheLectures() {
    return _instance;
  }

  CacheLectures._internal() {
    setResType(CacheSettings.lecturePath);
  }

  // List<cb.LecturesModel> get cached => Boxes.getLecturesModels().values.toList();

  Future<DownloadModel> addLecturesModel(
      l.LecturesModel lecture, Box<cl.LectureModel> box) async {
    final pdf = cl.LectureModel()
      ..id = lecture.id
      ..name = lecture.name
      ..resource_type_id = lecture.resource_type_id
      ..size = lecture.size
      ..res = lecture.res
      ..created_at = DateTime.now().toString()
      ..updated_at = lecture.updated_at
      ..isPdf = lecture.isPdf;

    await box.add(pdf);
    return await putFileFromUrlInPath2(lecture.res, lecture.id);
  }

  Future<void> deleteLecturesModel(cl.LectureModel lectureModel) async {
    await removeFile(
        lectureModel.id, p.extension(lectureModel.res).toLowerCase());
    await lectureModel.delete();
  }

  void removeAllCached(Box<cl.LectureModel> box) async {
    for (var lecture in box.values) {
      await removeFile(lecture.id, p.extension(lecture.res).toLowerCase());
    }
    await box.clear();
  }
}
