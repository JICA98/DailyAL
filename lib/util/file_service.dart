import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// To save the file in the device
class FileStorage {
  static Future<String> getExternalDocumentPath() async {
    Directory _directory;
    
    if (Platform.isAndroid) {
      // Android: Check storage permissions and use Download folder
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      _directory = Directory("/storage/emulated/0/Download");
    } else {
      // Desktop platforms (Linux, macOS, Windows) and iOS: use app documents directory
      // This works generically across all desktop platforms
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
    // final directory = await getApplicationDocumentsDirectory();
    // return directory.path;
    // To get the external path from device of download folder
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  static Future<File> writeFile(String bytes, String name) async {
    final path = await _localPath;
    // Create a file for the path of
    // device and file name with extension
    File file = File('$path/$name');
    print("Save file");

    // Write the data in the file you have created
    return file.writeAsString(bytes);
  }
}
