import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:university_app/controllers/downloads_provider.dart';

class DownloadButton extends StatefulWidget {
  final Future<String?> fileFuture;
  final VoidCallback onTapDownload;
  const DownloadButton(
      {Key? key, required this.fileFuture, required this.onTapDownload})
      : super(key: key);

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: widget.fileFuture,
        builder: (_, AsyncSnapshot<String?> snapshot) {
          late Widget body;
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              body = const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              );
              break;
            default:
              String? path = snapshot.data;
              if (path == null) {
                body = IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      widget.onTapDownload();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.bookmark_add_outlined,
                      color: Colors.green,
                    ));
              } else {
                body = const Icon(
                  Icons.bookmark_added_rounded,
                  color: Colors.green,
                );
              }
              break;
          }
          return body;
        });
  }
}

class DownloadButton2 extends StatefulWidget {
  final int id;
  final DownloadStatus? status;
  final VoidCallback onTapDownload;
  const DownloadButton2(
      {Key? key,
      required this.onTapDownload,
      required this.id,
      required this.status})
      : super(key: key);

  @override
  State<DownloadButton2> createState() => _DownloadButton2State();
}

class _DownloadButton2State extends State<DownloadButton2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadsProvider>(
      builder: (context, provider, child) {
        if (provider.foundId(widget.id) &&
            provider.getDownload(widget.id)!.currentProgress != null) {
          print(
              "current progress ${provider.getDownload(widget.id)?.currentProgress}");
          return SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.green,
              value: provider.getDownload(widget.id)?.currentProgress,
            ),
          );
        } else {
          if (widget.status == DownloadStatus.notStarted) {
            return IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  widget.onTapDownload();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.bookmark_add_outlined,
                  color: Colors.green,
                ));
          } else if (widget.status == DownloadStatus.done) {
            return const Icon(
              Icons.bookmark_added_rounded,
              color: Colors.green,
            );
          } else {
            return const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }
        }
      },
    );
  }
}

enum DownloadStatus { done, inProgress, notStarted }
