import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:university_app/cache/controller/hive_provider.dart';
import 'package:university_app/cache/widgets/file_size.dart';
import 'package:university_app/controllers/downloads_provider.dart';

import '../cache/cache_file/book_cache.dart';
import '../cache/widgets/download_button.dart';
import '../controllers/functions.dart';
import '../controllers/home_api_controller.dart';
import '../controllers/mode.dart';
import '../models/book.dart';
import 'package:university_app/models/cache/book/book.dart' as cb;
import '../screens/SummaryPDF.dart';
import 'package:provider/provider.dart';

import '../theme/my_colors.dart';
import 'package:path/path.dart' as p;

import 'downloading_widget.dart';

class BooksWidget extends StatefulWidget {
  final BookModel bookModel;
  final String imagepath;

  BooksWidget({Key? key, required this.imagepath, required this.bookModel})
      : super(key: key) {}

  @override
  State<BooksWidget> createState() => _BooksWidgetState();
}

class _BooksWidgetState extends State<BooksWidget> {
  String? filePath;
  DownloadStatus status = DownloadStatus.notStarted;
  bool _isFutureExecuting = false;

  @override
  void initState() {
    // TODO: implement initState
    CacheBook()
        .getFilePath(widget.bookModel.id,
            p.extension(widget.bookModel.res).toLowerCase())
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
        if (widget.bookModel.isPdf) {
          String? path = filePath;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SummaryPDF(
                res: widget.bookModel.res,
                name: widget.bookModel.name,
                path: path,
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
            await viewFile(widget.bookModel.res, widget.bookModel.id, context);
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
                        onTapDownload: () async {
                          final Box<cb.BookModel>? box =
                              await context.read<HiveProvider>().openBookBox();
                          DownloadModel downloadModel = await CacheBook()
                              .addBookModel2(widget.bookModel, box!);
                          print("before stream $downloadModel");
                          if (downloadModel.contentLength != null) {
                            provider.addDownloadModel(downloadModel);
                            downloadModel.stream?.listen((List<int> newBytes) {
                              provider.addCurrentBytes(
                                  downloadModel.id, newBytes);
                              print(
                                  "in stream ${provider.getDownload(widget.bookModel.id)}");
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
                            downloadModel.stream?.listen((List<int> newBytes) {
                              print("unKnown Length ${newBytes.length}");
                            }, onDone: () async {
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
                          await context.read<HiveProvider>().closeBookBox();
                          setState(() {});
                        },
                        id: widget.bookModel.id,
                      );
                    },
                  ),
                  FileSize(size: widget.bookModel.size),
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
            Expanded(
              child: Text(
                widget.bookModel.name,
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
