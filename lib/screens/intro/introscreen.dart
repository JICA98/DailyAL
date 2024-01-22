import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/pages/settings/langsettings.dart';
import 'package:dailyanimelist/pages/settings/themesettings.dart';
import 'package:dailyanimelist/theme/theme.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/background.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/user/signinpage.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../../constant.dart';
import '../../main.dart';

class IntroScreen extends StatefulWidget {
  final int index;
  final Function(bool)? onRtlChange;
  const IntroScreen({this.onRtlChange, Key? key, this.index = 0}) : super(key: key);
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int pageLength = 4;
  int pageIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageIndex = widget.index;
    pageController = PageController(initialPage: pageIndex);
  }

  void changePage(int index) {
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
    if (mounted)
      setState(() {
        pageIndex = index;
      });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  bool get _showPageNaviagtor => !lastPage;
  bool get lastPage => pageIndex == (pageLength - 1);
  bool get isLoginPage => pageIndex == 1;
  String get _nextButtonText =>
      (isLoginPage && user.status != AuthStatus.AUTHENTICATED)
          ? S.current.Skip
          : S.current.Next;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      final colorScheme =
          currentColorScheme(context, lightDynamic, darkDynamic);
      return Theme(
        data: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
        ),
        child: Scaffold(
          body: Stack(
            children: [
              PageView(
                controller: pageController,
                onPageChanged: (value) {
                  if (mounted)
                    setState(() {
                      pageIndex = value;
                    });
                },
                children: [
                  _page(),
                  _loginPage(),
                  _langPage(),
                  ThemeSettings(isIntroPage: true)
                ],
              ),
              // _skipButton(),
              if (_showPageNaviagtor) _pageNavigator(),
            ],
          ),
        ),
      );
    });
  }

  Widget _loginPage() {
    return SigninWidget(
      isIntro: true,
      update: () {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _langPage() {
    return LanguageSettings(
      isIntroPage: true,
      update: () {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _page() {
    return Stack(
      children: [
        Background(
          isNetworkImage: false,
          context: context,
          forceBg: true,
        ),
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/dal-black-bg.png'),
                radius: 48.0,
              ),
              const SizedBox(
                height: 30,
              ),
              title("DailyAL", opacity: 1, fontSize: 20),
            ],
          ),
        ),
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 2, left: 15, right: 15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 80,
                ),
                title("The Unofficial MyAnimeList App",
                    align: TextAlign.center, opacity: 1, fontSize: 17),
                const SizedBox(
                  height: 30,
                ),
                title(S.current.Intro_line_One, align: TextAlign.center),
                title("- or -", align: TextAlign.center),
                title(S.current.Intro_line_Two, align: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _skipButton() {
    return Container(
      alignment: Alignment.topRight,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
      child: PlainButton(
        onPressed: pageIndex == (pageLength - 1) ? null : () {},
        child: title(S.current.Skip),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13), side: BorderSide.none),
      ),
    );
  }

  Widget _pageNavigator() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Material(
        borderRadius: BorderRadius.circular(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _dots(),
            if (pageIndex == 0)
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5, right: 15),
                child: PlainButton(
                  onPressed: () {
                    changePage(1);
                  },
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: Icon(
                    Icons.arrow_forward_ios,
                  ),
                ),
              ),
            if (pageIndex != 0)
              Expanded(
                child: ButtonBar(
                  buttonPadding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                  children: [
                    PlainButton(
                      onPressed: pageIndex == 0
                          ? null
                          : () {
                              changePage(pageIndex - 1);
                            },
                      child: title(S.current.Previous),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                          side: BorderSide.none),
                    ),
                    PlainButton(
                      onPressed: pageIndex == (pageLength - 1)
                          ? null
                          : () {
                              changePage(pageIndex + 1);
                            },
                      child: title(_nextButtonText),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                          side: BorderSide.none),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 0),
            child: Opacity(
              opacity: 1,
              child: Container(
                  height: 20,
                  width: 100,
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(23)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      for (int index = 0; index < pageLength; ++index)
                        dot(index)
                    ],
                  )),
            ))
      ],
    );
  }

  Widget dot(int index) {
    return AnimatedContainer(
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 200),
      width: pageIndex == index ? 10 : 5,
      height: pageIndex == index ? 10 : 5,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor, shape: BoxShape.circle),
    );
  }
}
