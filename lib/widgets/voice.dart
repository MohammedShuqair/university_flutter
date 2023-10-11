import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:university_app/cache/widgets/download_button.dart';
import 'package:university_app/cache/widgets/file_size.dart';
import 'package:university_app/controllers/downloads_provider.dart';
import 'package:university_app/models/sound.dart';
import 'package:university_app/models/cache/sound/sound.dart' as cs;

import '../cache/cache_file/sound_cache.dart';
import '../cache/controller/hive_provider.dart';
import '../controllers/mode.dart';
import '../theme/my_colors.dart';
import 'package:path/path.dart' as p;

class VoiceWidget extends StatefulWidget {
  final SoundModel model;

  const VoiceWidget({Key? key, required this.model}) : super(key: key);

  @override
  State<VoiceWidget> createState() => _VoiceWidgetState();
}

class _VoiceWidgetState extends State<VoiceWidget> {
  String? filePath;
  DownloadStatus status = DownloadStatus.notStarted;
  @override
  void initState() {
    // TODO: implement initState
    CacheSound()
        .getFilePath(
            widget.model.id, p.extension(widget.model.res).toLowerCase())
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          SizedBox(
            height: 20.h,
          ),
          PhysicalModel(
            color: color,
            elevation: 6,
            shadowColor: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
            child: ListTile(
              leading: Consumer<DownloadsProvider>(
                builder: (context, provider, child) {
                  return DownloadButton2(
                      status: status,
                      id: widget.model.id,
                      onTapDownload: () async {
                        final Box<cs.SoundModel>? box =
                            await context.read<HiveProvider>().openSoundBox();
                        DownloadModel downloadModel = await CacheSound()
                            .addSoundModel(widget.model, box!);
                        if (downloadModel.contentLength != null) {
                          provider.addDownloadModel(downloadModel);
                          downloadModel.stream?.listen((List<int> newBytes) {
                            provider.addCurrentBytes(
                                downloadModel.id, newBytes);
                          }, onDone: () async {
                            File file = File(downloadModel.path);
                            await file
                                .writeAsBytes(downloadModel.currentBytes ?? []);
                            filePath = downloadModel.path;
                            status = DownloadStatus.done;
                            provider.removeModel(downloadModel.id);
                          });
                        } else {
                          status = DownloadStatus.inProgress;
                          downloadModel.stream?.listen((List<int> newBytes) {},
                              onDone: () async {
                            File file = File(downloadModel.path);
                            await file
                                .writeAsBytes(downloadModel.currentBytes ?? []);
                            filePath = downloadModel.path;
                            status = DownloadStatus.done;
                            setState(() {});
                          });
                        }

                        await context.read<HiveProvider>().closeSoundBox();
                        setState(() {});
                      });
                },
              ),
              trailing: SvgPicture.asset('images/play.svg'),
              title: Text(
                widget.model.name,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontFamily: 'Droid',
                  color: Colors.blueAccent,
                ),
              ),
              subtitle: FixedFileSize(size: widget.model.size),
            ),
          ),
          // Visibility(
          //   visible: false,
          //   child: ListTile(
          //     title: Text(
          //       link,
          //       textDirection: TextDirection.rtl,
          //       style: TextStyle(
          //         fontSize: 14.sp,
          //         fontFamily: 'Droid',
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
    // return Material(
    //   elevation: 21,
    //   shadowColor: Colors.grey.shade100,
    //   child: ListTile(
    //    shape: RoundedRectangleBorder(
    //      borderRadius: BorderRadius.circular(15)
    //    ),
    //     title: Text(link ,style: TextStyle(fontSize: 14,fontFamily: 'Droid' ),),
    //   ),
    // );
  }
}
