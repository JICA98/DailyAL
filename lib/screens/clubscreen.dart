import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dailyanimelist/widgets/background.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/forum/forumtopicwidget.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dailyanimelist/widgets/user/contentlistwidget.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';

import '../constant.dart';

class ClubScreen extends StatefulWidget {
  final ClubHtml clubHtml;
  const ClubScreen({Key? key, required this.clubHtml}) : super(key: key);

  @override
  _ClubScreenState createState() => _ClubScreenState();
}

enum _ViewAllType {
  members,
  forum,
  comments,
}

class _ClubScreenState extends State<ClubScreen> {
  ClubData? clubData;
  int pageIndex = 0;
  final regex = RegExp(r'font-size\s*:\s*[^;]+;');
  final Map<String, String> staffPositionMap = {};
  List<VisibleSection> visibleSections = [];
  static const _typePageMap = {
    _ViewAllType.members: 36,
    _ViewAllType.forum: 50,
    _ViewAllType.comments: 20,
  };

  @override
  void initState() {
    super.initState();
    getClubInfo();
  }

  int get _id => widget.clubHtml.clubId!;

  Future<void> getClubInfo() async {
    clubData = (await DalApi.i.getClubData(_id)).data;
    clubData?.details?.staffs?.forEach((staff) {
      final position = staff.position;
      final username = staff.user?.username;
      if (username != null && position != null) {
        staffPositionMap[username] =
            position.replaceAll('(', '').replaceAll(')', '');
      }
    });
    visibleSections = _visibleSections;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<VisibleSection> get _visibleSections {
    return [
      VisibleSection(
          S.current.general.capitalize()!,
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 40.0),
              child: HtmlW(
                data: (clubData!.information ?? '').replaceAll(regex, ''),
              ),
            ),
          )),
      if (!nullOrEmpty(clubData?.comments))
        VisibleSection(S.current.Comments, _buildComments()),
      if (!nullOrEmpty(clubData?.forumTopics))
        VisibleSection(
          S.current.Forums,
          ForumTopicsList(
            topics: clubData?.forumTopics ?? [],
            showViewAllButton: (clubData?.forumTopics ?? []).length > 3,
            onPressed: () => gotoPage(
              context: context,
              newPage: TitlebarScreen(
                InfinitePagination(
                  future: (offset) => DalApi.i.getClubTopics(_id, offset),
                  pageSize: _typePageMap[_ViewAllType.forum]!,
                  itemBuilder: (_, item, index) =>
                      ForumTopicWidget(topic: item.rowItems.first),
                ),
                appbarTitle: S.current.Forums,
              ),
            ),
          ),
        ),
      if (!nullOrEmpty(clubData?.details?.staffs))
        VisibleSection(S.current.Staff, _buildStaff()),
      if (!nullOrEmpty(clubData?.members))
        VisibleSection(S.current.Members, _buildMember()),
      if (!nullOrEmpty(clubData?.details?.clubRelations?.anime))
        VisibleSection(
            'Anime',
            _buildRelations(
                clubData?.details?.clubRelations?.anime ?? [], 'anime')),
      if (!nullOrEmpty(clubData?.details?.clubRelations?.manga))
        VisibleSection(
            'Manga',
            _buildRelations(
                clubData?.details?.clubRelations?.manga ?? [], 'manga')),
      if (!nullOrEmpty(clubData?.details?.clubRelations?.character))
        VisibleSection(
            S.current.Character,
            _buildRelations(clubData?.details?.clubRelations?.character ?? [],
                'character')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (visibleSections.length > 0) {
      child = DefaultTabController(
        length: visibleSections.length,
        child: _nestedScrollView(),
      );
    } else {
      child = _nestedScrollView();
    }
    return Scaffold(
      body: child,
      floatingActionButton: clubData == null
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BookMarkFloatingButton(
                  type: BookmarkType.clubs,
                  id: _id,
                  data: widget.clubHtml,
                ),
                SB.w10,
                FloatingActionButton(
                  onPressed: () => launchURLWithConfirmation(
                      '${CredMal.htmlEnd}clubs.php?action=join&id=$_id',
                      context: context),
                  child: Icon(Icons.add),
                ),
              ],
            ),
    );
  }

  NestedScrollView _nestedScrollView() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _appBar(innerBoxIsScrolled, context),
      ],
      body: clubData == null
          ? loadingCenter()
          : TabBarView(
              children: visibleSections.map((e) => e.child).toList(),
            ),
    );
  }

  SliverAppBar _appBar(bool innerBoxIsScrolled, BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240.0,
      pinned: true,
      title: innerBoxIsScrolled ? Text(_clubTitle) : null,
      bottom: visibleSections.length == 0
          ? null
          : TabBar(
              tabs: visibleSections.map((e) => Tab(text: e.title)).toList(),
              isScrollable: true,
              onTap: (index) {
                setState(() {
                  pageIndex = index;
                });
              },
            ),
      flexibleSpace: FlexibleSpaceBar(
        background: headerWidget(),
      ),
      actions: [
        bookmarkAction(context),
        searchIconButton(context),
      ],
    );
  }

  Widget _buildMember() {
    final members = clubData?.members ?? [];
    if (members.isEmpty) {
      return _noContent();
    }
    return _viewAllWidgets(
      SliverList.builder(
        itemBuilder: (context, index) =>
            _buildMemberTile(index, members[index]),
        itemCount: members.length,
      ),
      () => gotoPage(
        context: context,
        newPage: TitlebarScreen(
          InfinitePagination(
            future: (offset) => DalApi.i.getClubMember(_id, offset),
            pageSize: _typePageMap[_ViewAllType.members]!,
            itemBuilder: (_, item, index) =>
                _buildMemberTile(index, item.rowItems.first),
          ),
          appbarTitle: S.current.Members,
        ),
      ),
      S.current.Members,
    );
  }

  Widget _viewAllWidgets(
      Widget sliverList, VoidCallback onViewAll, String title) {
    return CustomScrollView(
      slivers: [
        SB.lh20,
        sliverList,
        SB.lh10,
        SliverWrapper(longButton(onPressed: onViewAll)),
        SB.lh30,
      ],
    );
  }

  Widget _buildMemberTile(int index, Member member) {
    final username = member.username ?? '';
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        child: InkWell(
          onTap: () => showUserPage(context: context, username: username),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                AvatarWidget(
                  url: member.mainPicture?.large,
                  height: 55,
                  width: 55,
                ),
                SB.w15,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username),
                    if (staffPositionMap.containsKey(username)) ...[
                      SB.h10,
                      _buildStaffPosition(username),
                    ]
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaff() {
    final staff = clubData?.details?.staffs ?? [];
    if (staff.isEmpty) {
      return _noContent();
    }
    return ListView.builder(
      itemBuilder: (context, index) => _buildStaffTile(index, staff[index]),
      itemCount: staff.length,
    );
  }

  Widget _buildStaffTile(int index, ClubStaff staff) {
    final username = staff.user?.username ?? '';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: InkWell(
          onTap: () => showUserPage(context: context, username: username),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(username),
                _buildStaffPosition(username),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelations(List<ClubRelation> relations, String category) {
    if (relations.isEmpty) {
      return _noContent();
    } else {
      return CustomScrollWrapper([
        SB.lh20,
        SliverList.builder(
          itemCount: relations.length,
          itemBuilder: (context, index) {
            final relation = relations[index];
            final content = Node(id: relation.id, title: relation.title);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(relation.title ?? '?'),
                trailing: contentTypes.contains(category)
                    ? IconButton.filledTonal(
                        onPressed: () => showContentEditSheet(
                            context, category, content,
                            updateCache: true),
                        icon: Icon(Icons.edit))
                    : null,
                onTap: () {
                  onNodeTap(content, category, context);
                },
              ),
            );
          },
        ),
        SB.lh40,
      ]);
    }
  }

  Widget _buildComments() {
    final comments = clubData?.comments ?? [];
    if (comments.isEmpty) {
      return _noContent();
    } else {
      final sliverList = SliverList.builder(
        itemBuilder: (context, index) => _commentsTitle(index, comments[index]),
        itemCount: comments.length,
      );
      return _viewAllWidgets(
        sliverList,
        () => gotoPage(
          context: context,
          newPage: TitlebarScreen(
            InfinitePagination(
              future: (offset) => DalApi.i.getClubComments(_id, offset),
              pageSize: _typePageMap[_ViewAllType.comments]!,
              itemBuilder: (_, item, index) =>
                  _commentsTitle(index, item.rowItems.first),
            ),
            appbarTitle: S.current.Comments,
          ),
        ),
        S.current.Comments,
      );
    }
  }

  Padding _noContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: showNoContent(),
    );
  }

  Widget _commentsTitle(int index, Comment comment) {
    final username = comment.by?.username ?? '';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Row(
          children: [
            AvatarWidget(
              url: comment.by?.mainPicture?.large,
              height: 40.0,
              width: 40.0,
              onTap: () => showUserPage(context: context, username: username),
            ),
            SB.w10,
            Text(
              '$username · ${comment.longAgo ?? ''}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            SB.w10,
            Expanded(child: SB.z),
            if (staffPositionMap.containsKey(username))
              _buildStaffPosition(username),
          ],
        ),
        SB.h10,
        HtmlW(
          data: (comment.content ?? '').replaceAll(regex, ''),
          useImageRenderer: true,
        ),
      ]),
    );
  }

  SizedBox _buildStaffPosition(String username) {
    return SizedBox(
      height: 30.0,
      child: ShadowButton(
        onPressed: () {},
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child:
            Text(staffPositionMap[username]!, style: TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget headerWidget() {
    return Stack(
      children: [
        if (clubData?.details?.picture?.large != null ||
            widget.clubHtml.imgUrl != null)
          SizedBox(
            child: Background(
              context: context,
              url: clubData?.details?.picture?.large ?? widget.clubHtml.imgUrl,
              forceBg: true,
            ),
          ),
        Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          _clubTitle,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (widget.clubHtml.desc != null) ...[
                        SB.h5,
                        Expanded(
                          flex: 4,
                          child: Text(
                            widget.clubHtml.desc ?? "?",
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                      SB.h15,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _clubTitle {
    return ((clubData?.title) ??
        widget.clubHtml.clubName ??
        "${S.current.Title} ?");
  }
}
