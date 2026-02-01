import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/util/file_service.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'dart:async';

void zoomInImage(BuildContext context, String url, [bool showButtons = true]) {
  showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Stack(
              children: [
                PhotoView(
                  imageProvider: Image.network(url).image,
                  backgroundDecoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  loadingBuilder: (context, event) => _imageLoader(event),
                ),
                Positioned(
                  bottom: 30.0,
                  left: 0.0,
                  right: 0.0,
                  child: imageButtons(url, context, showButtons),
                ),
              ],
            ),
          ),
        );
      });
}

Widget imageButtons(String url, BuildContext context,
    [bool showButtons = true]) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SB.w10,
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            SB.w10,
            if (showButtons) ...[
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => shareImage(url),
              ),
              SB.w10,
              IconButton(
                icon: Icon(Icons.save_alt),
                onPressed: () => saveImage(url),
              ),
              SB.w10,
              IconButton(
                icon: Icon(Icons.open_in_new),
                onPressed: () =>
                    launchURLWithConfirmation(url, context: context),
              ),
              SB.w10,
            ],
          ],
        ),
      ),
    ],
  );
}

Future<void> saveImageBytes(Uint8List bytes) async {
  try {
    var path = await FileStorage.getExternalDocumentPath();
    var fileName = new Random().nextInt(10000000).toString() + '.jpg';
    var newPath = '$path/$fileName';
    File file = File(newPath);
    await file.writeAsBytes(bytes);
    showToast('Image saved to $newPath');
  } catch (e) {
    showToast('Error saving image');
  }
}

void saveImage(String url) async {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    var path = await downloadImage(url);
    showToast('Image saved to $path');
    return;
  }
  var path = await downloadImage(url);
  File file = File(path);
  var fileName = _getFileName(path);
  var newPath = '${await FileStorage.getExternalDocumentPath()}/$fileName';
  file.copy(newPath);
  showToast('Image saved to $newPath');
}

/// download image from url and share it
void shareImage(String url) async {
  var path = await downloadImage(url);
  XFile file = XFile(path);
  Share.shareXFiles([file], text: 'Image from DailyAnimeList');
}

Future<String> downloadImage(String url) async {
  var savePath = await getLocalImagePath(url);
  var response = await Dio().download(url, savePath);
  if (response.statusCode != 200) {
    showToast('Error downloading file');
    throw Exception('Error downloading file');
  }
  return savePath;
}

Future<String> getLocalImagePath(String url) async {
  var path = await _getPathToDownload();
  return '$path/${_getFileName(url)}';
}

String _getFileName(String url) {
  var fileName = url.split('/').last;
  String? extension;
  if (fileName.contains('.')) {
    extension = fileName.split('.').last;
  }
  if (extension == null) {
    return new Random().nextInt(10000000).toString() + '.jpg';
  } else {
    return fileName;
  }
}

Future<String?> _getPathToDownload() async {
  if (Platform.isAndroid) {
    final externalStorageFolder = await getExternalStorageDirectory();
    if (externalStorageFolder != null) {
      return p.join(externalStorageFolder.path, "Downloads");
    }
  } else {
    final downloadFolder = await getDownloadsDirectory();
    if (downloadFolder != null) {
      return downloadFolder.path;
    }
  }
  return null;
}

void zoomInImageList(BuildContext context, List<String> urlList,
    [int index = 0]) {
  PageController pageController = PageController(initialPage: index);
  final listener = StreamListener(index);
  pageController.addListener(() => listener.update(pageController.page?.toInt() ?? 0));
  showDialog(
      context: context,
      builder: (context) => _GalleryDialogContent(
          urlList: urlList, pageController: pageController, listener: listener));
}

class _GalleryDialogContent extends StatefulWidget {
  final List<String> urlList;
  final PageController pageController;
  final StreamListener<int> listener;
  const _GalleryDialogContent(
      {required this.urlList,
      required this.pageController,
      required this.listener});
  @override
  State<_GalleryDialogContent> createState() => __GalleryDialogContentState();
}

class __GalleryDialogContentState extends State<_GalleryDialogContent> {
  FilterQuality _quality = FilterQuality.low;
  Map<int, bool> _highResActivated = {};
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.pageController.initialPage.toInt();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted)
        setState(() {
          _quality = FilterQuality.high;
          _highResActivated[_currentIndex] = true;
        });
    });
  }

  String _getHighRes(String url) => url.contains('cdn.myanimelist.net/images/')
      ? url.replaceFirst(RegExp(r'[tv]\.(jpg|jpeg|png|webp)$'), r'l.$1')
      : url;
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                    widget.pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut),
                const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                    widget.pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut),
                const SingleActivator(LogicalKeyboardKey.escape): () =>
                    Navigator.pop(context),
              },
              child: Focus(
                  autofocus: true,
                  child: Stack(children: [
                    PhotoViewGallery.builder(
                        pageController: widget.pageController,
                        scrollPhysics: const BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _quality = FilterQuality.low;
                            _currentIndex = index;
                          });
                          _startTimer();
                        },
                        builder: (context, i) {
                          var displayUrl = (_highResActivated[i] ?? false)
                              ? _getHighRes(widget.urlList[i])
                              : widget.urlList[i];
                          return PhotoViewGalleryPageOptions(
                              imageProvider: Image.network(displayUrl).image,
                              filterQuality: _quality,
                              initialScale:
                                  PhotoViewComputedScale.contained * 0.8);
                        },
                        backgroundDecoration:
                            const BoxDecoration(color: Colors.transparent),
                        itemCount: widget.urlList.length,
                        loadingBuilder: (context, event) =>
                            const Center(child: CircularProgressIndicator())),
                    StreamBuilder<int>(
                        stream: widget.listener.stream,
                        builder: (context, snapshot) {
                          var imageIndex = snapshot.data ?? 0;
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _pageIndicator(imageIndex, widget.urlList),
                                Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 40.0),
                                    child: imageButtons(
                                        widget.urlList[imageIndex], context))
                              ]);
                        }),
                  ])),
            )));
  }
}

Widget _pageIndicator(int imageIndex, List<String> urlList) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 25.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShadowButton(
          onPressed: () {},
          child: Text('${imageIndex + 1} / ${urlList.length}'),
        ),
      ],
    ),
  );
}

Center _imageLoader(ImageChunkEvent? event) {
  return Center(
    child: Container(
      width: 20.0,
      height: 20.0,
      child: CircularProgressIndicator(
        value: event == null
            ? 0
            : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
      ),
    ),
  );
}


