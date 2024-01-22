import 'package:auto_size_text/auto_size_text.dart';
import 'package:dailyanimelist/api/malclubs.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/clubscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

class ClubListWidget extends StatefulWidget {
  final ClubListHtml clubListHtml;
  const ClubListWidget({Key? key, required this.clubListHtml})
      : super(key: key);

  @override
  _ClubListWidgetState createState() => _ClubListWidgetState();
}

class _ClubListWidgetState extends State<ClubListWidget> {
  late ClubListHtml clubListHtml;
  List<ClubHtml> clubs = [];
  int pageIndex = 0;
  bool loadingStarted = false;
  bool noContent = false;

  @override
  void initState() {
    super.initState();
    clubListHtml = widget.clubListHtml;
    clubs = clubListHtml.clubs ?? [];
    if (clubs.isNotEmpty) {
      pageIndex = 1;
    }
  }

  loadMore() async {
    if (mounted)
      setState(() {
        loadingStarted = true;
        pageIndex++;
      });

    final _clubsHtmlList = await getClubs(page: pageIndex);

    if (_clubsHtmlList?.clubs != null && _clubsHtmlList!.clubs!.isNotEmpty) {
      clubs.addAll(_clubsHtmlList.clubs!);
    } else {
      noContent = true;
    }
    loadingStarted = false;

    if (mounted) setState(() {});
  }

  Future<ClubListHtml?> getClubs({bool fromCache = true, int page = 1}) async {
    var _clubs = await MalClub.getClubs(fromCache: fromCache, page: page);
    if (shouldUpdateContent(
        result: _clubs, timeinHours: user.pref.cacheUpdateFrequency[1])) {
      return await getClubs(fromCache: false, page: page);
    } else {
      return _clubs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return clubListHtml?.clubs == null || clubListHtml.clubs!.isEmpty
        ? showNoContent()
        : ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 40, bottom: 90),
            shrinkWrap: true,
            children: [
              ClubList(clubs: clubs),
              const SizedBox(
                height: 10,
              ),
              noContent
                  ? showNoContent()
                  : !loadingStarted
                      ? longButton(onPressed: () => loadMore())
                      : loadingCenter()
            ],
          );
  }
}

class ClubList extends StatelessWidget {
  final List<ClubHtml> clubs;
  const ClubList({Key? key, required this.clubs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: clubs.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemBuilder: (_, index) {
        var clubInfo = clubs.elementAt(index);
        return ClubHtmlListWidget(clubInfo: clubInfo);
      },
    );
  }
}

class ClubHtmlListWidget extends StatelessWidget {
  const ClubHtmlListWidget({
    super.key,
    required this.clubInfo,
  });

  final ClubHtml clubInfo;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          gotoPage(
              context: context,
              newPage: ClubScreen(
                clubHtml: clubInfo,
              ));
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        AvatarAspect(
                          url: clubInfo.imgUrl,
                          radius: BorderRadius.circular(4),
                          aspectRatio: 100 / 140,
                        ),
                      ],
                    ),
                  )),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        clubInfo.clubName ?? "Club ?",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        clubInfo?.desc ?? "",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (clubInfo.lastPostBy != null &&
                              clubInfo.lastPostTime != null)
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 180.0),
                              child: PlainButton(
                                onPressed: () {
                                  if (clubInfo.lastPostBy != null) {
                                    showUserPage(context: context, username: clubInfo.lastPostBy!);
                                  }
                                },
                                padding: EdgeInsets.zero,
                                child: Text(
                                  '${clubInfo.lastPostBy} · ${clubInfo.lastPostTime}',
                                  style: TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          Expanded(child: SB.z),
                          if (clubInfo.noOfMembers != null)
                            SizedBox(
                              height: 30.0,
                              child: ShadowButton(
                                onPressed: () {},
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: iconAndText(Icons.people,
                                    (clubInfo.noOfMembers ?? "?") + ""),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
