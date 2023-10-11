import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:university_app/cache/controller/hive_provider.dart';
import 'package:university_app/cache/widgets/file_size.dart';
import 'package:university_app/controllers/downloads_provider.dart';
import 'package:university_app/models/lectures.dart';

import '../cache/cache_file/lecture_cache.dart';
import '../cache/widgets/download_button.dart';
import '../controllers/functions.dart';
import '../controllers/home_api_controller.dart';
import '../controllers/mode.dart';
import 'package:university_app/models/cache/lecture/lecture.dart' as cl;
import '../screens/SummaryPDF.dart';
import 'package:provider/provider.dart';

import '../theme/my_colors.dart';
import 'package:path/path.dart' as p;

import 'downloading_widget.dart';

class LecturesWidget extends StatefulWidget {
  final LecturesModel lectureModel;
  final String imagepath;

  LecturesWidget(
      {Key? key, required this.imagepath, required this.lectureModel})
      : super(key: key) {}

  @override
  State<LecturesWidget> createState() => _LecturesWidgetState();
}

class _LecturesWidgetState extends State<LecturesWidget> {
  String? filePath;
  DownloadStatus status = DownloadStatus.notStarted;
  bool _isFutureExecuting = false;

  @override
  void initState() {
    // TODO: implement initState
    CacheLectures()
        .getFilePath(widget.lectureModel.id,
            p.extension(widget.lectureModel.res).toLowerCase())
        .then((value) {
      filePath = value;
      if (value != null) status = DownloadStatus.done;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("isCached ${widget.isCached}");
    Color color =
        context.watch<SettingsModel>().isDark ? colorPrimaryD : Colors.white;

    return InkWell(
      onTap: () async {
        if (widget.lectureModel.isPdf) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SummaryPDF(
                res: widget.lectureModel.res,
                name: widget.lectureModel.name,
                path: filePath,
              ),
            ),
          );
        } else {
          showDialog(
              context: context,
              builder: (_) => WillPopScope(
                    onWillPop: () async {
                      if (_isFutureExecuting) {
                        return false;
                      }
                      return true;
                    },
                    child: DownloadingWidget(),
                  ));
          setState(() {
            _isFutureExecuting = true;
          });
          if (filePath == null) {
            await viewFile(
                widget.lectureModel.res, widget.lectureModel.id, context);
          } else {
            openFile(filePath!, context);
          }
          _isFutureExecuting = false;
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: EdgeInsets.only(right: 5.w, left: 5.w, bottom: 5.h),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            width: 1,
            color: color,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Consumer<DownloadsProvider>(
                    builder: (context, provider, child) {
                      return DownloadButton2(
                        status: status,
                        id: widget.lectureModel.id,
                        onTapDownload: () async {
                          final Box<cl.LectureModel>? box = await context
                              .read<HiveProvider>()
                              .openLectureBox();
                          DownloadModel downloadModel = await CacheLectures()
                              .addLecturesModel(widget.lectureModel, box!);
                          if (downloadModel.contentLength != null) {
                            provider.addDownloadModel(downloadModel);
                            downloadModel.stream?.listen((List<int> newBytes) {
                              provider.addCurrentBytes(
                                  downloadModel.id, newBytes);
                            }, onDone: () async {
                              File file = File(downloadModel.path);
                              await file.writeAsBytes(
                                  downloadModel.currentBytes ?? []);
                              filePath = downloadModel.path;
                              status = DownloadStatus.done;
                              provider.removeModel(downloadModel.id);
                            });
                          } else {
                            status = DownloadStatus.inProgress;
                            downloadModel.stream?.listen(
                                (List<int> newBytes) {}, onDone: () async {
                              File file = File(downloadModel.path);
                              await file.writeAsBytes(
                                  downloadModel.currentBytes ?? []);
                              filePath = downloadModel.path;
                              status = DownloadStatus.done;
                              setState(() {});
                            });
                            // fileFuture =
                            //     CacheBook().addBookModel(widget.bookModel, box!);
                          }
                          await context.read<HiveProvider>().closeLectureBox();
                          setState(() {});
                        },
                      );
                    },
                  ),
                  FileSize(size: widget.lectureModel.size),
                ],
              ),
            ),
            Expanded(
              child: Image.asset(
                widget.imagepath,
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Text(
              widget.lectureModel.name,
              style: TextStyle(
                color: const Color(0xff377198),
                fontSize: 12.spMin,
                fontFamily: 'Droid',
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    // return Stack(
    //   children: [
    //     Container(

    //       decoration: BoxDecoration(
    //         border: Border.all(
    //           width: 1,
    //           color: Colors.white,
    //         ),
    //         borderRadius: BorderRadius.circular(15),
    //         boxShadow: const [
    //          BoxShadow(
    //             color: Colors.white,offset: Offset(2.0,2.0)
    //           ),

    //         ]
    //           ),
    //       width: 170.w,
    //       height: 170.h,
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //         children: [
    //           SizedBox(height: 10.h,),
    //           Expanded(
    //             flex: 3,
    //             child: Center(
    //               child: Image.asset(imagepath),

    //             ),
    //           ),

    //           Expanded(
    //             flex:2,
    //             child: Text(title ,maxLines: 1,style:TextStyle(color: const Color(0xff377198) , fontSize: 16.sp , fontFamily: 'Droid' , fontWeight: FontWeight.bold)))
    //         ],
    //       ),
    //     ),

    //   ],
    // );
  }
}
