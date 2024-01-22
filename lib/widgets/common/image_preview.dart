import 'dart:io';
import 'dart:math';

import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/util/file_service.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share/share.dart';
import 'package:path/path.dart' as p;

void zoomInImage(BuildContext context, String url, [bool showButtons = true]) {
  showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              PhotoView(
                imageProvider: Image.network(url).image,
                backgroundDecoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                loadingBuilder: (context, event) => _imageLoader(event),
              ),
              imageButtons(url, context, showButtons),
            ],
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

void saveImage(String url) async {
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
  Share.shareFiles([path], text: 'Image from DailyAnimeList');
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
  pageController.addListener(() {
    listener.update(pageController.page?.toInt() ?? 0);
  });
  showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                PhotoViewGallery.builder(
                  pageController: pageController,
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int i) {
                    var url = urlList[i];
                    return PhotoViewGalleryPageOptions(
                      imageProvider: Image.network(url).image,
                      initialScale: PhotoViewComputedScale.contained * 0.8,
                    );
                  },
                  backgroundDecoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  itemCount: urlList.length,
                  loadingBuilder: (context, event) => _imageLoader(event),
                ),
                StreamBuilder<int>(
                    stream: listener.stream,
                    builder: (context, snapshot) {
                      var imageIndex = snapshot.data ?? 0;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          imageButtons(urlList[imageIndex], context),
                          _pageIndicator(imageIndex, urlList),
                        ],
                      );
                    }),
              ],
            ));
      });
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
