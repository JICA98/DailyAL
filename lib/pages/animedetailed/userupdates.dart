import 'package:dailyanimelist/api/jikahelper.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/userpage.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/forum/nextprev.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/home/nodebadge.dart';
import 'package:dailyanimelist/widgets/loading/shimmerwidget.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserUpdatesPage extends StatefulWidget {
  final int id;
  final VoidCallback? onPageChange;
  final String category;
  final double horizPadding;
  const UserUpdatesPage(
      {Key? key,
      required this.id,
      required this.category,
      this.onPageChange,
      required this.horizPadding})
      : super(key: key);

  @override
  _UserUpdatesPageState createState() => _UserUpdatesPageState();
}

class _UserUpdatesPageState extends State<UserUpdatesPage>
    with AutomaticKeepAliveClientMixin {
  late Future<UserUpdateList> updatesFuture;
  int page = 1;

  @override
  void initState() {
    super.initState();
    updatesFuture = JikanHelper.getUserUpdates(widget.category, widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return CFutureBuilder<UserUpdateList?>(
      future: updatesFuture,
      done: (s) => _userListWidget(s.data?.data ?? []),
      loadingChild:
          _userListWidget(List<UserUpdate?>.generate(12, (index) => null)),
    );
  }

  Widget _userListWidget(List<UserUpdate?>? userList) {
    if (userList == null || userList.isEmpty) return showNoContent();

    return Container(
      height: 280,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: .5,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => _buildTile(userList[index]),
        padding: EdgeInsets.symmetric(
          horizontal: widget.horizPadding + 10,
          vertical: 7,
        ),
        itemCount: userList.length,
      ),
    );
  }

  Widget _buildTile(UserUpdate? e) {
    return ShimmerConditionally(
      showShimmer: e == null,
      child: Container(
        width: 120,
        child: Card(child: e == null ? SB.z : _userCardDetailed(e)),
      ),
    );
  }

  Widget _userCardDetailed(UserUpdate e) {
    var nsv = NodeStatusValue.fromString(e.status!);
    var date = DateTime.tryParse(e.date ?? "");
    final username = e.user?.username;
    final imageUrl = e.user?.images?.jpg?.imageUrl;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: username == null
          ? null
          : () => showUserPage(context: context, username: username),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    AvatarWidget(
                      username: username,
                      height: 45,
                      width: 45,
                      url: imageUrl,
                      onTap: username == null
                          ? null
                          : () => showUserPage(
                              context: context, username: username),
                    ),
                    SB.h10,
                    Container(
                      alignment: Alignment.center,
                      width: 80,
                      child: title(username,
                          fontSize: 13, textOverflow: TextOverflow.ellipsis),
                    )
                  ],
                ),
                _combinedProgress(e)
              ],
            ),
            SB.h5,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _scoreWidget(e.score?.toString() ?? null),
                if (date != null)
                  title(
                    displayTimeAgo(date),
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                if (nsv?.status != null) StatusBadge(nsv, height: 25)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _combinedProgress(UserUpdate e) {
    return widget.category.equals("anime")
        ? _progressWidget(
            e.episodesSeen,
            e.episodesTotal,
            S.current.Episodes,
          )
        : Container(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _progressWidget(
                    e.volumesRead, e.volumesTotal, S.current.Volumes),
                _progressWidget(
                    e.chaptersRead, e.chaptersTotal, S.current.Chapters)
              ],
            ),
          );
  }

  Widget _scoreWidget(score) {
    return Padding(
        padding: EdgeInsets.only(right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              height: 14,
              child: Image.asset("assets/images/star.png"),
            ),
            const SizedBox(
              width: 5,
            ),
            title(score ?? "--", opacity: 1, fontSize: 14),
          ],
        ));
  }

  Widget _progressWidget(int? by, int? total, String text) {
    return Column(
      children: [
        Container(
            height: 45,
            width: 45,
            child: Stack(
              children: [
                Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    value: (by == null || total == null || total == 0)
                        ? 0
                        : (by.toDouble() / total.toDouble()),
                  ),
                ),
                Center(
                  child: title('${by ?? "-"}/${total ?? "-"}', fontSize: 9),
                ),
              ],
            )),
        SB.h5,
        title(text)
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
