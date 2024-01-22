import 'dart:io';

import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/settings/customsettings.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/file_service.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BackUpAndRestorePage extends StatefulWidget {
  const BackUpAndRestorePage({super.key});

  @override
  State<BackUpAndRestorePage> createState() => _BackUpAndRestorePageState();
}

class _BackUpAndRestorePageState extends State<BackUpAndRestorePage> {
  final version = 1;
  final dateFormat = DateFormat('dd_MM_yyyy_HH_mm_ss_sss');
  Future<void> _backUp() async {
    final data = await CacheManager.instance.getBackUpData();
    final name =
        'V_${version}_DailyAL_${dateFormat.format(DateTime.now())}.json';
    final result = await showConfirmationDialog(
      context: context,
      alertTitle: S.current.Backup_Confirmation,
      desc: S.current.Backup_Confirmation_Desc,
      addtionalActions: [],
    );
    if (result) {
      await FileStorage.writeFile(data, name);
      showToast(S.current.BackUpFileSaved);
    }
  }

  Future<void> _restore() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        var path = result.files.single.path;
        if (path != null) {
          File file = File(path);
          final bytes = await file.readAsBytes();
          final data = String.fromCharCodes(bytes);
          final result = await CacheManager.instance.restoreData(data);
          if (result) {
            user = await User.getInstance();
            await user.refreshAuthStatus();
            await StreamUtils.i.init();
            await showToast(S.current.Restore_Sucess);
            restartApp();
          } else {
            showToast(S.current.Restore_fail);
          }
          return;
        }
      }
    } catch (e) {}
    showToast(S.current.Cancelled_Restore);
  }

  @override
  Widget build(BuildContext context) {
    return SettingSliverScreen(
      titleString: S.current.Backup_And_Restore,
      children: [
        SliverList.list(
          children: [
            OptionTile(
              text: S.current.Backup,
              desc: S.current.Backup_Desc,
              trailing: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.backup),
              ),
              onPressed: _backUp,
            ),
            OptionTile(
              text: S.current.Restore,
              desc: S.current.Restore_desc,
              trailing: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.restore),
              ),
              onPressed: _restore,
            ),
          ],
        ),
      ],
    );
  }
}
