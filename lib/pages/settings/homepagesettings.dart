import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/settings/customsettings.dart';
import 'package:dailyanimelist/pages/settings/optiontile.dart';
import 'package:dailyanimelist/screens/seasonal_screen.dart';
import 'package:dailyanimelist/user/hompagepref.dart';
import 'package:dailyanimelist/user/prefvalue.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/util/homepageutils.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dal_commons/dal_commons.dart';
import '../../constant.dart';

class HomePageSettings extends StatefulWidget {
  final VoidCallback? onUiChange;

  const HomePageSettings({Key? key, this.onUiChange}) : super(key: key);

  @override
  _HomePageSettingsState createState() => _HomePageSettingsState();
}

class _HomePageSettingsState extends State<HomePageSettings> {
  List<String> homePageItemOptions = ["14", "18", "24", "28"];

  @override
  Widget build(BuildContext context) {
    return SettingSliverScreen(
      titleString: S.current.Customize_Home_Page,
      child: SliverListWrapper([
        noOfItemsTile,
        homePageTileSizeOption(((value) {
          setState(() {});
        })),
        OptionTile(
          text: S.current.Home_Page_items,
          desc: S.current.Reorder_home_page,
          trailing: ShadowButton(
            child: Text(S.current.Reset),
            onPressed: () async {
              var result = await showConfirmationDialog(
                  context: context,
                  alertTitle: S.current.Reset_homepage,
                  desc: S.current.Reset_homepage_warning);
              if (result) {
                if (mounted)
                  setState(() {
                    user.pref.hpApiPrefList = defaultHPPrefList.toList();
                    user.setIntance(shouldNotify: true);
                    if (widget.onUiChange != null) widget.onUiChange!();
                  });
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: BorderButton(
              onPressed: () {
                if (user.pref.hpApiPrefList.length > 40) {
                  showToast(S.current.max_items_home);
                } else {
                  showItemEdit(edit: false);
                }
              },
              child: title(S.current.Add_an_Item)),
        ),
        SB.h20,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) =>
                homePageEditTile(user.pref.hpApiPrefList.elementAt(i), i),
            itemCount: user.pref.hpApiPrefList.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex = newIndex - 1;
              }
              user.pref.hpApiPrefList
                  .insert(newIndex, user.pref.hpApiPrefList.removeAt(oldIndex));
              user.setIntance(shouldNotify: true);
              if (widget.onUiChange != null) widget.onUiChange!();

              if (mounted) setState(() {});
            },
          ),
        ),
        SB.h20,
        showNoContent(text: S.current.Restart_to_see_changes),
        SB.h120
      ]),
    );
  }

  Widget homePageEditTile(HomePageApiPref e, int i) {
    return Card(
      key: ValueKey(e),
      child: OptionTile(
        text: "${e.value.title}",
        contentPadding: EdgeInsets.symmetric(horizontal: 15),
        iconData: Icons.drag_indicator,
        trailing: PlainButton(
            onPressed: () => showItemEdit(e: e, i: i),
            child: Icon(Icons.edit, size: 20)),
      ),
    );
  }

  void showItemEdit({HomePageApiPref? e, bool edit = true, int? i}) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 100),
        curve: Curves.decelerate,
        child: HomePageEditPreference(
          apiPref: e,
          showReset: edit,
          showDelete: user.pref.hpApiPrefList.length > 3 && edit,
          onDelete: () {
            if (edit) {
              if (mounted)
                setState(() {
                  user.pref.hpApiPrefList.removeAt(i!);
                  user.setIntance();
                });
            }
          },
          onSaved: (apiPref) {
            if (mounted)
              setState(() {
                if (edit) {
                  user.pref.hpApiPrefList[i!] = apiPref;
                } else {
                  user.pref.hpApiPrefList.insert(0, apiPref);
                }
                user.setIntance();
              });
          },
        ),
      ),
    );
  }

  Widget get noOfItemsTile => OptionTile(
        text: S.current.No_of_items_in_each_category,
        desc: S.current.No_of_items_desc,
        multiLine: true,
        iconData: Icons.format_list_numbered,
        trailing: PlainButton(
          onPressed: () {
            showCustomSheet(
                context: context,
                child: SelectSheet(
                  displayValues: homePageItemOptions,
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        user.pref.homePageItemsPerCategory =
                            int.tryParse(value) ?? 14;
                        user.setIntance();
                      });
                    }
                  },
                  popupText: S.current.Select_the_no_of_items,
                  options: homePageItemOptions,
                  selectedOption: user.pref.homePageItemsPerCategory.toString(),
                ));
          },
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: title('${user.pref.homePageItemsPerCategory}'),
        ),
      );
}

Widget homePageTileSizeOption(ValueChanged<double> onChanged) {
  return ListTile(
    title: Row(
      children: [
        title(S.current.Tile_Size_Title, opacity: 1),
        SB.w10,
        ToolTipButton(
          child: Icon(Icons.info_outline, size: 16),
          message: S.current.Tile_Size_Desc,
        )
      ],
    ),
    subtitle: Slider(
      value: user.pref.homePageTileSize.index.toDouble(),
      max: HomePageTileSize.values.length.toDouble() - 1,
      divisions: HomePageTileSize.values.length - 1,
      label: user.pref.homePageTileSize.name.capitalizeAll(),
      onChanged: (value) {
        user.pref.homePageTileSize =
            HomePageTileSize.values.elementAt(value.toInt());
        user.setIntance(shouldNotify: true);
        onChanged(value);
      },
    ),
  );
}

class HomePageEditPreference extends StatefulWidget {
  final bool showDelete;
  final HomePageApiPref? apiPref;
  final VoidCallback? onDelete;
  final Function(HomePageApiPref)? onSaved;
  final bool showReset;

  const HomePageEditPreference(
      {Key? key,
      this.showDelete = true,
      this.apiPref,
      this.showReset = true,
      this.onDelete,
      this.onSaved})
      : super(key: key);

  @override
  _HomePageEditPreferenceState createState() => _HomePageEditPreferenceState();
}

class _HomePageEditPreferenceState extends State<HomePageEditPreference> {
  late HomePageApiPref apiPref;
  List<String> yearList = List.generate(SeasonalConstants.totalYears,
      (index) => (SeasonalConstants.maxYear - index).toString()).toList();
  final FocusNode focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();
  final Map<HomePageType, String> _homePageTypeEnumMap = {
    HomePageType.top_anime: 'Top Anime',
    HomePageType.top_manga: 'Top Manga',
    HomePageType.forum: 'Forum',
    HomePageType.seasonal_anime: 'Seasonal Anime',
    HomePageType.sugg_anime: S.current.suggested_anime,
    HomePageType.user_list: 'User List',
    HomePageType.news: S.current.News
  };
  List<String> sortTypeOptions = [
    S.current.None,
    ...SortType.values.asNameMap().keys
  ];

  @override
  void initState() {
    super.initState();
    if (widget.apiPref != null) {
      initValue();
    } else {
      apiPref = HomePageApiPref.defaultPref();
    }
    updateForm();
  }

  void updateForm({bool buildTitle = true}) {
    if (buildTitle) apiPref.value.title = HomePageUtils().titleBuilder(apiPref);
    controller.text = apiPref.value.title;
  }

  void initValue() {
    apiPref = HomePageApiPref.fromValues(
        contentType: widget.apiPref!.contentType, value: widget.apiPref!.value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SB.h20,
              _field(
                  S.current.Content_type,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SelectBar(
                      selectedOption: _homePageTypeEnumMap[apiPref.contentType],
                      options: _homePageTypeEnumMap.values.toList(),
                      // iconToUse: Icons.arrow_drop_down,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            apiPref.contentType = _homePageTypeEnumMap.keys
                                .elementAt(_homePageTypeEnumMap.values
                                    .toList()
                                    .indexOf(value!));
                            apiPref.value = PrefValue.fromApiPref(apiPref);
                            updateForm();
                          });
                        }
                      },
                    ),
                  )),
              ExpandedSection(
                expand: apiPref.contentType != null,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: _specificWidget,
                ),
              ),
              SB.h10,
              _fieldForm(S.current.Title),
              SB.h40,
              buttonRow(),
              SB.h20,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _specificWidget {
    if (apiPref.value.authOnly && user.status == AuthStatus.UNAUTHENTICATED) {
      return showNoContent(text: S.current.Login_toView_Settings);
    }

    switch (apiPref.contentType) {
      case HomePageType.top_anime:
        return _buildAnimeBar();
      case HomePageType.top_manga:
        return _buildMangaBar();
      case HomePageType.seasonal_anime:
        return _buildSeasonalBar();
      case HomePageType.forum:
        return _buildForumBar();
      case HomePageType.user_list:
        return _buildUserListBar();
      default:
    }
    return SB.z;
  }

  Widget _buildAnimeBar() {
    return _field(
        S.current.Select_Ranking_Type,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SelectBar(
            selectedOption: rankingMap[apiPref.value?.rankingType],
            options: rankingMap.values.toList(),
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  if (value != null) {
                    apiPref.value.rankingType = rankingMap.keys
                        .elementAt(rankingMap.values.toList().indexOf(value));
                    updateForm();
                  }
                });
              }
            },
          ),
        ));
  }

  Widget _buildMangaBar() {
    return _field(
        S.current.Select_Ranking_Type,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SelectBar(
            selectedOption: mangaRankingMap[apiPref.value?.mangaRanking],
            options: mangaRankingMap.values.toList(),
            // iconToUse: Icons.arrow_drop_down,
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  if (value != null) {
                    apiPref.value.mangaRanking = mangaRankingMap.keys.elementAt(
                        mangaRankingMap.values.toList().indexOf(value));
                    updateForm();
                  }
                });
              }
            },
          ),
        ));
  }

  Column _buildUserListBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldBar(
            title: S.current.Category,
            selected: apiPref.value.userCategory,
            options: contentTypes,
            onChanged: (value) {
              apiPref.value.userCategory = value;
            }),
        SB.h20,
        _fieldBar(
            title: S.current.Sub_Category,
            selected: apiPref.value.userSubCategory,
            options: apiPref.value.userCategory!.equals("anime")
                ? allAnimeStatusMap.values.toList()
                : allMangaStatusMap.values.toList(),
            onChanged: (value) {
              apiPref.value.userSubCategory = value;
            }),
      ],
    );
  }

  Column _buildForumBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(
            S.current.Select_Board,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SelectBar(
                selectedOption: apiPref.value.boardName,
                options: ForumConstants.boards.values.toList(),
                // iconToUse: Icons.arrow_drop_down,
                disabled: apiPref.value.subboardName != null,
                disabledReason: S.current.Cannot_select_board_with_subb,
                onClear: () {
                  if (mounted) {
                    setState(() {
                      apiPref.value.boardName = null;
                      updateForm();
                    });
                  }
                },
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      apiPref.value.boardName = value;
                      updateForm();
                    });
                  }
                },
              ),
            )),
        SB.h20,
        _field(
            S.current.Select_Sub_board,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SelectBar(
                selectedOption: apiPref.value.subboardName,
                options: ForumConstants.subBoards.values.toList(),
                // iconToUse: Icons.arrow_drop_down,
                disabledReason: S.current.Cannot_select_subboard_with_board,
                disabled: apiPref.value.boardName != null,
                onClear: () {
                  if (mounted) {
                    setState(() {
                      apiPref.value.subboardName = null;
                      updateForm();
                    });
                  }
                },
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      apiPref.value.subboardName = value;
                      updateForm();
                    });
                  }
                },
              ),
            ))
      ],
    );
  }

  Column _buildSeasonalBar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _fieldBar(
                title: S.current.Auto,
                selected: apiPref.value.auto ? S.current.Yes : S.current.No,
                options: [S.current.Yes, S.current.No],
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      apiPref.value = PrefValue.fromApiPref(apiPref);
                      apiPref.value.auto = value.equals(S.current.Yes);
                      updateForm();
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: _field(
                S.current.Sort_By,
                SelectButton(
                  options: sortTypeOptions,
                  selectedOption:
                      apiPref.value.sortType?.name ?? S.current.None,
                  selectType: SelectType.select_sheet,
                  reverseIcon: true,
                  useIcon: false,
                  popupText: S.current.Sort_the_list_based_on,
                  onChanged: (value) {
                    setState(() {
                      apiPref.value.sortType =
                          SortType.values.asNameMap()[value];
                      updateForm();
                    });
                  },
                ),
                0,
              ),
            ),
          ],
        ),
        if (!apiPref.value.auto)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _field(
                      S.current.Season,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SelectBar(
                          selectedOption: seasonMap[apiPref.value?.seasonType],
                          options: seasonMap.values.toList(),
                          // iconToUse: Icons.arrow_drop_down,
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                if (value != null) {
                                  apiPref.value.seasonType = seasonMap.keys
                                      .elementAt(seasonMap.values
                                          .toList()
                                          .indexOf(value));
                                  updateForm();
                                }
                              });
                            }
                          },
                        ),
                      )),
                ),
                Expanded(
                  flex: 3,
                  child: _field(
                      S.current.Year,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SelectBar(
                          shouldBreak: false,
                          selectedOption: apiPref.value?.year?.toString(),
                          options: yearList,
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                apiPref.value.year =
                                    int.tryParse(value!) ?? DateTime.now().year;
                                updateForm();
                              });
                            }
                          },
                        ),
                      )),
                )
              ],
            ),
          )
      ],
    );
  }

  Widget _fieldBar({
    required String title,
    required String? selected,
    required List<String> options,
    String disabledReason = "",
    bool disabled = false,
    VoidCallback? onClear,
    required Function(String) onChanged,
  }) {
    return _field(
        title,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SelectBar(
            selectedOption: selected,
            options: options,
            disabledReason: disabledReason,
            disabled: disabled,
            onClear: () {
              if (onClear != null) onClear();
              if (mounted)
                setState(() {
                  updateForm();
                });
            },
            onChanged: (value) {
              onChanged(value!);
              if (mounted)
                setState(() {
                  updateForm();
                });
            },
          ),
        ));
  }

  Widget buttonRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showDelete)
            ShadowButton(
              child: iconAndText(Icons.delete, S.current.Delete),
              onPressed: () {
                if (widget.onDelete != null) widget.onDelete!();
                Navigator.pop(context);
              },
            ),
          const SizedBox(width: 5),
          Expanded(
            child: ShadowButton(
              child: Text(S.current.Save, softWrap: false),
              onPressed: apiPref?.contentType == null
                  ? null
                  : () {
                      if (controller.text.length < 3) {
                        showToast(S.current.Min_title_length);
                      } else if (apiPref.contentType == HomePageType.forum &&
                          apiPref.value.boardName == null &&
                          apiPref.value.subboardName == null) {
                        showToast(S.current.Please_select_a_board_or_sub_board);
                      } else {
                        apiPref.value.title = controller.text;
                        final originalTitle = HomePageUtils().titleBuilder(apiPref);
                        apiPref.value.titleChanged = !originalTitle.equals(apiPref.value.title);
                        if (widget.onSaved != null) widget.onSaved!(apiPref);
                        Navigator.pop(context);
                      }
                    },
            ),
          ),
          const SizedBox(width: 5),
          if (widget.showReset)
            ShadowButton(
              child: iconAndText(Icons.restore, S.current.Reset),
              onPressed: () {
                if (mounted)
                  setState(() {
                    initValue();
                    updateForm();
                  });
              },
            )
        ],
      ),
    );
  }

  Widget _field(String text, Widget child, [double paddingLeft = 25]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: paddingLeft),
          child: title(text, opacity: 1, fontSize: 18),
        ),
        SB.h10,
        child
      ],
    );
  }

  Widget _fieldForm(String text) {
    return _field(
        text,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Card(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        focusNode: focusNode,
                        autofocus: false,
                        controller: controller,
                        onFieldSubmitted: (value) {
                          if (value != null) {
                            if (mounted)
                              setState(() {
                                apiPref.value.title = value;
                              });
                          }
                        },
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type ${text.toLowerCase()} here..',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () {
                        focusNode.unfocus();
                      },
                      iconSize: 16,
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        if (mounted)
                          setState(() {
                            apiPref.value.title = "";
                          });
                      },
                      iconSize: 16,
                    ),
                  ],
                )),
          ),
        ));
  }
}
