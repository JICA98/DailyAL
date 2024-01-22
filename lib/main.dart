import 'dart:io';

import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/notifservice.dart';
import 'package:dailyanimelist/screens/homescreen.dart';
import 'package:dailyanimelist/screens/openscreen.dart';
import 'package:dailyanimelist/theme/theme.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/error/error_reporting.dart';
import 'package:dailyanimelist/util/pathutils.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dal_api/dal_local_api.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:restart_app/restart_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

/// Global UserData
late User user;
int androidSDKVersion = 0;
final int homeIndex = 0;
final int forumIndex = 1;
final int userIndex = 2;
final int profileIndex = 3;
final int exploreIndex = 4;
GlobalKey<ScaffoldMessengerState> messenger = GlobalKey();

void main() async {
  try {
    // Universal Log Config for DailyAL
    dalLogConfig.debugMode = kDebugMode;
    Environment.i.malClientId = CredMal.clientId;
    WidgetsFlutterBinding.ensureInitialized();
    ErrorReporting.init();
    await StreamUtils.i.init();
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    androidSDKVersion = androidInfo.version.sdkInt;
    await _initSupabase();
  } catch (e) {}

  Node? node;
  if (!kIsWeb && Platform.isAndroid) {
    await NotificationService().init();
    node = await NotificationService().onSelectWhileAsleep();
    try {
      await DalLocalApi.i.runApp();
    } catch (e) {}
  }

  runApp(_buildProvider(node));
}

Future<void> _initSupabase() async {
  await supa.Supabase.initialize(
    url: CredMal.supabaseUrl,
    anonKey: CredMal.supabaseKey,
  );
}

void restartApp() {
  Restart.restartApp();
}

MultiProvider _buildProvider(Node? node) {
  return MultiProvider(
    providers: [ChangeNotifierProvider<User?>(create: (_) => null)],
    child: RestartApp(
      child: MyApp(
        notifNode: node,
      ),
    ),
  );
}

class RestartApp extends StatefulWidget {
  RestartApp({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartAppState>()!.restartApp();
  }

  @override
  _RestartAppState createState() => _RestartAppState();
}

class _RestartAppState extends State<RestartApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  void dispose() {
    super.dispose();
    StreamUtils.i.close();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

class MyApp extends StatelessWidget {
  final Node? notifNode;

  const MyApp({Key? key, this.notifNode}) : super(key: key);
  static GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");

  @override
  Widget build(BuildContext context) {
    return StateFullFutureWidget<User>(
        future: () => User.getInstance(),
        loadingChild: loadingStartup,
        done: (snap) {
          user = snap.data!;
          return DynamicColorBuilder(
              builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            final colorScheme =
                currentColorScheme(context, lightDynamic, darkDynamic);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              scaffoldMessengerKey: messenger,
              home: OpenScreen(notifNode: notifNode),
              themeMode: user.theme.themeMode == UserThemeMode.Auto
                  ? ThemeMode.system
                  : (user.theme.themeMode == UserThemeMode.Dark
                      ? ThemeMode.dark
                      : ThemeMode.light),
              darkTheme: ThemeData(
                colorScheme: colorScheme,
                useMaterial3: true,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
              theme: ThemeData(
                colorScheme: colorScheme,
                useMaterial3: true,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
              title: 'DailyAL',
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                S.delegate,
              ],
              locale: Locale.fromSubtags(languageCode: "en_US"),
              supportedLocales: S.delegate.supportedLocales,
              onGenerateRoute: (route) {
                // Handle '/'
                if (route.name == '/') {
                  return MaterialPageRoute(
                      builder: (context) => OpenScreen(
                          loadWidget: HomeScreen(pageIndex: 0),
                          notifNode: notifNode));
                }
                var fromExistingScreen = false;
                try {
                  fromExistingScreen =
                      ((route.arguments as List?)?.firstOrNull) ?? false;
                } catch (e) {}
                return MaterialPageRoute(
                  builder: (context) => CFutureBuilder(
                    future: DalPathUtils.handleUri(
                      Uri.tryParse(route.name ?? ''),
                    ),
                    done: (snapshot) => fromExistingScreen
                        ? snapshot.data
                        : OpenScreen(
                            loadWidget: snapshot.data,
                          ),
                    loadingChild: loadingStartup,
                  ),
                );
              },
            );
          });
        });
  }
}
