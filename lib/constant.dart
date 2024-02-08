import 'dart:ui' as ui;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/animedetailed/videoswidget.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/homescreen.dart';
import 'package:dailyanimelist/screens/user_profile.dart';
import 'package:dailyanimelist/theme/theme.dart';
import 'package:dailyanimelist/theme/themedata.dart';
import 'package:dailyanimelist/util/pathutils.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/forum/bbcodewidget.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/contenteditwidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

/// SizedBOX & Sliver SizedBox
class SB {
  /// const SizedBox(height: 5)
  static const h5 = const SizedBox(height: 5);

  /// const SizedBox(height: 10)
  static const h10 = const SizedBox(height: 10);

  /// const SizedBox(height: 15)
  static var h15 = const SizedBox(height: 15);

  /// const SizedBox(height: 20)
  static const h20 = const SizedBox(height: 20);

  /// const SizedBox(height: 30)
  static const h30 = const SizedBox(height: 30);
  static const h35 = const SizedBox(height: 35);

  /// const SizedBox(height: 40)
  static const h40 = const SizedBox(height: 40);

  /// const SizedBox(height: 60)
  static const h60 = const SizedBox(height: 60);

  /// const SizedBox(height: 80)
  static const h80 = const SizedBox(height: 80);

  /// const SizedBox()
  static const z = const SizedBox();

  /// const SizedBox(height: 120)
  static const h120 = const SizedBox(height: 120);

  /// const SizedBox(height: 200)
  static const h200 = const SizedBox(height: 200);

  /// const SizedBox(width: 5)
  static const w5 = const SizedBox(width: 5);

  /// const SizedBox(width: 10)
  static const w10 = const SizedBox(width: 10);

  /// const SizedBox(width: 10)
  static const w15 = const SizedBox(width: 15);

  /// const SizedBox(width: 20)
  static const w20 = const SizedBox(width: 20);

  /// const SizedBox(width: 30)
  static const w30 = const SizedBox(width: 30);

  /// const SizedBox(width: 40)
  static const w40 = const SizedBox(width: 40);

  /// const SizedBox(width: 60)
  static const w60 = const SizedBox(width: 60);

  static const lz = const SliverWrapper(z);
  static const lh10 = const SliverWrapper(h10);
  static const lh20 = const SliverWrapper(h20);
  static const lh30 = const SliverWrapper(h30);
  static const lh35 = const SliverWrapper(h35);
  static const lh40 = const SliverWrapper(h40);
  static const lh60 = const SliverWrapper(h60);
  static const lh80 = const SliverWrapper(h80);
  static const lh120 = const SliverWrapper(h120);
  static const lw10 = const SliverWrapper(w10);
  static const lw20 = const SliverWrapper(w20);
  static const lw40 = const SliverWrapper(w40);
  static const lw60 = const SliverWrapper(w60);
}

const strList = <String>[];

RoundedRectangleBorder btnBorder(BuildContext context) =>
    RoundedRectangleBorder(
      side: BorderSide(
        color: Theme.of(context).dividerColor,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(12),
    );

var bgWThemes = ["dark", "black"];
final DateFormat globalDate = new DateFormat('EEE, MMM d, yyyy');
const invalidUserNames = ['MyAnimeList', 'removed-user'];

Widget conditional({
  Key? key,
  required bool on,
  required Widget child,
  required Widget Function(Widget child) parent,
}) {
  if (on) {
    return parent(child);
  } else {
    return child;
  }
}

Widget starField(
  String score, {
  double starHeight = 17.0,
  TextStyle? textStyle,
  bool useIcon = false,
}) {
  return Row(
    children: [
      if (useIcon)
        Icon(
          Icons.star,
          size: starHeight,
        )
      else
        Container(
          height: starHeight,
          child: Image.asset("assets/images/star.png"),
        ),
      const SizedBox(
        width: 5,
      ),
      Text(
        score,
        style: textStyle,
      )
    ],
  );
}

class RankingMap {
  final SearchResult searchResult;
  final RankingType rankingType;
  RankingMap({required this.searchResult, required this.rankingType});
}

class StatusMap {
  final SearchResult searchResult;
  final String contentStatus;
  StatusMap({required this.searchResult, required this.contentStatus});
}

void navigateTo(BuildContext context, Widget screen) {
  gotoPage(context: context, newPage: screen);
}

String convertGenre(MalGenre g, [String category = "anime"]) {
  var genres = category.equals("anime") ? Mal.animeGenres : Mal.mangaGenres;
  var genre = genres[g.id];
  if (genre == null) {
    genre = g.name;
  }
  return genre ?? '?';
}

void onGenrePress(MalGenre e, String category, BuildContext context) {
  final genre = convertGenre(e, category);
  final filter = (category.equals("anime")
      ? CustomFilters.genresAnimeFilter
      : CustomFilters.genresMangaFilter)
    ..includedOptions = [genre];
  gotoPage(
      context: context,
      newPage: GeneralSearchScreen(
        category: category,
        autoFocus: false,
        exclusiveScreen: true,
        filterOutputs: {'genres': filter},
        // searchQuery:
        //     "#${getGenre(e, context, widget.category).standardizeLower()}@${widget.category}",
      ));
}

Widget genresWidget(
    List<MalGenre> genres, String category, BuildContext context,
    {TextAlign textAlign = TextAlign.center}) {
  plainButtonBuild(MalGenre e, [String additional = '']) => PlainButton(
        onPressed: () => onGenrePress(e, category, context),
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        child: Text(
          convertGenre(e, category).replaceAll("_", " "),
          style: TextStyle(fontSize: 12.0),
        ),
      );
  final length = genres.length;
  return RichText(
    textAlign: textAlign,
    text: TextSpan(
        children: genres.asMap().entries.map((e) {
      return TextSpan(
        children: [
          WidgetSpan(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: plainButtonBuild(e.value),
          )),
          if (length != (e.key + 1))
            WidgetSpan(
              child: SizedBox(
                width: 10.0,
                child: PlainButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  child: Text('·'),
                ),
              ),
            ),
        ],
      );
    }).toList()),
  );
}

void setUIStyle(BuildContext context) {
  final brightness = currentBrightness(context);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarIconBrightness: brightness,
  ));
}

String getUserImage(int id) {
  return CredMal.userImageEndPoint + "$id.jpg";
}

String getUserAvatar(int id) {
  return CredMal.apiUserAvatar + "$id.jpg";
}

Widget cardLoading({
  double radius = 1.0,
  BorderRadius? borderRadius,
  double height = 150,
  double width = 100,
}) {
  return ShimmerColor(Container(
    height: height,
    width: width,
    child: Material(
      borderRadius: borderRadius ?? BorderRadius.circular(radius),
    ),
  ));
}

Color malColor = Color(0xff3052A2);

Widget get loadingCenterColored {
  return loadingCenter();
}

Widget loadingCenter({
  double? width,
  double containerSide = 20,
}) {
  return Center(
    child: Container(
      width: containerSide,
      height: containerSide,
      child: CircularProgressIndicator(
        strokeWidth: width ?? 2,
      ),
    ),
  );
}

Widget loadingText(BuildContext context) {
  final shimmerColors = ShimmerColors.fromContext(context);
  return Padding(
    padding: EdgeInsets.fromLTRB(15, 5, 15, 60),
    child: Shimmer.fromColors(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 200,
              height: 15,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: Theme.of(context).dividerColor),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 160,
              height: 15,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: Theme.of(context).dividerColor),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 300,
              height: 15,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: Theme.of(context).dividerColor),
            )
          ],
        ),
        baseColor: shimmerColors.baseColor,
        highlightColor: shimmerColors.highlightColor),
  );
}

void showSnackBar(Widget content, [Duration? duration]) async {
  messenger.currentState!.showSnackBar(
    SnackBar(
      content: content,
      duration: duration ?? const Duration(seconds: 4),
    ),
  );
}

void showMessage(IconData iconData, String message) {
  showSnackBar(
    Padding(
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: title("$message"),
          ),
        ],
      ),
    ),
  );
}

void showError(String message) {
  showMessage(Icons.error, message);
}

void showInfo(String message) {
  showMessage(Icons.info, message);
}

void showPopup(
    {required BuildContext context, required Widget child, Color? color}) {
  showCupertinoModalPopup(
      context: context,
      builder: (context) => Material(color: color, child: child));
}

void showCustomSheet({
  required BuildContext context,
  required Widget child,
  Color? color,
  bool isScrollControlled = true,
  double elevation = 0,
  bool enableDrag = true,
}) {
  showModalBottomSheet(
    context: context,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    backgroundColor: color,
    builder: (context) => Material(color: color, child: child),
  );
}

String enumToString(Object o) => o.toString().split('.')[1];

List<String> enumList(List<Object> os) =>
    os.map((e) => enumToString(e)).toList();

IconData getFilterIcon(Iterable? list) {
  if (list == null || list.isEmpty) return Icons.filter_alt;
  return filterLengthIcon(list.length);
}

IconData filterLengthIcon(int length) {
  switch (length) {
    case 1:
      return Icons.filter_1;
    case 2:
      return Icons.filter_2;
    case 3:
      return Icons.filter_3;
    case 4:
      return Icons.filter_4;
    case 5:
      return Icons.filter_5;
    case 6:
      return Icons.filter_6;
    case 7:
      return Icons.filter_7;
    case 8:
      return Icons.filter_8;
    case 9:
      return Icons.filter_9;
    default:
      return Icons.filter_9_plus;
  }
}

Widget loadingInner() {
  return Center(
    child: Stack(
      children: [
        Center(
          child: Container(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              strokeWidth: .8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(Color(0xff757575)),
            ),
          ),
        ),
        _logoImage()
      ],
    ),
  );
}

Center _logoImage([double? height = 40.0, double? width = 40.0]) {
  return Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(32.0),
      child: Container(
        height: height,
        width: width,
        child: Image.asset("assets/images/dal-black-bg.png"),
      ),
    ),
  );
}

Widget loadingError() {
  return Center(
    child: Stack(
      children: [
        Center(
          child: Container(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              strokeWidth: .8,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(Color(0xff757575)),
            ),
          ),
        ),
        _logoImage(),
      ],
    ),
  );
}

bool shouldUpdateContent(
    {@required dynamic result, double timeinHoursD = 0, int timeinHours = 0}) {
  try {
    var lastUpdated = result is String
        ? DateTime.parse(result)
        : result is Map
            ? DateTime.parse(result['lastUpdated'])
            : result?.lastUpdated;
    return ((DateTime.now().difference(lastUpdated).inMinutes / 60.0) >=
        (timeinHoursD + timeinHours));
  } catch (e) {
    return false;
  }
}

Future<bool> hasConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi;
}

Future<void> showToast(String message, {Toast? toast}) async {
  await Fluttertoast.showToast(
      gravity: ToastGravity.CENTER,
      msg: message,
      toastLength: toast,
      backgroundColor: Colors.black,
      textColor: Colors.white);
}

Widget showErrorImage() {
  return AvatarWidget(
    url: 'assets/images/error_image.png',
    isNetworkImage: false,
  );
}

bool hasText(String? text) {
  if (text == null) return false;
  return text.isNotBlank;
}

Future<bool> showConfirmationDialog({
  String alertTitle = "",
  String desc = "",
  required BuildContext context,
  List<Widget>? addtionalActions,
}) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title(alertTitle, opacity: 1, fontSize: 14),
      content: title(desc, opacity: 1, fontSize: 14),
      actions: addtionalActions == null
          ? _yesOrNoButtons(context)
          : [
              ...addtionalActions,
              ..._yesOrNoButtons(context),
            ],
    ),
  );
}

void launchURLWithConfirmation(
  String url, {
  required BuildContext context,
}) async {
  var result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        S.current.Just_a_sec,
      ),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.current.Url_open_conf),
            Text("$url"),
            Text(S.current.Continue),
          ]),
      actions: [
        PlainButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
            Navigator.of(context, rootNavigator: true).pop(false);
          },
          child: Text(S.current.Copy),
        ),
        ..._yesOrNoButtons(context)
      ],
    ),
  );
  if (result ?? false) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.isNotBlank) {
      launchURL(url);
    } else {
      final widget = await DalPathUtils.handleUri(uri, context);
      if (widget != null) {
        gotoPage(context: context, newPage: widget);
      }
    }
  }
}

List<Widget> _yesOrNoButtons(BuildContext context) {
  return [
    PlainButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(false); // dismisses only the dialog and returns false
      },
      child: Text(S.current.No),
    ),
    ShadowButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(true); // dismisses only the dialog and returns true
      },
      child: Text(S.current.Yes),
    ),
  ];
}

void launchLogOutConfirmation({required BuildContext context}) async {
  var result = await showConfirmationDialog(
      context: context,
      alertTitle: S.current.Logout_Confirmation,
      desc: S.current.Do_you_wish_to_logout);
  if (result) {
    try {
      await MalAuth.signOut();
      restartApp();
    } catch (e) {
      logDal(e);
      showToast(S.current.Couldnt_sign_out_now);
    }
  }
}

enum ReportType { forummessage, profile, recommendation }

void reportWithConfirmation({
  required ReportType type,
  required BuildContext context,
  required Widget content,
  Map<String, dynamic>? queryParams,
  String? optionalUrl,
}) async {
  final url = optionalUrl ??
      '${CredMal.htmlEnd}modules.php?go=report&type=${type.name}&${buildQueryParams(queryParams ?? {})}';
  var result = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(S.current.Report_Confirmation),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          SB.h20,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: title(S.current.Report_Description),
          ),
        ],
      ),
      actions: [
        PlainButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true)
                .pop(false); // dismisses only the dialog and returns false
          },
          child: Text(S.current.Cancel),
        ),
        ShadowButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true)
                .pop(true); // dismisses only the dialog and returns true
          },
          child: Text(S.current.ContinueW),
        ),
      ],
    ),
  );
  if (result) {
    launchURL(url);
  }
}

List<Widget> alertDefaultButtons(
  BuildContext context, {
  String? yesText,
  String? noText,
}) {
  return [
    PlainButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(false); // dismisses only the dialog and returns false
      },
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(noText ?? S.current.Cancel),
    ),
    ShadowButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(true); // dismisses only the dialog and returns true
      },
      child: Text(yesText ?? S.current.ContinueW),
    ),
  ];
}

Widget alertButton(BuildContext context, String text) {
  return PlainButton(
    onPressed: () {
      Navigator.of(context, rootNavigator: true)
          .pop(true); // dismisses only the dialog and returns true
    },
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    child: Text(text),
  );
}

Future<bool> openAlertDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  Widget? additionalAction,
  bool useDefaultBtns = true,
  bool useCloseBtn = false,
  String? yesText,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsets? insetPadding,
  String? noText,
}) async {
  return await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      contentPadding: contentPadding,
      content: content,
      insetPadding: insetPadding ??
          EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      actions: [
        if (additionalAction != null) additionalAction,
        if (useDefaultBtns)
          ...alertDefaultButtons(
            context,
            noText: noText,
            yesText: yesText,
          )
        else if (useCloseBtn)
          alertButton(context, S.current.Close)
      ],
    ),
  );
}

Widget backdropFilter(Widget child) {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
    child: child,
  );
}

Widget get loadingStartup {
  return Container(
    color: Color(0xFF02001B),
    child: _logoImage(120, 120),
  );
}

Widget wrapScrollTag({
  required int index,
  required Widget child,
  required AutoScrollController controller,
  Color? highlightColor,
}) {
  return AutoScrollTag(
      key: ValueKey(index),
      controller: controller,
      index: index,
      child: child,
      highlightColor: highlightColor);
}

void launchURL(String url) async {
  try {
    await launch(url);
  } catch (e) {
    showToast("${S.current.Couldn_Launch} $url!");
  }
}

Widget iconAndText(
  IconData iconData,
  String? text, {
  double width = 10.0,
  double fontSize = 13,
  int? colorVal,
  int? iconColorVal,
  double iconSize = 16,
  bool reverse = false,
  FontStyle? fontStyle = FontStyle.normal,
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  MainAxisSize mainAxisSize = MainAxisSize.max,
  TextOverflow? overflow,
}) {
  final iconColor = iconColorVal ?? colorVal;
  var content = [
    Icon(
      iconData,
      size: iconSize,
      color: iconColor == null ? null : Color(iconColor),
    ),
    SizedBox(
      width: width,
    ),
    Text(
      text ?? '',
      style: TextStyle(
        fontSize: fontSize,
        color: colorVal == null ? null : Color(colorVal),
        fontStyle: fontStyle,
        overflow: overflow,
      ),
      textAlign: TextAlign.start,
    )
  ];
  if (reverse) {
    content = content.reversed.toList();
  }
  return Row(
    mainAxisAlignment: mainAxisAlignment,
    // alignment: WrapAlignment.center,
    mainAxisSize: mainAxisSize,
    children: content,
  );
}

Widget loadingBelowText({
  String? text,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
}) {
  if (text == null) {
    text = S.current.Loading_Content;
  }
  return Column(
    mainAxisAlignment: mainAxisAlignment,
    children: [
      loadingCenterColored,
      const SizedBox(height: 20),
      Padding(
        padding: padding,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13),
        ),
      ),
    ],
  );
}

Brightness currentBrightness(BuildContext context, [UserThemeMode? themeMode]) {
  return switch (themeMode ?? user.theme.themeMode) {
    UserThemeMode.Auto => MediaQuery.of(context).platformBrightness,
    UserThemeMode.Dark => Brightness.dark,
    UserThemeMode.Black => Brightness.dark,
    UserThemeMode.Light => Brightness.light,
  };
}

ColorScheme? currentColorScheme(
  BuildContext context,
  ColorScheme? lightDynamic,
  ColorScheme? darkDynamic, [
  UserThemeMode? themeMode,
]) {
  final ColorScheme? colorScheme;
  final color = UserThemeData.colorSchemeMap[user.theme.color];
  if (color != null) {
    colorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: currentBrightness(context, themeMode),
    );
  } else {
    final brightness = currentBrightness(context, themeMode);
    if (brightness == Brightness.dark) {
      colorScheme = darkDynamic;
    } else {
      colorScheme = lightDynamic;
    }
  }
  return _blackTheme(colorScheme, themeMode);
}

ColorScheme? _blackTheme(
  ColorScheme? colorScheme, [
  UserThemeMode? themeMode,
]) {
  if (themeMode != UserThemeMode.Black) {
    return colorScheme;
  } else {
    return colorScheme?.copyWith(
      background: Color(0xff0C0404),
      surface: Color(0xff0C0404),
      onBackground: Color(0xffFFFFFF),
      onSurface: Color(0xffFFFFFF),
    );
  }
}

Widget showNoContent({
  String? text,
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
}) {
  if (text == null) {
    text = S.current.No_Content;
  }
  return Column(
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    children: [
      const SizedBox(height: 20),
      Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13),
      ),
      const SizedBox(height: 20),
    ],
  );
}

Widget showNoContentSliver() {
  return SliverList(
    delegate: SliverChildListDelegate(
      [
        const SizedBox(height: 20),
        Text(
          S.current.No_Content,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13),
        ),
      ],
    ),
  );
}

Widget showEmptySliverWidget() {
  return SliverList(
    delegate: SliverChildListDelegate([]),
  );
}

Widget title(
  String? title, {
  double fontSize = 13,
  double opacity = 1,
  int? colorVal,
  TextOverflow? textOverflow,
  TextStyle? textStyle,
  FontStyle? fontStyle = FontStyle.normal,
  TextAlign? align = TextAlign.left,
  FontWeight? fontWeight = FontWeight.normal,
  bool selectable = false,
  double? scaleFactor,
}) {
  title = title ?? '';
  textStyle ??= TextStyle();
  if (selectable) {
    return SelectableText(
      title,
      textAlign: align,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: colorVal == null ? null : Color(colorVal).withOpacity(opacity),
      ),
    );
  } else {
    return Text(
      title,
      // overflow: TextOverflow.ellipsis,
      overflow: textOverflow,
      textAlign: align,
      textScaleFactor: scaleFactor,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: colorVal == null ? null : Color(colorVal).withOpacity(opacity),
      ),
    );
  }
}

Widget text(String? title, {double? fontSize}) {
  return Text(
    title ?? "",
    style: TextStyle(fontSize: fontSize ?? 16),
  );
}

Widget heading(String text,
    {double fontSize = 32, AlignmentGeometry alignment = Alignment.topLeft}) {
  return Container(
    alignment: alignment,
    padding: EdgeInsets.only(left: 20),
    child: title(text, opacity: 1, fontSize: fontSize),
  );
}

Future<dynamic> showContentEditSheet(
  BuildContext context,
  String category,
  dynamic content, {
  ValueChanged<bool>? onUpdate,
  bool updateCache = false,
  VoidCallback? onDelete,
  ValueChanged<dynamic>? onListStatusChange,
}) {
  return showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AnimatedPadding(
            padding: MediaQuery.of(context).viewInsets,
            duration: const Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: ContentEditWidget(
              category: category,
              showAdditional: true,
              contentDetailed: content,
              isCacheRefreshed: true,
              updateCache: updateCache,
              onDelete: () {
                if (onDelete != null) onDelete();
              },
              onListStatusChange: (status) {
                if (onListStatusChange != null) onListStatusChange(status);
              },
              onUpdate: (value) {
                if (onUpdate != null) onUpdate(value);
              },
            ),
          ));
}

Widget longButton({required Function onPressed, String? text}) {
  if (text == null) {
    text = S.current.Load_More;
  }
  return Container(
    width: double.infinity,
    height: 40,
    padding: EdgeInsets.symmetric(horizontal: 15),
    child: PlainButton(
      onPressed: () => onPressed(),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: Center(
        child: Text(
          text,
          // overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

Widget personAndDate({String? text, String? date, bool isDate = true}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      iconAndText(Icons.person_outline, text),
      const SizedBox(
        height: 5,
      ),
      iconAndText(isDate ? Icons.date_range : Icons.access_time, date)
    ],
  );
}

Future<T?> gotoPage<T>(
    {required BuildContext context, required Widget newPage}) {
  return Navigator.push<T>(
    context,
    new MaterialPageRoute(
      builder: (context) => Directionality(
          textDirection:
              user.pref.isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: newPage),
    ),
  );
}

gotoAuthPage() {
  MyApp.navigatorKey.currentState!.push(
    MaterialPageRoute(
      builder: (_) => Directionality(
        textDirection:
            user.pref.isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: HomeScreen(
          pageIndex: userIndex,
        ),
      ),
    ),
  );
}

void showUserPage({required BuildContext context, required String username}) {
  gotoPage(
    context: context,
    newPage: UserProfilePage(
      username: username,
      isSelf: false,
    ),
  );
}

class HtmlW extends StatefulWidget {
  final String? data;
  final bool useImageRenderer;
  const HtmlW({Key? key, this.data, this.useImageRenderer = false})
      : super(key: key);

  @override
  State<HtmlW> createState() => _HtmlWState();
}

class _HtmlWState extends State<HtmlW> {
  late dom.Document document;

  @override
  void initState() {
    super.initState();
    document = dom.Document.html(widget.data ?? '');
    document.querySelectorAll('.spoiler').forEach((spoiler) {
      final div = document.createElement('spoiler');
      final input = spoiler.querySelector('input');
      final content = spoiler.querySelector('.spoiler_content');
      if (input != null && content != null) {
        content.attributes['style'] = '';
        div.attributes['name'] =
            input.attributes['value'] ?? S.current.Show_Spoiler;
        spoiler.reparentChildren(div);
        spoiler.replaceWith(div);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Html.fromDom(
      document: document,
      style: {
        "body": Style(
          fontSize: FontSize.medium,
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
        ),
        "a": Style(color: Theme.of(context).textTheme.bodyMedium?.color),
        "hr": Style(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
      },
      onLinkTap: (url, _, __) => onLinkTap(url, context),
      onAnchorTap: (url, _, __) => onLinkTap(url, context),
      extensions: commonExtensions(context, widget.useImageRenderer),
    );
  }
}

void onLinkTap(String? url, BuildContext context) {
  logDal(url);
  if (url != null) {
    try {
      Uri uri = Uri.parse(url);
      if (uri.host.equals('www.youtube.com')) {
        showYouTubeVideo(url: url, context: context);
        return;
      }
    } catch (e) {}
    launchURLWithConfirmation(url, context: context);
  }
}

List<HtmlExtension> commonExtensions(BuildContext context,
    [bool useImageRenderer = true]) {
  return [
    TagExtension(
        tagsToExtend: {'iframe'}, builder: (c) => iframeWidget(c, context)),
    TagExtension(
        tagsToExtend: {'spoiler'}, builder: (c) => _spoilerWidget(c, context)),
    if (useImageRenderer)
      TagExtension(
          tagsToExtend: {'img'},
          builder: (c) => onHtmlImageBuilder(c, context)),
  ];
}

Widget _spoilerWidget(ExtensionContext c, BuildContext context) {
  final attributes = c.attributes;
  final innerHtml = c.element?.innerHtml;
  return Padding(
    padding: EdgeInsets.only(top: 5, bottom: 5),
    child: PlainButton(
        child: Text(
          attributes['name'] ?? S.current.Show_Spoiler,
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 300),
                    child: Material(
                      child: SingleChildScrollView(
                        child: BbcodeWidget(
                          shrinkWrap: false,
                          alignCenter:
                              (innerHtml ?? "").length > 1000 ? false : true,
                          body: "<div> $innerHtml </div>",
                        ),
                      ),
                    ),
                  ));
        }),
  );
}

Widget onHtmlImageBuilder(ExtensionContext rc, BuildContext context) {
  final url = rc.attributes["src"] ?? "";
  return ConstrainedBox(
    constraints: BoxConstraints(maxHeight: 300.0),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () => zoomInImage(context, url),
            child: CachedNetworkImage(imageUrl: url),
          ))
        ],
      ),
    ),
  );
}

Widget iframeWidget(ExtensionContext rc, BuildContext context) {
  final url = rc.attributes["src"] ?? "";
  if (url.isNotBlank) {
    return GestureDetector(
      onTap: () => launchURLWithConfirmation(url, context: context),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: title(url),
      ),
    );
  } else {
    return SB.z;
  }
}

extension DateTimeExtension on DateTime {
  DateTime nextDateTime(int day) {
    return this.add(
      Duration(
        days: (day - this.weekday) % DateTime.daysPerWeek,
      ),
    );
  }

  DateTime nextDate(int day) {
    return DateFormat("yyyy-MM-dd")
        .parse(DateFormat("yyyy-MM-dd").format(this.nextDateTime(day)));
  }
}

String displayTimeAgo(DateTime date, {bool numericDates = true}) {
  final date2 = DateTime.now();
  final difference = date2.difference(date);

  if ((difference.inDays / 365).floor() >= 2) {
    return '${(difference.inDays / 365).floor()} ${S.current.years_ago}';
  } else if ((difference.inDays / 365).floor() >= 1) {
    return (numericDates) ? S.current.year_ago : S.current.Last_year;
  } else if ((difference.inDays / 30).floor() >= 2) {
    return '${(difference.inDays / 30).floor()} ${S.current.months_ago}';
  } else if ((difference.inDays / 30).floor() >= 1) {
    return (numericDates) ? S.current.month_ago : S.current.Last_month;
  } else if ((difference.inDays / 7).floor() >= 2) {
    return '${(difference.inDays / 7).floor()}  ${S.current.weeks_ago}';
  } else if ((difference.inDays / 7).floor() >= 1) {
    return (numericDates) ? S.current.week_ago : S.current.Last_week;
  } else if (difference.inDays >= 2) {
    return '${difference.inDays}  ${S.current.days_ago}';
  } else if (difference.inDays >= 1) {
    return (numericDates) ? S.current.day_ago : S.current.Yesterday;
  } else if (difference.inHours >= 2) {
    return '${difference.inHours}  ${S.current.hours_ago}';
  } else if (difference.inHours >= 1) {
    return S.current.hour_ago;
  } else if (difference.inMinutes >= 2) {
    return '${difference.inMinutes}  ${S.current.minutes_ago}';
  } else if (difference.inMinutes >= 1) {
    return S.current.minute_ago;
  } else if (difference.inSeconds >= 3) {
    return '${difference.inSeconds}  ${S.current.seconds_ago}';
  } else {
    return S.current.Just_now;
  }
}

Future<ColorResult> colorPickerDialog(context, dialogSelectColor) async {
  Color selectedColor = dialogSelectColor;
  var _result = await ColorPicker(
    color: dialogSelectColor,
    onColorChanged: (Color color) => selectedColor = color,
    width: 40,
    height: 40,
    borderRadius: 4,
    spacing: 5,
    runSpacing: 5,
    wheelDiameter: 155,
    heading: Text(
      S.current.Select_a_suitable_color,
      style: Theme.of(context).textTheme.bodyMedium,
    ),
    showMaterialName: true,
    showColorName: true,
    showColorCode: false,
    enableShadesSelection: true,
    pickersEnabled: const <ColorPickerType, bool>{
      ColorPickerType.both: false,
      ColorPickerType.primary: false,
      ColorPickerType.accent: false,
      ColorPickerType.bw: false,
      ColorPickerType.custom: false,
      ColorPickerType.wheel: true,
    },
  ).showPickerDialog(
    context,
    constraints:
        const BoxConstraints(minHeight: 220, minWidth: 250, maxWidth: 320),
  );
  return ColorResult(selectedColor, _result);
}

class ColorResult {
  final Color color;
  final bool result;

  ColorResult(this.color, this.result);
}

bool nullOrEmpty(dynamic list) {
  if (list == null) return true;
  if (!(list is List)) return true;
  if (list.isEmpty) return true;
  return false;
}

Future<void> openFutureAndNavigate<T>({
  required String text,
  required Future<T> future,
  required Widget? Function(T) onData,
  required BuildContext context,
  String? customError,
  bool isPopup = false,
}) async {
  showModalBottomSheet(
    context: context,
    builder: (_) => loadingBelowText(text: text),
  );

  try {
    final result = await future;
    if (result == null) throw Error();
    final newPage = onData(result);
    Navigator.pop(context);
    if (newPage != null) {
      if (isPopup) {
        showDialog(context: context, builder: (_) => newPage);
      } else {
        gotoPage(context: context, newPage: newPage);
      }
    }
  } catch (e) {
    logDal(e);
    Navigator.pop(context);
    showToast(customError ?? S.current.Couldnt_connect_network);
  }
}
