import 'dart:async';
import 'dart:io';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

enum LinuxTrayEvent { search, userList, calendar, home }

class LinuxDesktopHelper extends TrayListener {
  static bool _hasLibNotify = true;
  static bool get hasLibNotify => _hasLibNotify;
  
  static String? _appIconPath;
  static String? get appIconPath => _appIconPath;

  static final StreamController<LinuxTrayEvent> _navController = 
      StreamController<LinuxTrayEvent>.broadcast();
  static Stream<LinuxTrayEvent> get onNavigationEvent => _navController.stream;

  static final LinuxDesktopHelper _instance = LinuxDesktopHelper._internal();
  LinuxDesktopHelper._internal();

  static Future<void> init() async {
    if (!Platform.isLinux || kIsWeb) return;

    try {
      await _initTimezone();
      await _checkDependencies();
      await _initWindowManager();
      await _instance._initTray();
      await _extractAppIcon();
      print('DEBUG: Linux Desktop Helper initialized successfully');
    } catch (e) {
      print('ERROR: Failed to initialize Linux Desktop Helper: $e');
    }
  }

  static Future<void> _extractAppIcon() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/dal-black-bg.png');
      final List<int> bytes = data.buffer.asUint8List();
      final String tempPath = '${Directory.systemTemp.path}/dailyanimelist_icon.png';
      final File file = File(tempPath);
      await file.writeAsBytes(bytes);
      _appIconPath = tempPath;
      print('DEBUG: Extracted app icon to: $tempPath');
    } catch (e) {
      print('WARNING: Could not extract app icon: $e');
    }
  }

  static Future<void> _initWindowManager() async {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setPreventClose(true);
      await windowManager.show();
      await windowManager.focus();
    });
    windowManager.addListener(_LinuxWindowListener());
  }

  Future<void> _initTray() async {
    String iconPath = Platform.resolvedExecutable.contains('debug')
        ? 'assets/images/dal-black-bg.png'
        : 'data/flutter_assets/assets/images/dal-black-bg.png';

    await trayManager.setIcon(iconPath);
    
    List<MenuItem> items = [
      MenuItem(
        key: 'show_window',
        label: 'Show DailyAL',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'nav_search',
        label: '🔍 Search Anime',
      ),
      MenuItem(
        key: 'nav_list',
        label: '📋 My List',
      ),
      MenuItem(
        key: 'nav_calendar',
        label: '📅 Calendar',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'hide_window',
        label: 'Hide to Tray',
      ),
      MenuItem(
        key: 'exit_app',
        label: 'Exit',
      ),
    ];
    await trayManager.setContextMenu(Menu(items: items));
    trayManager.addListener(this);
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      await windowManager.show();
      await windowManager.focus();
    } else if (menuItem.key == 'hide_window') {
      await windowManager.hide();
    } else if (menuItem.key == 'exit_app') {
      exit(0);
    } else if (menuItem.key?.startsWith('nav_') ?? false) {
      await windowManager.show();
      await windowManager.focus();

      switch (menuItem.key) {
        case 'nav_search':
          _navController.add(LinuxTrayEvent.search);
          break;
        case 'nav_list':
          _navController.add(LinuxTrayEvent.userList);
          break;
        case 'nav_calendar':
          _navController.add(LinuxTrayEvent.calendar);
          break;
      }
    }
  }

  static Future<void> _initTimezone() async {
    tz.initializeTimeZones();
    try {
      final String timeZoneName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print(
          'WARNING: Could not determine local timezone, defaulting to UTC to avoid crash.');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  static Future<void> _checkDependencies() async {
    try {
      final result = await Process.run('which', ['notify-send']);
      _hasLibNotify = result.exitCode == 0;
    } catch (e) {
      _hasLibNotify = false;
    }
  }

  static void showMissingDependencyNotice() {
    if (Platform.isLinux && !_hasLibNotify) {
      showToast(
          'Aviso: Instala libnotify-bin para recibir notificaciones del sistema.');
    }
  }
}

class _LinuxWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await windowManager.hide();
    }
  }
}
