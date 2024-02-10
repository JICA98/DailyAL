import 'package:dailyanimelist/api/auth/auth.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

import '../../constant.dart';
import '../../main.dart';

class SigninWidget extends StatefulWidget {
  final bool isIntro;
  final VoidCallback? update;
  const SigninWidget({Key? key, this.isIntro = false, this.update})
      : super(key: key);

  @override
  _SigninWidgetState createState() => _SigninWidgetState();
}

class _SigninWidgetState extends State<SigninWidget> {
  late AuthStatus previousStatus;
  UserProf? _userProf;
  bool hasError = false;
  @override
  void initState() {
    super.initState();
    previousStatus = user.status;
    Future.delayed(Duration.zero).then((value) {
      user.addListener(() {
        if (widget.update != null) {
          widget.update!();
        }
        if (mounted) setState(() {});
        if (widget.isIntro &&
            user.status != previousStatus &&
            user.status == AuthStatus.AUTHENTICATED) {
          getUserData();
        }
      });
    });
    if (user.status == AuthStatus.AUTHENTICATED && widget.isIntro) {
      getUserData();
    }
  }

  getUserData() async {
    try {
      _userProf = await MalUser.getUserInfo();
    } catch (e) {
      hasError = true;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];
    if (user.status == AuthStatus.AUTHENTICATED && widget.isIntro) {
      if (_userProf == null) {
        widgets = [
          Container(
            child: Center(
              child: loadingCenter(),
            ),
          ),
          SB.h20,
          textWidget(S.current.Loading_Profile)
        ];
      } else {
        widgets = [
          AvatarWidget(
            url: _userProf?.picture,
            radius: BorderRadius.circular(50),
            height: 100,
            width: 100,
          ),
          SB.h20,
          textWidget(hasError
              ? S.current.Logged_In
              : '${S.current.Logged_In_as} ${_userProf?.name}'),
        ];
      }
    } else {
      widgets = [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage:
                        AssetImage("assets/images/dal-black-bg.png"),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  width: 80,
                  height: 80,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/images/mal-icon.png"),
                  ),
                )
              ],
            )),
        const SizedBox(
          height: 40,
        ),
        textWidget(signInText),
        const SizedBox(
          height: 30,
        ),
        // user.status == AuthStatus.INPROGRESS
        //     ? Container(
        //         child: Center(
        //           child: loadingCenter(),
        //         ),
        //       )
        //     : user.status == AuthStatus.UNAUTHENTICATED
        //         ?
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          height: 45,
          child: PlainButton(
            onPressed: () async {
              MalAuth.handleSignIn();
              Future.delayed(Duration(seconds: 45)).then((value) {
                if (user.status != AuthStatus.AUTHENTICATED) {
                  logDal("timed out");
                  showToast(S.current.Setup_timed_out);
                  if (mounted)
                    setState(() {
                      user.status = AuthStatus.UNAUTHENTICATED;
                    });
                } else {
                  if (mounted) setState(() {});
                }
              });
            },
            // elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            child: Text(
              S.current.Tap_to_Sign_In,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15),
            ),
          ),
        )
        // : SB.z
      ];
    }

    return Center(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widgets,
          )
        ],
      ),
    );
  }

  Widget textWidget(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15),
    );
  }

  String get signInText => user.status == AuthStatus.INPROGRESS
      ? S.current.Account_fetch_details
      : user.status == AuthStatus.AUTHENTICATED
          ? S.current.Logged_In
          : S.current.Sign_in_Suggestions;
}
