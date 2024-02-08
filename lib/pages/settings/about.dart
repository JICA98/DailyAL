import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/pages/settings/customsettings.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dal_commons/commons.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

String _githubApiLink = 'https://api.github.com/repos/JICA98/DailyAL/releases';
String _githubHtmlLink = 'https://github.com/JICA98/DailyAL/releases';
String _malAgreement = 'https://myanimelist.net/static/apiagreement.html';

Future<String> getCurrentTag() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return '${packageInfo.version}+${packageInfo.buildNumber}';
}

Future<_GithubResponse> getLatestRelease() async {
  final response = await Dio().get('$_githubApiLink/latest');
  final git = _GithubResponse.fromJson(response.data ?? {});
  if (git.tagName == null) {
    throw Exception('Couldnt find release');
  }
  return git;
}

bool isUpdateAvailable(String currentTag, String latestTag) {
  try {
    return int.parse(latestTag.split("+")[1]) >
        int.parse(currentTag.split("+")[1]);
  } catch (e) {}
  return false;
}

Widget showUpdateAvailablePopup(
  _GithubResponse git,
  BuildContext context,
  String tag,
) {
  final hasUpdate = isUpdateAvailable(tag, git.tagName ?? '');
  final changeLog = git.changeLog;
  return AlertDialog(
    title: Text(hasUpdate
        ? S.current.Update_available
        : S.current.No_new_updates),
    content: SingleChildScrollView(
      child: Text(hasUpdate
          ? ('${S.current.Whats_new}\n\n${changeLog ?? ''}')
          : ''),
    ),
    actions: [
      _closeButton(context),
      if (hasUpdate) ...[
        TextButton(
          onPressed: () => launchURLWithConfirmation(
              '$_githubHtmlLink/tag/${git.tagName}',
              context: context),
          child: Text(S.current.Open),
        ),
        ShadowButton(
          onPressed: () => launchURLWithConfirmation(
              '$_githubHtmlLink/download/${git.tagName}/app-release.apk',
              context: context),
          child: Text(S.current.Update),
        ),
      ],
    ],
  );
}

TextButton _closeButton(BuildContext context) {
  return TextButton(
    onPressed: () {
      Navigator.pop(context);
    },
    child: Text(S.current.Close),
  );
}

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String? _tag;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postFirstFrame();
    });
  }

  void _postFirstFrame() async {
    _tag = await getCurrentTag();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingSliverScreen(
      titleString: S.current.About,
      children: _aboutTiles(context),
    );
  }

  List<Widget> _aboutTiles(BuildContext context) {
    return [
      OptionTile(
        text: S.current.Version,
        desc: _tag,
        iconData: Icons.info,
      ),
      OptionTile(
        text: S.current.ChangeLog,
        iconData: Icons.new_releases,
        onPressed: () => _onGetChangeLog(context),
      ),
      OptionTile(
        text: S.current.Check_for_updates,
        iconData: Icons.refresh,
        onPressed: () => _checkForUpdates(context),
      ),
      OptionTile(
        text: S.current.MAL_API_Licence,
        desc: S.current.MAL_API_Licence_Desc,
        iconData: Icons.assignment_rounded,
        onPressed: () => _openMalAgreement(context),
      ),
      CFutureBuilder(
        future: DalApi.i.dalConfigFuture,
        done: (snap) {
          if (snap.data?.storeUrl == null) {
            return SB.z;
          }
          return OptionTile(
            text: S.current.Rate_Review,
            iconData: Icons.rate_review,
            desc: S.current.Rate_Review_desc,
            onPressed: () => launchURLWithConfirmation(
                snap.data?.storeUrl ?? '',
                context: context),
          );
        },
        loadingChild: SB.z,
      ),
      SB.h30,
      _buildSocialButtons(context),
      Row(
        children: [],
      )
    ].map((e) => SliverToBoxAdapter(child: e)).toList();
  }

  Widget _buildSocialButtons(BuildContext context) {
    return CFutureBuilder<Servers?>(
      future: DalApi.i.dalConfigFuture,
      done: (snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialButton(
              'https://github.com/JICA98/DailyAL',
              LineIcons.github,
              context,
            ),
            if (snapshot.data?.discordLink != null)
              _socialButton(
                snapshot.data?.discordLink ?? '',
                LineIcons.discord,
                context,
              ),
            if (snapshot.data?.telegramLink != null)
              _socialButton(
                snapshot.data?.telegramLink ?? '',
                LineIcons.telegram,
                context,
              ),
          ],
        );
      },
      loadingChild: SB.z,
    );
  }

  Widget _socialButton(
    String url,
    IconData icon,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ShadowButton(
        onPressed: () => launchURLWithConfirmation(url, context: context),
        child: Icon(icon),
      ),
    );
  }

  void _openMalAgreement(BuildContext context) {
    openFutureAndNavigate(
      text: S.current.Loading,
      future: Dio().get<String>(_malAgreement),
      isPopup: true,
      onData: (data) {
        return AlertDialog(
          content: SizedBox(
            height: 600,
            width: 400,
            child: SingleChildScrollView(child: HtmlW(data: data.data ?? '?')),
          ),
          actions: [
            _closeButton(context),
            TextButton(
              onPressed: () =>
                  launchURLWithConfirmation(_malAgreement, context: context),
              child: Text(S.current.Open),
            ),
          ],
        );
      },
      context: context,
    );
  }

  void _checkForUpdates(BuildContext context) {
    openFutureAndNavigate(
      text: S.current.Checking_for_updates,
      future: getLatestRelease(),
      isPopup: true,
      onData: (git) {
        return showUpdateAvailablePopup(git, context, _tag ?? '');
      },
      context: context,
      customError: S.current.Couldnt_find_release,
    );
  }

  void _onGetChangeLog(BuildContext context) {
    openFutureAndNavigate(
      text: '${S.current.Loading} ${S.current.ChangeLog}',
      future: Dio().get('$_githubApiLink/tags/$_tag'),
      isPopup: true,
      onData: (data) {
        final response = _GithubResponse.fromJson(data.data ?? {});
        return AlertDialog(
          title: Text(S.current.ChangeLog),
          content: SingleChildScrollView(
            child: Text(response.changeLog ?? ''),
          ),
          actions: [
            _closeButton(context),
          ],
        );
      },
      context: context,
      customError: S.current.Couldnt_find_release,
    );
  }
}

class _GithubResponse {
  final String? changeLog;
  final String? tagName;
  _GithubResponse({
    this.changeLog,
    this.tagName,
  });

  _GithubResponse.fromJson(Map<String, dynamic> json)
      : changeLog = json['body'],
        tagName = json['tag_name'];
}
