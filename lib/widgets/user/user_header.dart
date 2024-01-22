import 'package:collection/collection.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/api/jikahelper.dart';
import 'package:dailyanimelist/api/malforum.dart';
import 'package:dailyanimelist/cache/history_data.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/characterscreen.dart';
import 'package:dailyanimelist/screens/clubscreen.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/headerwidget.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/loading/shimmerwidget.dart';
import 'package:dal_commons/commons.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserHeader {
  UserHeader._();
  static UserHeader _uh = UserHeader._();
  factory UserHeader() => _uh;
  Widget aboutWidget(String username, [bool showEdit = true]) {
    final aboutW = (UserAbout? about) => (about == null || about.about.isBlank)
        ? showNoContent()
        : HtmlW(
            data: about.about,
            useImageRenderer: true,
          );
    return CFutureBuilder<UserAbout?>(
      future: DalApi.i.getUserAbout(username),
      loadingChild: _loadingBelow(S.current.About),
      done: (snap) => SingleChildScrollView(
        child: Column(
          children: [
            aboutW(snap.data),
            if (showEdit) ...[
              SB.h20,
              aboutEditBtn(snap.data?.modern ?? false),
              aboutEditRefreshMessage,
              SB.h20,
            ],
          ],
        ),
      ),
    );
  }

  Widget aboutEditBtn(bool modern) {
    final url = modern
        ? 'https://mxj.myanimelist.net/about-me/?utm_source=MAL&utm_medium=profile_link_about-me'
        : '${CredMal.htmlEnd}editprofile.php';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Tooltip(
          message: S.current.Add_Edit_Msg,
          child: BorderButton(
            onPressed: () => launchURLWithConfirmation(url,
                context: MyApp.navigatorKey.currentContext!),
            child: title(S.current.Edit_About, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget get aboutEditRefreshMessage {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        child: title(
          S.current.Edit_Refresh_Message,
          align: TextAlign.center,
        ),
      ),
    );
  }

  Widget friendsWidget(String username) {
    return FutureBuilder<FriendV4List>(
      future: DalApi.i.getUserFriends(username),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final friends = snapshot.data?.friends ?? [];
          if (friends.isNotEmpty) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: title("(${friends.length} ${S.current.friends})",
                        fontStyle: FontStyle.italic)),
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10),
                    itemCount: friends.length,
                    itemBuilder: (_, i) => friendTile(friends.elementAt(i)))
              ],
            );
          } else {
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 20),
              child: showNoContent(text: S.current.No_friends_found),
            );
          }
        } else {
          return _loadingBelow(S.current.Friends);
        }
      },
    );
  }

  Widget friendTile(FriendV4 friend) {
    final friendUsername = friend?.user?.username;
    String? friendSince = friend.friendsSince, lastOnline = friend.lastOnline;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Material(
        child: ListTile(
          onTap: () {
            if (friendUsername != null) {
              showUserPage(
                  context: MyApp.navigatorKey.currentContext!,
                  username: friendUsername);
            }
          },
          onLongPress: () {
            if (friendSince != null) {
              showToast("$friendSince");
            }
          },
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          leading: AvatarAspect(
            url: friend?.user?.images?.jpg?.imageUrl,
            isNetworkImage: true,
            username: friendUsername,
          ),
          title: title(friendUsername, opacity: 1, fontSize: 16),
          subtitle: lastOnline == null
              ? null
              : title("${S.current.last_seen} $lastOnline",
                  fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget clubsWidget(String username) {
    return FutureBuilder<SearchResult>(
      future: MalForum.getUserClubs(username: username),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          List<BaseNode> clubs = snapshot.data?.data ?? [];
          if (clubs.isEmpty) {
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 20),
              child: showNoContent(text: S.current.No_clubs_found),
            );
          }
          return ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: clubs.length,
              itemBuilder: (_, i) => clubTile(clubs.elementAt(i)));
        } else {
          return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 20),
              child: loadingBelowText(text: S.current.Loading_clubs));
        }
      },
    );
  }

  Widget clubTile(BaseNode club) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Material(
        child: ListTile(
          onTap: () {
            if (club?.content?.id != null) {
              gotoPage(
                  context: MyApp.navigatorKey.currentContext!,
                  newPage: ClubScreen(
                    clubHtml: ClubHtml(
                        clubId: club?.content?.id,
                        clubName: club?.content?.title,
                        desc: ""),
                  ));
            } else {
              showToast(S.current.Couldnt_open_Club);
            }
          },
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          leading: Icon(Icons.people_rounded),
          title: title(club?.content?.title ?? "", opacity: 1, fontSize: 16),
        ),
      ),
    );
  }

  Widget favoritesWidget(String username) {
    return CFutureBuilder<UserFavV4>(
      future: JikanHelper.getUserFavorites(username),
      loadingChild: _loadingBelow(S.current.Favorites),
      done: (snapshot) => Padding(
        padding: EdgeInsets.only(left: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _detailBuilder(
                  S.current.Anime_Caps, "anime", snapshot.data?.anime ?? []),
              _detailBuilder(
                  S.current.Manga_Caps, "manga", snapshot.data?.manga ?? []),
              _detailBuilder(S.current.Characters, "character",
                  snapshot.data?.characters ?? []),
              _detailBuilder(
                  S.current.People_Caps, "seiyuu", snapshot.data?.people ?? []),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailBuilder(String _title, String category, Iterable? _list) {
    var context = MyApp.navigatorKey.currentContext!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title(_title, opacity: 1, fontSize: 22),
        const SizedBox(height: 30),
        _list == null || _list.isEmpty
            ? Padding(
                padding: EdgeInsets.only(bottom: 30), child: showNoContent())
            : Container(
                height: 140,
                child: ListView.builder(
                    itemCount: _list.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) {
                      Node _node;
                      var role = _list.elementAt(index);
                      if (role is Node) {
                        _node = role;
                      } else {
                        _node = _getNode(role);
                      }
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: AnimeGridCard(
                          category: category,
                          height: 100,
                          width: 80,
                          onTap: () {
                            if (category.equals("character") ||
                                category.equals("seiyuu")) {
                              gotoPage(
                                  context: context,
                                  newPage: CharacterScreen(
                                    id: _node.id!,
                                    charaCategory: category,
                                  ));
                            } else
                              gotoPage(
                                  context: context,
                                  newPage: ContentDetailedScreen(
                                    category: category,
                                    id: _node.id,
                                    node: _node,
                                  ));
                          },
                          node: _node,
                        ),
                      );
                    }),
              )
      ],
    );
  }

  Node _getNode(dynamic role) {
    return Node(
      id: role.malId,
      mainPicture: Picture(
          large: role.images.jpg.imageUrl, medium: role.images.jpg.imageUrl),
      title: _getNameOrTitle(role),
    );
  }

  String _getNameOrTitle(node) {
    String? _title;
    try {
      _title = node.title;
    } catch (e) {}
    if (_title == null || _title.isBlank) {
      try {
        _title = node.name;
      } catch (e) {}
    }
    return _title ?? '';
  }
}

Widget _loadingBelow(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 60.0),
    child: Column(
      children: [
        SizedBox(width: double.infinity),
        loadingBelowText(text: '${S.current.Loading} $text'),
      ],
    ),
  );
}

class UserHistoryWidget extends StatefulWidget {
  final String username;
  const UserHistoryWidget({super.key, required this.username});

  @override
  State<UserHistoryWidget> createState() => _UserHistoryWidgetState();
}

class _UserHistoryWidgetState extends State<UserHistoryWidget> {
  Category? _category;
  final headers = [S.current.All, 'Anime', 'Manga'];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: historyWidget(widget.username),
        ),
        SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: HeaderWidget(
              header: headers,
              shouldAnimate: false,
              selectedIndex: _category == null
                  ? 0
                  : _category == Category.ANIME
                      ? 1
                      : 2,
              onPressed: (value) {
                setState(() {
                  _category = value == 0
                      ? null
                      : value == 1
                          ? Category.ANIME
                          : Category.MANGA;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget historyWidget(String username) {
    return StateFullFutureWidget<UserHistoryData>(
      future: () => DalApi.i.getUserHistory(username),
      done: (snapshot) {
        final history = (snapshot.data?.data ?? []).where((element) {
          if (_category == null) return true;
          return element.category == _category;
        }).toList();
        if (history.isEmpty) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 20),
            child: showNoContent(text: S.current.No_history_found),
          );
        }
        final groupedHistory = groupBy(history, (datum) {
          String time = (datum.time ?? '');

          if (time.startsWith('Yesterday')) {
            time = time.replaceAll('Yesterday,', '').trim();
            var dateFormat2 = DateFormat('hh:mm a');
            try {
              var yest = DateTime.now().subtract(Duration(days: 1));
              var parse = dateFormat2.parse(time);
              yest = yest.copyWith(hour: parse.hour, minute: parse.minute);
              yest = yest.add(Duration(hours: 13, minutes: 30));
              datum.formattedDate = dateFormat2.format(yest);
            } catch (e) {}
            return S.current.Yesterday;
          }
          return _someDateText(datum) ?? S.current.Today;
        });
        return ListView.builder(
            padding: EdgeInsets.only(top: 10, bottom: 40),
            itemCount: groupedHistory.length,
            itemBuilder: (_, i) =>
                _historyTile(groupedHistory.entries.elementAt(i)));
      },
      loadingChild: _loadingBelow(S.current.History),
    );
  }

  String? _someDateText(Datum datum) {
    String time = (datum.time ?? '');
    DateTime? parsed;
    final dateFormat = DateFormat('MMM d, hh:mm a');

    try {
      parsed = dateFormat.parse(time);
      parsed = parsed.copyWith(year: DateTime.now().year);
      parsed = parsed.add(Duration(hours: 13, minutes: 30));
      datum.formattedDate = dateFormat.format(parsed);
    } catch (e) {}
    if (parsed != null) {
      final duration = DateTime.now().difference(parsed);
      if (duration.inDays < 6) {
        return DateFormat('EEEE').format(parsed);
      } else if (duration.inDays < 14) {
        return S.current.Last_Week;
      } else if (duration.inDays < 21) {
        return S.current.Two_Weeks_ago;
      } else if (duration.inDays < 28) {
        return S.current.Three_Weeks_ago;
      } else if (duration.inDays < 35) {
        return S.current.Last_Month;
      } else if (duration.inDays < 60) {
        return S.current.Two_Months_ago;
      } else {
        return S.current.weeks_ago.capitalize()!;
      }
    }
    return null;
  }

  Widget _historyTile(MapEntry<String, List<Datum>> elementAt) {
    final date = elementAt.key;
    final history = elementAt.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Material(
        child: ExpansionTile(
          initiallyExpanded:
              [S.current.Today, S.current.Yesterday].contains(date),
          title: Row(
            children: [
              title(date, opacity: 1, fontSize: 16),
              Spacer(),
              title(
                  "${history.length} ${history.length == 1 ? S.current.item : S.current.items}",
                  opacity: 1,
                  fontSize: 12),
            ],
          ),
          children: history
              .map((e) => ListTile(
                    onTap: () {
                      if (e.id != null) {
                        gotoPage(
                            context: context,
                            newPage: ContentDetailedScreen(
                              category: e.category == Category.ANIME
                                  ? "anime"
                                  : "manga",
                              id: int.parse(e.id!),
                            ));
                      }
                    },
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    title: title(e.title ?? "", opacity: 1, fontSize: 16),
                    trailing: title(e.history ?? "", opacity: 1, fontSize: 12),
                    subtitle: title((e.formattedDate ?? e.time ?? '').trim(),
                        opacity: 1, fontSize: 12),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
