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
import 'package:dailyanimelist/data/top_character_ids.dart';

import '../main.dart';

enum VoiceSortType { mostRecent, favorites, title }

final Map<int, int> _favoritesCache = {};
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
  VoiceSortType _voiceSort = VoiceSortType.mostRecent;
  bool _isSortingFavorites = false;
  List<VoicesFull> _originalVoices = [], _sortedVoices = [];
  bool _disposed = false;

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

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  getSeiyuuDetails() async {
    var _personInfo =
        await DalApi.i.getCharaPeopleInfo(id, DataUnionType.people);
    if (_personInfo != null) {
      personInfo = _personInfo as PeopleV4Data;

      // add voiced characters excluding duplicates
      final seen = <int>{};
      _originalVoices = [];
      for (final v in personInfo?.voices ?? []) {
        final id = v.character?.malId;
        if (id != null && !seen.contains(id)) {
          seen.add(id);
          _originalVoices.add(v);
        }
      }
      _sortedVoices = List.from(_originalVoices);

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
        if (chara.equals("character"))
          _detailBuilder(
            title: "Animeography",
            category: "anime",
            rawList: characterInfo?.anime?.map((e) => e.anime).toList(),
          )
        else
          _detailBuilder(
            title: S.current.Voice_Acting_Roles,
            category: "character",
            rawList: _sortedVoices,
            showSort: true,
          ),

        _detailBuilder(
          title: chara.equals("character")
              ? "Mangaography"
              : S.current.Published_Manga,
          category: "manga",
          rawList: chara.equals("character")
              ? characterInfo?.manga?.map((e) => e.manga).toList()
              : personInfo?.manga?.map((e) => e.manga).toList(),
        ),

        _detailBuilder(
          title: chara.equals("character")
              ? S.current.Voice_Actors
              : S.current.Anime_Staff,
          category: chara.equals("character") ? "person" : "anime",
          rawList: chara.equals("character")
              ? characterInfo?.voices?.map((e) => e.person).toList()
              : personInfo?.anime?.map((e) => e.anime).toList(),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
  
  Widget titleWidget(String value) {
    if (value.isEmpty) return SizedBox.shrink();
    return title(value, opacity: 1, fontSize: 22);
  }

  Widget _detailBuilder({
    required String title,
    required String category,
    required List? rawList,
    bool showSort = false,
  }) {
    List list = rawList ?? [];

    if (showSort) {
      list = _sortedVoices;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            titleWidget(title),
            if (showSort)
              SizedBox(
                width: 28,
                height: 28,
                child: _isSortingFavorites
                    ? Padding(
                        padding: const EdgeInsets.all(4),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : PopupMenuButton<VoiceSortType>(
                        padding: EdgeInsets.zero,
                        tooltip: 'Sort',
                        icon: Icon(Icons.sort, size: 20),
                        onSelected: (sort) async {
                          if (sort == VoiceSortType.favorites) {
                            if (mounted) setState(() => _isSortingFavorites = true);
                            await _fetchMissingFavorites();
                            if (mounted) setState(() => _isSortingFavorites = false);
                          }
                          if (mounted) {
                            setState(() {
                              _voiceSort = sort;
                            });
                            _sortVoices();
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                              value: VoiceSortType.mostRecent,
                              child: Text('Most Recent')),
                          PopupMenuItem(
                              value: VoiceSortType.favorites,
                              child: Text('Favorites')),
                          PopupMenuItem(
                              value: VoiceSortType.title,
                              child: Text('Title')),
                        ],
                      ),
              ),
          ],
        ),
        const SizedBox(height: 30),
        list.isEmpty
            ? Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: showNoContent(),
              )
            : Container(
                height: 180,
                child: ListView.builder(
                  key: showSort ? ValueKey(_voiceSort) : null,
                  itemCount: list.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    final item = list[index];
                    final role = showSort ? item.character : item;

                    if (role == null) return SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: CharacterCardLoader(
                        role: role,
                        category: category,
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Future<bool> _fetchFavorites(List<VoicesFull> voices) async {
    for (var voice in voices) {
      if (_disposed) return false;

      final id = voice.character?.malId;
      if (id != null && !_favoritesCache.containsKey(id)) {
        try {
          final data = await DalApi.i.getCharaPeopleInfo(id, DataUnionType.character);
          if (data is CharacterV4Data) {
            _favoritesCache[id] = data.favorites ?? 0;
          } else {
            showToast(S.current.Rate_limit_reached);
            return false;
          }
        } catch (_) {}
      }
    }
    return true;
  }

  Future<void> _fetchMissingFavorites() async {
    // Build topVoices in the same order as topCharacterIds (descending by favorites)
    final Map<int, VoicesFull> voiceMap = {
      for (final voice in _originalVoices)
        if (voice.character?.malId != null) voice.character!.malId!: voice
    };
    final topVoices = <VoicesFull>[];
    for (final id in topCharacterIds) {
      final voice = voiceMap[id];
      if (voice != null) {
        topVoices.add(voice);
      }
    }

    if (await _fetchFavorites(topVoices) && await _fetchFavorites(_originalVoices)) {
      showToast(S.current.Sorting_finished);
    }
  }

  void _sortVoices() {
    if (_originalVoices.isEmpty) return;

    List<VoicesFull> voices = List.from(_originalVoices);

    if (_voiceSort == VoiceSortType.title) {
      voices.sort((a, b) =>
          (a.character?.name ?? '').compareTo(b.character?.name ?? ''));
    } else if (_voiceSort == VoiceSortType.favorites) {
      voices.sort((a, b) {
        final favA = _favoritesCache[a.character?.malId ?? -1] ?? 0;
        final favB = _favoritesCache[b.character?.malId ?? -1] ?? 0;
        return favB.compareTo(favA);
      });
    } else {
      // no sorting needed as Most Recent is the default order
    }

    setState(() {
      _sortedVoices = voices;
    });
  }
}

class CharacterCardLoader extends StatefulWidget {
  final dynamic role;
  final String category;

  const CharacterCardLoader({required this.role, required this.category, super.key});

  @override
  State<CharacterCardLoader> createState() => _CharacterCardLoaderState();
}

class _CharacterCardLoaderState extends State<CharacterCardLoader> {
  late Node _node;

  @override
  void initState() {
    super.initState();
    final String? title = (widget.category.equals("character") || widget.category.equals("person"))
      ? widget.role?.name
      : widget.role?.title;
    final imageUrl = widget.role.images?.webp?.imageUrl ?? widget.role.images?.jpg?.imageUrl;

    _node = Node(
      id: widget.role.malId,
      title: title,
      mainPicture: Picture(
        large: imageUrl,
        medium: imageUrl,
      ),
      favorites: null,
    );

    _loadFavoritesIfNeeded();
  }

  void _loadFavoritesIfNeeded() async {
    if (_node.favorites != null || _node.id == null) return;
    if (widget.category != "character") return;

    try {
      final data = await DalApi.i.getCharaPeopleInfo(_node.id!, DataUnionType.character);
      if (data is CharacterV4Data && mounted) {
        final imageUrl = data.images?.webp?.imageUrl ?? data.images?.jpg?.imageUrl;
        _favoritesCache[_node.id!] = data.favorites ?? 0;
        setState(() {
          _node = Node(
            id: _node.id,
            title: _node.title,
            mainPicture: Picture(
              large: imageUrl,
              medium: imageUrl,
            ),
            favorites: data.favorites,
          );
        });
      }
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimeGridCard(
      category: widget.category,
      height: 140,
      width: 105,
      onTap: () {
        if (widget.category.equals("character") || widget.category.equals("person")) {
          gotoPage(
            context: context,
            newPage: CharacterScreen(
              id: _node.id!,
              charaCategory: widget.category,
            ),
          );
        } else {
          gotoPage(
            context: context,
            newPage: ContentDetailedScreen(
              category: widget.category,
              id: _node.id,
              node: _node,
            ),
          );
        }
      },
      node: _node,
    );
  }
}
