import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// Events emitted by the Linux Tray for the UI to consume.
enum LinuxTrayEvent { search, userList, calendar, home }

/// [LinuxDesktopHelper] handles all native integrations for the Linux platform.
/// 
/// It uses a Singleton pattern and acts as a bridge between the system (Tray, Window Manager)
/// and the Flutter UI via the [onNavigationEvent] stream.
///
/// ### Expansion Guide:
/// 1. **To add a new Tray Menu option:**
///    - Add a new [MenuItem] in [_initTray] with a unique key (usually starting with `nav_`).
///    - Handle the key in [onTrayMenuItemClick].
///    - (Optional) Add a new value to [LinuxTrayEvent] if UI navigation is needed.
/// 2. **To add new Window behaviors:**
///    - Modify [_initWindowManager] or add methods to [_LinuxWindowListener].
class LinuxDesktopHelper extends TrayListener {
  static bool _hasLibNotify = true;
  static bool _trayInitialized = false;

  /// Returns true if 'notify-send' is available on the path.
  static bool get hasLibNotify => _hasLibNotify;

  static String? _appIconPath;
  /// The absolute path to the extracted app logo on the disk.
  static String? get appIconPath => _appIconPath;

  // Stream used to signal navigation changes to the HomeScreen.
  static final StreamController<LinuxTrayEvent> _navController = 
      StreamController<LinuxTrayEvent>.broadcast();
  static Stream<LinuxTrayEvent> get onNavigationEvent => _navController.stream;

  static final LinuxDesktopHelper _instance = LinuxDesktopHelper._internal();
  LinuxDesktopHelper._internal();

  /// Main entry point for Linux initialization. Called from main.dart.
  static Future<void> init() async {
    if (!Platform.isLinux || kIsWeb) return;

    try {
      await _initTimezone();
      await _checkDependencies();
      await _initWindowManager();
      await _instance._initTray();
      await _extractAppIcon(); // Extract logo for system notifications
      print('DEBUG: Linux Desktop Helper initialized successfully');
    } catch (e) {
      print('ERROR: Failed to initialize Linux Desktop Helper: $e');
    }
  }

  /// Extracts the app asset logo to a temporary directory.
  /// Standard Linux notifications (libnotify) require an absolute file path to display icons.
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

  /// Configures window behavior: always-alive (minimize instead of close).
  static Future<void> _initWindowManager() async {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setPreventClose(true); // Don't kill process on [X]
      await windowManager.show();
      await windowManager.focus();
    });
    windowManager.addListener(_LinuxWindowListener());
  }

  /// Initializes the system tray icon and its context menu.
  Future<void> _initTray() async {
    try {
      // Logic to find the correct icon path depending on build mode.
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
      _trayInitialized = true;
    } catch (e) {
      _trayInitialized = false;
      print('WARNING: Tray initialization failed. Missing libayatana-appindicator? : $e');
    }
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu(); // Show right-click menu
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
      // Handle navigation shortcuts
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

  /// Fixes a common crash on Linux where the timezone is not automatically detected.
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

  /// Checks if required system binaries are present.
  static Future<void> _checkDependencies() async {
    try {
      final result = await Process.run('which', ['notify-send']);
      _hasLibNotify = result.exitCode == 0;
    } catch (e) {
      _hasLibNotify = false;
    }
  }

  /// Displays a toast if critical system libraries are missing in Linux.
  /// Package names provided are for Debian-based systems (Pop!_OS, Ubuntu).
  static void showMissingDependencyNotice() {
    if (Platform.isLinux) {
      List<String> missingPackages = [];

      if (!_hasLibNotify) {
        missingPackages.add('libnotify-bin');
      }

      if (!_trayInitialized) {
        missingPackages.add('libayatana-appindicator3-dev');
        missingPackages.add('libdbusmenu-gtk3-dev');
      }

      if (missingPackages.isNotEmpty) {
        final String packageList = missingPackages.join(', ');
        showToast(
            'System Notice: Please install "$packageList" to enable all desktop features (Tray & Notifications).');
      }
    }
  }
}

/// Listener to handle window-level events like closing the window.
class _LinuxWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      // Instead of closing, we just hide it (Always-alive behavior)
      await windowManager.hide();
    }
  }
}
