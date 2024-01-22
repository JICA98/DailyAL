import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/contentdetailedscreen.dart';
import 'package:dailyanimelist/screens/plainscreen.dart';
import 'package:dailyanimelist/util/pathutils.dart';
import 'package:dailyanimelist/util/streamutils.dart';
import 'package:dailyanimelist/widgets/common/image_preview.dart';
import 'package:dailyanimelist/widgets/common/share_builder.dart';
import 'package:dailyanimelist/widgets/customappbar.dart';
import 'package:dailyanimelist/widgets/headerwidget.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/home/bookmarks_widget.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dailyanimelist/widgets/translator.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class CharacterScreen extends StatefulWidget {
  final int id;
  final String charaCategory;
  const CharacterScreen(
      {Key? key, required this.id, this.charaCategory = "character"})
      : super(key: key);

  @override
  _CharacterScreenState createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  late int id;
  CharacterV4Data? characterInfo;
  PeopleV4Data? personInfo;
  int pageIndex = 0;
  String chara = "character";
  List<String> characterPics = [];
  StreamListener listener = StreamListener(0);

  @override
  void initState() {
    super.initState();
    id = widget.id;
    chara = widget.charaCategory;
    if (chara.equals("character")) {
      getCharacterDetails();
      getCharacterPictures();
    } else {
      getSeiyuuDetails();
      getSeiyuuPics();
    }
  }

  getSeiyuuDetails() async {
    var _personInfo =
        await DalApi.i.getCharaPeopleInfo(id, DataUnionType.people);
    if (_personInfo != null) {
      personInfo = _personInfo as PeopleV4Data;
      characterPics.insert(0, personInfo!.images?.jpg?.imageUrl ?? '');
      applyChanges();
    } else {
      showToast(S.current.Couldnt_retreive_Content);
    }
  }

  getSeiyuuPics() async {
    var _characterPics = await DalApi.i.getPictures(id, 'people');
    if (_characterPics != null && _characterPics.isNotEmpty) {
      characterPics.addAll(_characterPics);
      applyChanges();
    }
  }

  getCharacterDetails() async {
    var _characterInfo =
        await DalApi.i.getCharaPeopleInfo(id, DataUnionType.character);
    if (_characterInfo != null) {
      characterInfo = _characterInfo as CharacterV4Data;
      characterPics.insert(0, characterInfo!.images?.jpg?.imageUrl ?? '');
      applyChanges();
    } else {
      showToast(S.current.Couldnt_retreive_Content);
    }
  }

  getCharacterPictures() async {
    var _characterPics = await DalApi.i.getPictures(id, 'character');
    if (_characterPics != null && _characterPics.isNotEmpty) {
      characterPics.addAll(_characterPics);
      applyChanges();
    }
  }

  applyChanges() {
    if (mounted) setState(() {});
  }

  String get appbarTitle =>
      characterInfo?.name ??
      personInfo?.name ??
      (chara.equals('character') ? S.current.Character : S.current.Seiyuu);

  @override
  Widget build(BuildContext context) {
    return TitlebarScreen(
      (characterInfo != null || personInfo != null)
          ? content()
          : ShimmerColor(content()),
      appbarTitle: '',
      floatingActionButton: (characterInfo != null || personInfo != null)
          ? BookMarkFloatingButton(
              type: BookmarkType.values.byName(
                  widget.charaCategory.equals('character')
                      ? 'character'
                      : 'person'),
              id: id,
              data: chara.equals("character") ? characterInfo : personInfo,
            )
          : null,
      actions: [
        PopupMenuBuilder(
          menuItems: [
            shareMenuItem()
              ..onTap = () => openShareBuilder(
                    context,
                    buildShareInputs(
                        characterInfo ?? personInfo, _buildNode.toUrl()),
                    '${S.current.Share} $appbarTitle',
                  ),
            browserMenuItem()
              ..onTap = () => launchURLWithConfirmation(_buildNode.toUrl(),
                  context: context)
          ],
        )
      ],
    );
  }

  DalNode get _buildNode {
    return DalNode(
      category: chara.equals("character") ? "character" : "people",
      id: id,
    );
  }

  Widget content() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
              color: Colors.transparent,
              child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading(
                          (chara.equals("character")
                                  ? characterInfo?.name
                                  : personInfo?.name) ??
                              S.current.Loading_Content,
                          alignment: Alignment.center),
                      const SizedBox(height: 30),
                      heading(
                          (chara.equals("character")
                                  ? characterInfo?.nameKanji
                                  : ((personInfo?.givenName ?? "") +
                                      ", " +
                                      (personInfo?.familyName ?? ""))) ??
                              "",
                          alignment: Alignment.center,
                          fontSize: 18),
                      const SizedBox(height: 30),
                      _imageSlider(),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite),
                          const SizedBox(width: 15),
                          title(
                              chara.equals("character")
                                  ? (characterInfo?.favorites?.toString() ??
                                      "?")
                                  : (personInfo?.favorites.toString() ?? "?"),
                              opacity: 1,
                              align: TextAlign.center,
                              fontSize: 27),
                          const SizedBox(width: 15),
                          Icon(Icons.people)
                        ],
                      ),
                      const SizedBox(height: 30),
                      HeaderWidget(
                        header: [S.current.About, S.current.Details],
                        selectedIndex: pageIndex,
                        onPressed: (_) {
                          pageIndex = _;
                          applyChanges();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            pageIndex == 0 ? _aboutWidget() : _detailsWidget()
                          ],
                        ),
                      ),
                    ],
                  )))
        ],
      ),
    );
  }

  Widget _imageSlider() {
    var isEmpty = characterPics.isEmpty;
    return GestureDetector(
      onTap: () {
        if (isEmpty) return;
        zoomInImageList(context, characterPics, listener.currentValue);
      },
      child: CarouselSlider(
          items: isEmpty
              ? [
                  ClipOval(
                    child: AspectRatio(
                      aspectRatio: 1.5,
                      child: Image.asset("assets/images/user_dal.png"),
                    ),
                  )
                ]
              : characterPics
                  .map((e) => ClipOval(
                        child: AspectRatio(
                          aspectRatio: 1.5,
                          child: CachedNetworkImage(imageUrl: e),
                        ),
                      ))
                  .toList(),
          // carouselController: carouselController,
          options: CarouselOptions(
              onPageChanged: (index, reason) {
               listener.update(index);
              },
              aspectRatio: 2,
              viewportFraction: 0.45,
              autoPlay: true,
              enableInfiniteScroll: true,
              enlargeCenterPage: true)),
    );
  }

  Widget _aboutWidget() {
    final content = chara.equals("character")
            ? (characterInfo?.about ?? "...")
            : (personInfo?.about ?? "...");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        TranslaterWidget(
          content: content,
          reversed: true,
          done: (text) => Text(
            text ?? '...',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 30)
      ],
    );
  }

  Widget _detailsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        _detailBuilder(
            chara.equals("character")
                ? "Animeography"
                : S.current.Voice_Acting_Roles,
            "anime",
            (chara.equals("character")
                ? characterInfo?.anime
                    ?.map((e) => _getNode(e.anime)..title = e.anime!.title!)
                : personInfo?.voices
                    ?.map((e) => _getNode(e.anime)..title = e.anime!.title))),
        _detailBuilder(
            chara.equals("character")
                ? "Mangaography"
                : S.current.Published_Manga,
            "manga",
            chara.equals("character")
                ? characterInfo?.manga
                    ?.map((e) => _getNode(e.manga)..title = e.manga!.title)
                : personInfo?.manga
                    ?.map((e) => _getNode(e.manga)..title = e.manga!.title)),
        _detailBuilder(
            chara.equals("character")
                ? S.current.Voice_Actors
                : S.current.Anime_Staff,
            chara.equals("character") ? "person" : "anime",
            chara.equals("character")
                ? characterInfo?.voices
                    ?.map((e) => _getNode(e.person)..title = e.person!.name)
                : personInfo?.anime
                    ?.map((e) => _getNode(e.anime)..title = e.anime!.title)),
        const SizedBox(height: 30)
      ],
    );
  }

  Widget _detailBuilder(String _title, String category, Iterable? _list) {
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
                                category.equals("person")) {
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
        large: role.images?.jpg?.imageUrl,
        medium: role.images?.jpg?.imageUrl,
      ),
    );
  }
}
