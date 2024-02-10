import 'package:dailyal_support/api.dart';
import 'package:dailyal_support/constant.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:line_icons/line_icons.dart';

String _githubApiLink = 'https://api.github.com/repos/JICA98/DailyAL/releases';
String _githubHtmlLink = 'https://github.com/JICA98/DailyAL/releases';

Future<String> getCurrentTag() async {
  AppInfo app = await InstalledApps.getAppInfo('io.github.jica98');
  return '${app.versionName}+${app.versionCode}';
}

Future<GithubResponse> getLatestRelease() async {
  final response = await Dio().get('$_githubApiLink/latest');
  final git = GithubResponse.fromJson(response.data ?? {});
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
  GithubResponse git,
  BuildContext context,
  String tag, [
  bool latestUpdate = false,
]) {
  final hasUpdate = isUpdateAvailable(tag, git.tagName ?? '');
  final changeLog = git.changeLog;
  return AlertDialog(
    title: Text(
      latestUpdate
          ? 'Latest version'
          : (hasUpdate ? 'Update available' : 'No new updates'),
    ),
    content: SingleChildScrollView(
      child: Text((hasUpdate || latestUpdate)
          ? ('Whats new\n\n${changeLog ?? ''}')
          : ''),
    ),
    actions: [
      _closeButton(context),
      if (hasUpdate || latestUpdate) ...[
        TextButton(
          onPressed: () => launchURLWithConfirmation(
              '$_githubHtmlLink/tag/${git.tagName}',
              context: context),
          child: const Text('Open'),
        ),
        ElevatedButton(
          onPressed: () => launchURLWithConfirmation(
              '$_githubHtmlLink/download/${git.tagName}/app-release.apk',
              context: context),
          child: Text(latestUpdate ? 'Install' : 'Update'),
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
    child: const Text('Close'),
  );
}

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late Future<String?> _tagFuture;

  @override
  void initState() {
    super.initState();
    _setFuture();
  }

  void _setFuture() {
    _tagFuture = getCurrentTag();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: _tagFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  _setFuture();
                  if (mounted) {
                    setState(() {});
                  }
                },
                child: CustomScrollView(
                  slivers: [
                    ..._aboutTiles(snapshot.data, context),
                  ],
                ),
              ),
              Positioned(
                left: 20.0,
                right: 20.0,
                bottom: 40.0,
                child: _buildSocialButtons(context),
              )
            ],
          );
        });
  }

  List<Widget> _aboutTiles(String? tag, BuildContext context) {
    return [
      const SizedBox(height: 20.0),
      if (tag != null) ...[
        _optionTile(
          text: 'App is installed',
          desc: tag,
          iconData: Icons.phone_android,
        ),
        _optionTile(
          text: 'ChangeLog',
          iconData: Icons.new_releases,
          onPressed: () => _onGetChangeLog(tag, context),
        ),
        _optionTile(
          text: 'Check for updates',
          iconData: Icons.refresh,
          onPressed: () => _checkForUpdates(tag, context),
        ),
        _optionTile(
            text: 'Latest version',
            iconData: Icons.verified,
            onPressed: () => _installLatestVersion(context)),
      ] else
        _optionTile(
          text: 'App is not installed',
          desc: 'Click here to install latest version',
          iconData: Icons.info,
          onPressed: () => _installLatestVersion(context),
        ),
      const SizedBox(
        height: 30.0,
      ),
    ].map((e) => SliverToBoxAdapter(child: e)).toList();
  }

  void _installLatestVersion(BuildContext context) {
    openFutureAndNavigate(
      text: 'Fetching latest version',
      future: getLatestRelease(),
      onData: (git) => showUpdateAvailablePopup(git, context, '', true),
      context: context,
    );
  }

  Widget _buildSocialButtons(BuildContext context) {
    return FutureBuilder<Config?>(
      future: Api.i.dalConfigFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox();
        }
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
    );
  }

  Widget _socialButton(
    String url,
    IconData icon,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => launchURLWithConfirmation(url, context: context),
        child: Icon(icon),
      ),
    );
  }

  void _checkForUpdates(String? tag, BuildContext context) {
    openFutureAndNavigate(
      text: 'Checking for updates',
      future: getLatestRelease(),
      onData: (git) {
        return showUpdateAvailablePopup(git, context, tag ?? '');
      },
      context: context,
      customError: 'Couldnt find release',
    );
  }

  void _onGetChangeLog(String? tag, BuildContext context) {
    openFutureAndNavigate(
      text: 'Loading ChangeLog',
      future: Dio().get('$_githubApiLink/tags/$tag'),
      onData: (data) {
        final response = GithubResponse.fromJson(data.data ?? {});
        return AlertDialog(
          title: const Text('ChangeLog'),
          content: SingleChildScrollView(
            child: Text(response.changeLog ?? ''),
          ),
          actions: [
            _closeButton(context),
          ],
        );
      },
      context: context,
      customError: 'Couldnt find release',
    );
  }
}

Widget _optionTile({
  required String text,
  String? desc,
  required IconData iconData,
  void Function()? onPressed,
}) {
  return ListTile(
    title: Text(text),
    subtitle: desc != null ? Text(desc) : null,
    leading: Icon(iconData),
    onTap: onPressed,
  );
}

class GithubResponse {
  final String? changeLog;
  final String? tagName;
  GithubResponse({
    this.changeLog,
    this.tagName,
  });

  GithubResponse.fromJson(Map<String, dynamic> json)
      : changeLog = json['body'],
        tagName = json['tag_name'];
}
