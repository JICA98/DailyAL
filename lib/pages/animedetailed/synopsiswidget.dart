// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';

import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/fadingeffect.dart';
import 'package:dailyanimelist/widgets/translator.dart';
import 'package:dal_commons/commons.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:translator_plus/translator_plus.dart';

// HapticFeedback

class PromoNode extends Node {
  String? title;
  String videoUrl;
  String imageUrl;

  PromoNode(
      {required this.title, required this.imageUrl, required this.videoUrl})
      : super(
          title: title,
          mainPicture: Picture(large: imageUrl, medium: imageUrl),
        );
}

class SysonpsisWidget extends StatefulWidget {
  final int? id;
  final String? synopsis;
  final List<MalGenre>? genres;
  final String? background;
  final String category;
  final double horizPadding;
  final int characterLimit;
  final bool expanded;
  final int? totalEpisodes;

  const SysonpsisWidget({
    this.id,
    this.background,
    this.synopsis,
    this.category = "anime",
    this.genres,
    this.expanded = false,
    this.characterLimit = 300,
    this.horizPadding = 15.0,
    this.totalEpisodes,
  });

  @override
  _SysonpsisWidgetState createState() => _SysonpsisWidgetState();
}

class _SysonpsisWidgetState extends State<SysonpsisWidget>
    with AutomaticKeepAliveClientMixin {
  String? synopsis;
  final translator = GoogleTranslator();
  ScheduleData? scheduleData;
  Future<Translation>? transFuture;
  bool expanded = false;
  bool showExpand = false;
  bool showSchedule = true;
  bool scheduleLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.synopsis != null) {
      showSchedule = user.pref.showCountDownInDetailed;
      synopsis = widget.synopsis;
      showExpand = (synopsis != null &&
              synopsis!.isNotBlank &&
              synopsis!.length > widget.characterLimit) ||
          (widget.background != null && widget.background!.isNotBlank);
      expanded = widget.expanded || !showExpand;
      if (widget.synopsis!.isNotBlank)
        transFuture = translator.translate(synopsis ?? '',
            from: "en", to: Intl.shortLocale(Intl.defaultLocale ?? 'en'));
      setScheduleData();
    }
  }

  void setScheduleData() async {
    final schedules = await DalApi.i.scheduleForMalIds;
    if (widget.id != null && schedules.containsKey(widget.id)) {
      scheduleData = schedules[widget.id];
    }
    if (mounted)
      setState(() {
        scheduleLoaded = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CustomPaint(
            foregroundPainter: FadingEffect(
              extend: 5,
              color: Theme.of(context).scaffoldBackgroundColor,
              start: expanded ? 50 : 0,
              end: expanded ? 50 : 255,
            ),
            child: Container(
              height: expanded ? null : 220,
              padding: EdgeInsets.fromLTRB(
                widget.horizPadding,
                0,
                widget.horizPadding,
                0,
              ),
              child: synopsisContent(),
            ),
          ),
        ),
        if (showExpand)
          Center(
            child: Container(
              height: 40,
              child: IconButton(
                onPressed: () {
                  if (mounted)
                    setState(() {
                      expanded = !expanded;
                    });
                },
                padding: EdgeInsets.zero,
                icon: Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24,
                ),
              ),
            ),
          )
      ],
    );
  }

  Container synopsisContent() {
    return Container(
      width: double.infinity,
      child: (widget.synopsis == null || !scheduleLoaded)
          ? loadingText(context)
          : ListView(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(5, 5, 5, 10),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (showSchedule &&
                    scheduleData?.timestamp != null &&
                    _checkShouldShow(
                      scheduleData!,
                      widget.totalEpisodes,
                    ))
                  _schedulesWidget(),
                genresWidget(widget.genres ?? [], widget.category, context),
                SB.h5,
                if (widget.synopsis!.isNotBlank) translatedSynposis(),
                SB.h10,
                (widget.background == null || widget.background == "")
                    ? Container()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            S.current.Background,
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.background ?? S.current.None,
                            textAlign: TextAlign.justify,
                            style: TextStyle(fontSize: 14),
                          )
                        ],
                      ),
              ],
            ),
    );
  }

  Widget _schedulesWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: CountDownWidget(
        onClose: () {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted)
              setState(() {
                showSchedule = false;
              });
          });
        },
        timestamp: scheduleData!.timestamp!,
        extraWidget: Row(
          children: [
            _prefixCountdown(false),
            SB.w5,
            title(
              'Currently Airing',
              colorVal: Colors.green.value,
            )
          ],
        ),
        prefix: _prefixCountdown(),
      ),
    );
  }

  RichText _prefixCountdown([bool addIn = true]) {
    return RichText(
      text: TextSpan(
          text: 'Ep ',
          style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(.7),
              fontSize: 13),
          children: [
            TextSpan(
                text: scheduleData!.episode.toString(),
                style: Theme.of(context).textTheme.bodyMedium),
            if (addIn) TextSpan(text: ' in'),
          ]),
    );
  }

  Widget translatedSynposis() {
    return TranslaterWidget(
      future: transFuture!,
      autoTranslate: user.pref.autoTranslateSynopsis,
      content: widget.synopsis!,
      done: (s) => _buildRichTextWithAnchors(s ?? ''),
      loading: loadingText(context),
      preButtonText: S.current.Translate_Synopsis2,
      postButtonText: S.current.Show_Original,
      buttonPadding: EdgeInsets.zero,
      reversed: true,
      onError: (error) {
        logDal(error);
        showToast("Couldn't translate");
      },
    );
  }

  Widget _buildRichTextWithAnchors(String inputString) {
    List<TextSpan> textSpans = [];

    RegExp urlRegex = RegExp(
        r'(?:(?:http|https):\/\/)?(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)');

    Iterable<Match> matches = urlRegex.allMatches(inputString);
    int start = 0;

    for (Match match in matches) {
      if (match.start > start) {
        textSpans
            .add(TextSpan(text: inputString.substring(start, match.start)));
      }

      String url = match.group(0)!;
      textSpans.add(
        TextSpan(
          text: url,
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () => launchURLWithConfirmation(url, context: context),
        ),
      );

      start = match.end;
    }

    if (start < inputString.length) {
      textSpans.add(TextSpan(text: inputString.substring(start)));
    }

    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall,
        children: textSpans,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

bool _checkShouldShow(ScheduleData scheduleData, [int? totalEpisodes]) {
  final timestamp = scheduleData.timestamp!;
  final episode = scheduleData.episode;

  final localDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  final nowDate = DateTime.now();
  final diff = localDate.difference(nowDate);
  if (diff.isNegative) {
    if (diff.inMinutes.abs() < 30) {
      return true;
    } else {
      return false;
    }
  }
  if (episode != null && totalEpisodes != null) {
    if (episode > totalEpisodes) {
      return false;
    }
  }
  return true;
}

class CWTime {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final bool timerOver;

  CWTime({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.timerOver,
  });
}

class CountDownWidget extends StatefulWidget {
  final int timestamp;
  final Widget? prefix;
  final VoidCallback? onClose;
  final Widget? extraWidget;
  final double? elevation;
  final Widget Function(CWTime)? customTimer;
  const CountDownWidget({
    Key? key,
    required this.timestamp,
    this.prefix,
    this.onClose,
    this.extraWidget,
    this.elevation,
    this.customTimer,
  }) : super(key: key);

  @override
  State<CountDownWidget> createState() => _CountDownWidgetState();
}

class _CountDownWidgetState extends State<CountDownWidget> {
  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  Timer? timer;
  bool showExtra = false;
  bool timerOver = false;

  @override
  void initState() {
    super.initState();
    timerOver = false;
    final localDate =
        DateTime.fromMillisecondsSinceEpoch(widget.timestamp * 1000);
    _setTimeUnits(localDate);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _setTimeUnits(localDate);
      if (mounted) setState(() {});
    });
  }

  void _setTimeUnits(DateTime localDate) {
    final nowDate = DateTime.now();
    final diff = localDate.difference(nowDate);
    if (diff.isNegative) {
      timerOver = true;
      if (diff.inMinutes.abs() < 30) {
        showExtra = true;
      } else {
        if (widget.onClose != null) widget.onClose!();
      }
    } else {
      final timeleft = diff.inMilliseconds;
      days = (timeleft / (1000 * 60 * 60 * 24)).floor();
      hours = ((timeleft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)).floor();
      minutes = ((timeleft % (1000 * 60 * 60)) / (1000 * 60)).floor();
      seconds = ((timeleft % (1000 * 60)) / 1000).floor();
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customTimer != null) {
      return widget.customTimer!(
        CWTime(
          days: days,
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          timerOver: timerOver,
        ),
      );
    }
    return Stack(
      children: [
        Card(
          elevation: widget.elevation,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showExtra && widget.extraWidget != null)
                  widget.extraWidget!
                else ...[
                  if (widget.prefix != null) ...[
                    widget.prefix!,
                    SB.w5,
                  ],
                  _countDownWidget(),
                ]
              ],
            ),
          ),
        ),
        if (widget.onClose != null)
          Positioned(
            top: 8.0,
            right: 0.0,
            child: SizedBox(
              height: 35,
              width: 35,
              child: IconButton(
                onPressed: widget.onClose,
                icon: Icon(Icons.close),
                iconSize: 18.0,
              ),
            ),
          ),
      ],
    );
  }

  String padLef(int number) {
    return number.toString().padLeft(2, '0');
  }

  Widget _countDownWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (days > 0) _timeUnit('d', padLef(days)),
        if (hours > 0) _timeUnit('h', padLef(hours)),
        if (minutes > 0) _timeUnit('m', padLef(minutes)),
        _timeUnit('s', padLef(seconds), true),
      ],
    );
  }

  Widget _timeUnit(String text, String time, [bool isLast = false]) {
    return Text(
      '${time}${text} ${isLast ? '' : '·'} ',
    );
  }
}
