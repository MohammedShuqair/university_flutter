import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:university_app/cache/cache_file/form_cache.dart';
import 'package:university_app/controllers/downloads_provider.dart';
import 'package:university_app/models/form.dart';
import 'package:university_app/models/cache/form/form.dart' as cf;

import '../cache/controller/hive_provider.dart';
import '../cache/widgets/download_button.dart';
import '../cache/widgets/file_size.dart';
import '../controllers/functions.dart';
import '../controllers/home_api_controller.dart';
import '../controllers/mode.dart';
import '../screens/SummaryPDF.dart';
import '../theme/my_colors.dart';
import 'package:path/path.dart' as p;

import 'downloading_widget.dart';

class FormsWidget extends StatefulWidget {
  final FormModel formModel;
  final String imagepath;

  const FormsWidget(
      {Key? key, required this.formModel, required this.imagepath})
      : super(key: key);

  @override
  State<FormsWidget> createState() => _FormsWidgetState();
}

class _FormsWidgetState extends State<FormsWidget> {
  bool _isFutureExecuting = false;
  DownloadStatus status = DownloadStatus.notStarted;
  String? filePath;

  @override
  void initState() {
    // TODO: implement initState
    CacheForm()
        .getFilePath(widget.formModel.id,
            p.extension(widget.formModel.res).toLowerCase())
        .then((value) {
      filePath = value;
      if (value != null) status = DownloadStatus.done;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color color =
        context.watch<SettingsModel>().isDark ? colorPrimaryD : Colors.white;

    return InkWell(
      onTap: () async {
        if (!widget.formModel.isPdf) {
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
            await viewFile(widget.formModel.res, widget.formModel.id, context);
          } else {
            openFile(filePath!, context);
          }
          _isFutureExecuting = false;
          Navigator.pop(context);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SummaryPDF(
                        path: filePath,
                        res: widget.formModel.res,
                        name: widget.formModel.name,
                      )));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5),
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
        // width: 170.w,
        // height: 174.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Consumer<DownloadsProvider>(
                    builder: (context, provider, child) {
                      return DownloadButton2(
                        id: widget.formModel.id,
                        status: status,
                        onTapDownload: () async {
                          final Box<cf.FormModel>? box =
                              await context.read<HiveProvider>().openFormBox();
                          DownloadModel downloadModel = await CacheForm()
                              .addFormModel(widget.formModel, box!);
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
                          }
                          await context.read<HiveProvider>().closeFormBox();
                          setState(() {});
                        },
                      );
                    },
                  ),
                  FileSize(
                    size: widget.formModel.size,
                  )
                ],
              ),
            ),
            Expanded(
              child: Image.asset(widget.imagepath),
            ),
            SizedBox(
              height: 10.h,
            ),
            Expanded(
              child: Text(
                widget.formModel.name,
                style: TextStyle(
                  color: const Color(0xff377198),
                  fontSize: 12.spMin,
                  fontFamily: 'Droid',
                  fontWeight: FontWeight.bold,
                ),
                // overflow: TextOverflow.ellipsis,
                maxLines: 2,

                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
