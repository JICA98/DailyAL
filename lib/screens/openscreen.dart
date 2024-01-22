import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/homescreen.dart';
import 'package:dailyanimelist/screens/intro/introscreen.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

class OpenScreen extends StatefulWidget {
  final Node? notifNode;
  final Widget? loadWidget;
  const OpenScreen({Key? key, this.notifNode, this.loadWidget})
      : super(key: key);

  @override
  State<OpenScreen> createState() => _OpenScreenState();
}

class _OpenScreenState extends State<OpenScreen> {
  late Future<User> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = user.runPostInitialization();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setUIStyle(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CFutureBuilder<User>(
      future: userFuture,
      done: (sp) {
        user = sp.data!;
        return Directionality(
          textDirection:
              user.pref.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: user.pref.firstTime
              ? (widget.loadWidget ?? IntroScreen())
              : HomeScreen(
                  notifNode: widget.notifNode,
                  loadWidget: widget.loadWidget,
                ),
        );
      },
      loadingChild: loadingStartup,
    );
  }
}
