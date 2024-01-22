import 'dart:ui';

import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/api/maluser.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/homescreen.dart';
import 'package:dailyanimelist/user/user.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/loading/expandedwidget.dart';
import 'package:dailyanimelist/widgets/search/filtermodal.dart';
import 'package:dailyanimelist/widgets/selectbottom.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../constant.dart';
import '../../main.dart';
import '../togglebutton.dart';

enum EditMode { floating, full }

class ContentEditWidget extends StatefulWidget {
  final dynamic contentDetailed;
  final String category;
  final bool isCacheRefreshed;
  final bool showAdditional;
  final bool updateCache;
  final bool applyPopScope;
  final ValueChanged<bool>? onUpdate;
  final ValueChanged<dynamic>? onListStatusChange;
  final VoidCallback? onDelete;
  final EditMode editMode;
  final bool applyHero;

  ContentEditWidget({
    this.contentDetailed,
    required this.category,
    this.onUpdate,
    this.onListStatusChange,
    this.updateCache = false,
    this.showAdditional = false,
    this.isCacheRefreshed = false,
    this.applyPopScope = false,
    this.applyHero = true,
    this.onDelete,
    this.editMode = EditMode.full,
  });
  @override
  _ContentEditWidgetState createState() => _ContentEditWidgetState();
}

class _ContentEditWidgetState extends State<ContentEditWidget> {
  bool showAddOptions = false;
  bool modifyStatus = false;
  bool modifyStars = false;
  bool modifyEpisodes = false;
  bool modifyChapters = false;
  bool modifyVolumes = false;
  bool initComplete = false;
  bool cacheUpdated = false;
  bool showAdvancedEdit = false;
  var modifyReStatus = false;
  String? statusValue;
  int? starValue;
  dynamic contentDetailed;
  late TextEditingController episodeController,
      chapterController,
      volumesController;

  bool modifyStartDate = false;

  bool modifyFinishDate = false;

  bool modifyPriority = false;
  bool modifyComments = false;
  bool modifyTags = false;

  bool isReStatusOpen = true;
  bool isDatesOpen = false;
  bool isOthersOpen = false;
  bool isListStatusOpen = true;
  bool animationPending = false;
  DateTime? startDate, finishDate;

  Map<String, bool> accordions = {
    S.current.Your_List_Status: true,
    S.current.Dates_Priority: false,
    S.current.Others: false,
  };

  final ItemScrollController itemScrollController = ItemScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    reset();
    contentDetailed = widget.contentDetailed;
    showAddOptions = isFloating && user.status == AuthStatus.AUTHENTICATED;
    if (widget.updateCache && user.status == AuthStatus.AUTHENTICATED) {
      cacheUpdated = false;
      updateCache();
    } else {
      cacheUpdated = true;
    }

    accordions[(widget.category.equals('anime') ? 'Rewatch' : 'Reread') +
        ' Status'] = true;
  }

  reset() {
    episodeController = new TextEditingController(text: "0");
    chapterController = new TextEditingController(text: "0");
    volumesController = new TextEditingController(text: "0");
    statusValue = null;
    starValue = null;
  }

  onAdvancedEdit() {}

  updateCache() async {
    try {
      var field =
          "num_episodes,my_list_status{is_rewatching,is_rereading,num_times_rewatched,num_times_reread,priority,rewatch_value,reread_value,start_date,finish_date,tags,comments}";
      var content = contentDetailed;
      if (contentDetailed is BaseNode) {
        content = contentDetailed?.content;
      }
      contentDetailed = widget.category.equals("anime")
          ? await MalApi.getAnimeDetails(content.id, fields: [field])
          : await MalApi.getMangaDetails(content.id, fields: [field]);
      checkForUpdatesDuringBuild();
      if (mounted) {
        setState(() {
          cacheUpdated = true;
        });
      }
    } catch (e) {
      showToast(S.current.Couldnt_Update);
    }
  }

  void updateParent(bool result) {
    if (widget.onUpdate != null) {
      widget.onUpdate!(result);
    }
  }

  void updateListStatus(status) {
    if (widget.onListStatusChange != null) {
      widget.onListStatusChange!(status);
    }
  }

  updateEpisodeCount({int? episodes, int? add}) async {
    bool result = false;
    int _episodes = episodes ?? (int.tryParse(episodeController.text) ?? 0);
    _episodes += add ?? 0;
    String? watchStatus;
    if (_episodes < 0) {
      showToast(S.current.Negative_episode_not_allowed);
      return;
    }
    var content = contentDetailed;
    if (contentDetailed is BaseNode) {
      content = contentDetailed?.content;
    }

    try {
      if ((content is AnimeDetailed) &&
          content?.numEpisodes != null &&
          (content.numEpisodes != 0)) {
        if (_episodes > content.numEpisodes!) {
          showToast(S.current.Maximum_reached);
          return;
        }
        if (_episodes == content.numEpisodes) {
          watchStatus = "completed";
        }
      }
    } catch (e) {}

    if (mounted)
      setState(() {
        modifyEpisodes = true;
      });
    var status = await MalUser.updateMyAnimeListStatus(content.id,
        numEpisodesWatched: _episodes, status: watchStatus);
    if (status != null) {
      result = true;
      updateListStatus(status);
      if (mounted)
        setState(() {
          modifyEpisodes = false;
          episodeController.text = status.numEpisodesWatched.toString();
          statusValue = status.status;
        });
    } else {
      showToast(S.current.Couldnt_Update);
      if (mounted)
        setState(() {
          modifyEpisodes = false;
        });
    }
    updateParent(result);
  }

  updateVolumeCount({int? volumes, int? add}) async {
    bool result = false;
    int _volumes = volumes ?? (int.tryParse(volumesController.text) ?? 0);
    _volumes += add ?? 0;
    if (_volumes < 0) {
      showToast(S.current.Negative_volumes_not_allowed);
      return;
    }

    if ((contentDetailed is MangaDetailed) &&
        contentDetailed?.numVolumes != null &&
        contentDetailed.numVolumes != 0 &&
        _volumes > contentDetailed.numVolumes) {
      showToast(S.current.Maximum_reached);
      return;
    }

    if (mounted)
      setState(() {
        modifyVolumes = true;
      });
    var content = contentDetailed;
    if (contentDetailed is BaseNode) {
      content = contentDetailed?.content;
    }
    var status = await MalUser.updateMyMangaListStatus(content.id,
        numVolumesRead: _volumes);
    if (status != null) {
      result = true;
      updateListStatus(status);
      if (mounted)
        setState(() {
          modifyVolumes = false;
          volumesController.text = status.numVolumesRead.toString();
        });
    } else {
      showToast(S.current.Couldnt_Update);
      if (mounted)
        setState(() {
          modifyVolumes = false;
        });
    }
    updateParent(result);
  }

  updateChapterCount({int? chapters, int? add}) async {
    bool result = false;
    int _chapters = chapters ?? (int.tryParse(chapterController.text) ?? 0);
    _chapters += add ?? 0;
    if (_chapters < 0) {
      showToast(S.current.Negative_chapters_not_allowed);
      return;
    }

    if ((contentDetailed is MangaDetailed) &&
        contentDetailed?.numChapters != null &&
        contentDetailed.numChapters != 0 &&
        _chapters > contentDetailed.numChapters) {
      showToast(S.current.Maximum_reached);
      return;
    }

    if (mounted)
      setState(() {
        modifyChapters = true;
      });
    var content = contentDetailed;
    if (contentDetailed is BaseNode) {
      content = contentDetailed?.content;
    }
    var status = await MalUser.updateMyMangaListStatus(content.id,
        numChaptersRead: _chapters);
    if (status != null) {
      result = true;
      updateListStatus(status);
      if (mounted)
        setState(() {
          modifyChapters = false;
          chapterController.text = status.numChaptersRead.toString();
        });
    } else {
      showToast(S.current.Couldnt_Update);
      if (mounted)
        setState(() {
          modifyChapters = false;
        });
    }
    updateParent(result);
  }

  Future<void> updateWatchingStatus(String value) async {
    bool result = false;
    int? _episodes;
    String? _startDate, _endDate;
    if (value.equals(statusValue)) {
      return;
    }
    if (!await hasConnection()) {
      showToast(S.current.No_Connection);
      return;
    }
    if (mounted)
      setState(() {
        modifyStatus = true;
      });

    var content = contentDetailed;
    if (contentDetailed is BaseNode) {
      content = contentDetailed?.content;
    }

    if ((content is AnimeDetailedMixin)) {
      if (content?.numEpisodes != null &&
          (content.numEpisodes != 0) &&
          value.equals("completed")) {
        _episodes = content.numEpisodes;
      }
    }
    if (content is AnimeDetailed && user.pref.autoAddStartEndDate) {
      if (value.equals("watching") && content.myListStatus?.startDate == null) {
        _startDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
      }
      if (value.equals("completed") &&
          content.myListStatus?.finishDate == null) {
        _endDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
      }
    }

    var status;

    if (widget.category.equals("anime")) {
      status = await MalUser.updateMyAnimeListStatus(
        content.id,
        status: value,
        numEpisodesWatched: _episodes,
        endDate: _endDate,
        startDate: _startDate,
      );
    } else {
      status = await MalUser.updateMyMangaListStatus(content.id, status: value);
    }
    if (status != null) {
      result = true;
      updateListStatus(status);
      if (mounted)
        setState(() {
          modifyStatus = false;
          statusValue = status.status;
          if (status is MyAnimeListStatus) {
            episodeController.text = status.numEpisodesWatched.toString();
            startDate = status.startDate;
            finishDate = status.finishDate;
          }
        });
    } else {
      showToast(S.current.Couldnt_Update);
      if (mounted)
        setState(() {
          modifyStatus = false;
        });
    }
    updateParent(result);
  }

  void updateRatingStatus(int value) async {
    bool result = false;
    if (value == starValue) {
      return;
    }
    if (!await hasConnection()) {
      showToast(S.current.No_Connection);
      return;
    }
    if (mounted)
      setState(() {
        modifyStars = true;
      });
    var content = contentDetailed;
    if (contentDetailed is BaseNode) {
      content = contentDetailed?.content;
    }
    var status;
    if (widget.category.equals("anime")) {
      status = await MalUser.updateMyAnimeListStatus(content.id, score: value);
    } else {
      status = await MalUser.updateMyMangaListStatus(content.id, score: value);
    }
    if (status != null) {
      result = true;
      updateListStatus(status);
      if (mounted)
        setState(() {
          modifyStars = false;
          starValue = status.score;
        });
    } else {
      showToast(S.current.Couldnt_Update);
      if (mounted)
        setState(() {
          modifyStars = false;
        });
    }
    updateParent(result);
  }

  checkForUpdatesDuringBuild() {
    starValue = contentDetailed?.myListStatus?.score?.round();
    statusValue = contentDetailed?.myListStatus?.status;
    initComplete = true;
    try {
      if (widget.category.equals("anime")) {
        episodeController.text =
            (contentDetailed?.myListStatus?.numEpisodesWatched == null
                    ? "0"
                    : contentDetailed?.myListStatus?.numEpisodesWatched
                        ?.toString()) ??
                '';
      } else {
        chapterController
            .text = (contentDetailed?.myListStatus?.numChaptersRead == null
                ? "0"
                : contentDetailed?.myListStatus?.numChaptersRead?.toString()) ??
            '';
        volumesController
            .text = (contentDetailed?.myListStatus?.numVolumesRead == null
                ? "0"
                : contentDetailed?.myListStatus?.numVolumesRead?.toString()) ??
            '';
      }
    } catch (e) {}
  }

  updateAdvancedStatus(
      {bool? isRewatching,
      bool? isRereading,
      int? timesRewatched,
      int? timesReread,
      int? rewatchValue,
      int? rereadValue,
      String? startDate,
      int? priority,
      String? comments,
      String? tags,
      required Function onDone,
      String? finishDate}) async {
    if (mounted) setState(() {});
    FocusScope.of(context).unfocus();
    var status;
    bool result = false;
    var content = contentDetailed;
    if (contentDetailed is BaseNode) {
      content = contentDetailed?.content;
    }
    if (widget.category.equals("anime")) {
      status = await MalUser.updateMyAnimeListStatus(content.id,
          endDate: finishDate,
          isRewatching: isRewatching,
          numTimesRewatched: timesRewatched,
          priority: priority,
          comments: comments,
          tags: tags,
          rewatchValue: rewatchValue,
          startDate: startDate);
    } else {
      status = await MalUser.updateMyMangaListStatus(content.id,
          isRereading: isRereading,
          numTimesReread: timesReread,
          priority: priority,
          comments: comments,
          tags: tags,
          endDate: finishDate,
          startDate: startDate,
          rereadValue: rereadValue);
    }
    onDone();
    if (status != null) {
      result = true;
      contentDetailed?.myListStatus = status;
      updateListStatus(status);
    } else {
      showToast(S.current.Couldnt_Update);
    }
    if (mounted) setState(() {});
    updateParent(result);
  }

  Future<void> deleteFromList() async {
    var result = await showConfirmationDialog(
      context: context,
      alertTitle: S.current.Item_delete_confi,
      desc: S.current.Item_delete_desc,
    );
    if (!result) {
      return;
    }
    _loading = true;
    if (mounted) setState(() {});
    var content = contentDetailed;
    if (contentDetailed is BaseNode) {
      content = contentDetailed?.content;
    }
    if (await MalUser.deleteFromList(content.id, category: widget.category)) {
      showAdvancedEdit = false;
      isListStatusOpen = true;
      contentDetailed.myListStatus = null;
      reset();
      if (widget.onDelete != null) widget.onDelete!();
      updateParent(true);
    } else {
      updateParent(false);
      showToast(S.current.Couldnt_Delete);
    }
    onAdvancedEdit();
    _loading = false;
    if (mounted) setState(() {});
  }

  bool get isFloating => widget.editMode == EditMode.floating;

  @override
  Widget build(BuildContext context) {
    if (starValue == null && !initComplete && widget.isCacheRefreshed) {
      contentDetailed = widget.contentDetailed;
      checkForUpdatesDuringBuild();
    }
    var _build = Container(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // additionalWidget,
            _heroWithTag("bottomnavbar")
          ],
        ),
      ),
    );

    if (widget.applyPopScope)
      return WillPopScope(
          child: _build,
          onWillPop: () async {
            if (showAdvancedEdit) {
              if (mounted)
                setState(() {
                  showAdvancedEdit = false;
                });
              return false;
            }
            return true;
          });
    else
      return _build;
  }

  Widget _heroWithTag(String tag) {
    if (widget.applyHero) {
      return Hero(tag: tag, child: animatedContainer);
    } else {
      return animatedContainer;
    }
  }

  Widget get animatedContainer => AnimatedContainer(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeIn,
        padding: EdgeInsets.symmetric(
            horizontal: isFloating && widget.category.equals("anime") ? 7 : 2,
            vertical: 0),
        constraints: BoxConstraints(minHeight: isFloating ? 120 : 100),
        child: Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          child: editChild,
        ),
      );

  Widget get editChild =>
      ((contentDetailed == null || !widget.isCacheRefreshed) ||
              !cacheUpdated ||
              _loading)
          ? Center(child: loadingCenter())
          : (!showAddOptions && contentDetailed.myListStatus?.status == null)
              ? Container(
                  width: double.infinity,
                  height: 60,
                  child: Center(
                      child: PlainButton(
                    onPressed: () {
                      if (user.status != AuthStatus.AUTHENTICATED) {
                        gotoPage(
                            context: context,
                            newPage: HomeScreen(
                              pageIndex: 2,
                            ));
                      } else if (mounted) {
                        _addToList();
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                    child: Text(
                      user.status != AuthStatus.AUTHENTICATED
                          ? S.current.Login_Add_to_List
                          : S.current.Add_to_List,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16),
                    ),
                  )),
                )
              : contentStatusWidget();

  void _addToList() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }
    await updateWatchingStatus(
        widget.category.equals('anime') ? 'watching' : 'reading');
    showAddOptions = true;
    _loading = false;
    setState(() {});
  }

  Widget get additionalWidget => widget.showAdditional
      ? Container(
          width: 60,
          height: 20,
          child: PlainButton(
            onPressed: () {
              Navigator.pop(context);
            },
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    topLeft: Radius.circular(14))),
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 24,
            ),
          ),
        )
      : const SizedBox();

  Widget contentStatusWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onVerticalDragUpdate: (details) {
            if (animationPending) {
              return;
            }
            animationPending = true;
            Future.delayed(const Duration(milliseconds: 300))
                .then((value) => animationPending = false);
            if (mounted)
              setState(() {
                if (details.delta.dy < 0) {
                  showAdvancedEdit = true;
                } else {
                  showAdvancedEdit = false;
                }
                onAdvancedEdit();
                isListStatusOpen = true;
              });
          },
          child: Container(
            width: double.infinity,
            height: 20,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (mounted)
                  setState(() {
                    showAdvancedEdit = !showAdvancedEdit;
                    isListStatusOpen = true;
                  });
                onAdvancedEdit();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                child: Icon(
                  (!showAdvancedEdit
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        !widget.showAdditional
            ? const SizedBox()
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 7),
                child: title(
                    ((contentDetailed is Node)
                        ? (contentDetailed?.title ?? "Title ?")
                        : (widget?.contentDetailed?.content?.title ??
                            "Title ?")),
                    align: TextAlign.center),
              ),
        ExpandedSection(
            expand: showAdvancedEdit,
            child: sectionHeading(S.current.Your_List_Status,
                isOpen: showAdvancedEdit, onChange: () {
              if (mounted)
                setState(() {
                  showAdvancedEdit = !showAdvancedEdit;
                });
              onAdvancedEdit();
            })),
        widget.category.equals("anime")
            ? animeStatusWidget()
            : mangaStatusWidget(),
        ExpandedSection(
          expand: showAdvancedEdit,
          child: advancedWidget,
        ),
        _deleteButton,
        SB.h10,
      ],
    );
  }

  Widget sectionHeading(String heading,
      {bool isOpen = true,
      VoidCallback? onChange,
      MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start}) {
    return InkWell(
      onTap: () {
        if (onChange != null) onChange();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: mainAxisAlignment == MainAxisAlignment.start ? 10 : 0,
            vertical: 10),
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            if (onChange != null)
              IconButton(
                  onPressed: () {
                    onChange();
                  },
                  icon: Icon(isOpen
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right)),
            title(
              heading,
              align: TextAlign.center,
              fontSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget get advancedWidget => Form(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeading(
                  (widget.category.equals('anime') ? 'Rewatch' : 'Reread') +
                      ' Status',
                  isOpen: isReStatusOpen, onChange: () {
                if (mounted)
                  setState(() {
                    isReStatusOpen = !isReStatusOpen;
                  });
              }),
              ExpandedSection(
                expand: isReStatusOpen,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: rewatchWidget,
                ),
              ),
              sectionHeading(S.current.Dates_Priority, isOpen: isDatesOpen,
                  onChange: () {
                if (mounted)
                  setState(() {
                    isDatesOpen = !isDatesOpen;
                  });
              }),
              ExpandedSection(
                expand: isDatesOpen,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: dateStatusWidget,
                ),
              ),
              sectionHeading(S.current.Others, isOpen: isOthersOpen,
                  onChange: () {
                if (mounted)
                  setState(() {
                    isOthersOpen = !isOthersOpen;
                  });
              }),
              ExpandedSection(
                expand: isOthersOpen,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: othersWidget,
                ),
              ),
              SB.h20
            ],
          ),
        ),
      );

  Widget get _divider => Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Divider(thickness: 1));

  Widget get othersWidget => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          field(
              S.current.Comments,
              _modifyWidget(
                modifyComments,
                TextFormFilter(
                    onFieldSubmitted: (value) {
                      modifyComments = true;
                      updateAdvancedStatus(
                          comments: value,
                          onDone: () {
                            modifyComments = false;
                          });
                    },
                    option: FilterOption(
                        value: contentDetailed?.myListStatus?.comments,
                        fieldName: "Comments")),
              ),
              null,
              null,
              CrossAxisAlignment.start,
              EdgeInsets.only(left: 20, bottom: 8)),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: field(
                  S.current.Tags,
                  _modifyWidget(
                    modifyTags,
                    TextFormFilter(
                        onFieldSubmitted: (value) {
                          modifyTags = true;
                          updateAdvancedStatus(
                              tags: value,
                              onDone: () {
                                modifyTags = false;
                              });
                        },
                        option: FilterOption(
                            value:
                                (contentDetailed?.myListStatus?.tags != null &&
                                        contentDetailed
                                            .myListStatus.tags.isNotEmpty)
                                    ? contentDetailed?.myListStatus?.tags[0]
                                    : '',
                            fieldName: "Tags")),
                  ),
                  null,
                  null,
                  CrossAxisAlignment.start,
                  EdgeInsets.only(left: 20, bottom: 8))),
        ],
      );

  Widget get _deleteButton {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SB.w10,
        ShadowButton(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          onPressed: () => deleteFromList(),
          child: iconAndText(Icons.delete, S.current.Delete_from_List),
        ),
        SB.w10,
      ],
    );
  }

  Widget get dateStatusWidget => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          field(
            S.current.Start_Date,
            _modifyWidget(
              modifyStartDate,
              SelectDate(
                onChangedFormatted: (value) {
                  modifyStartDate = true;
                  updateAdvancedStatus(
                      startDate: value,
                      onDone: () {
                        modifyStartDate = false;
                      });
                },
                selectDate:
                    startDate ?? contentDetailed?.myListStatus?.startDate,
              ),
            ),
          ),
          field(
            S.current.Finish_Date,
            _modifyWidget(
              modifyFinishDate,
              SelectDate(
                onChangedFormatted: (value) {
                  modifyFinishDate = true;
                  updateAdvancedStatus(
                      finishDate: value,
                      onDone: () {
                        modifyFinishDate = false;
                      });
                },
                selectDate:
                    finishDate ?? contentDetailed?.myListStatus?.finishDate,
              ),
            ),
          ),
          field(
              S.current.Priority,
              _modifyWidget(
                  modifyPriority,
                  SelectButton(
                    iconToUse: Icons.arrow_drop_down,
                    onChanged: (value) {
                      modifyPriority = true;
                      updateAdvancedStatus(
                          priority: int.tryParse(value),
                          onDone: () {
                            modifyPriority = false;
                          });
                    },
                    showSelectWhenNull: true,
                    displayValues: [
                      S.current.Low,
                      S.current.Medium,
                      S.current.High
                    ],
                    selectedOption:
                        contentDetailed?.myListStatus?.priority?.toString(),
                    options: List.generate(3, (i) => (i).toString()),
                  )),
              S.current.Priority_level_qn)
        ],
      );

  Widget get rewatchWidget => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          field(
              (widget.category.equals('anime')
                  ? S.current.Rewatching
                  : S.current.Rereading),
              _modifyWidget(
                  modifyReStatus,
                  ToggleButton(
                    padding: EdgeInsets.zero,
                    toggleValue: widget.category.equals('anime')
                        ? (contentDetailed?.myListStatus?.isRewatching ?? false)
                        : (contentDetailed?.myListStatus?.isRereading ?? false),
                    onToggled: (value) {
                      modifyReStatus = true;
                      if (widget.category.equals('anime')) {
                        updateAdvancedStatus(
                            isRewatching: value,
                            onDone: () {
                              modifyReStatus = false;
                            });
                      } else {
                        updateAdvancedStatus(
                            isRereading: value,
                            onDone: () {
                              modifyReStatus = false;
                            });
                      }
                    },
                  ))),
          field(
            (widget.category.equals('anime')
                ? S.current.Times_Rewatched
                : S.current.Times_Reread),
            plusMinusWidget(
              (value) {
                modifyReStatus = true;
                if (widget.category.equals('anime')) {
                  updateAdvancedStatus(
                      timesRewatched: (value),
                      onDone: () {
                        modifyReStatus = false;
                      });
                } else {
                  updateAdvancedStatus(
                      timesReread: (value),
                      onDone: () {
                        modifyReStatus = false;
                      });
                }
              },
              initialValue: widget.category.equals('anime')
                  ? ((contentDetailed?.myListStatus?.numTimesRewatched ?? 0)
                      ?.toString())
                  : ((contentDetailed?.myListStatus?.numTimesReread ?? 0)
                      ?.toString()),
              modify: modifyReStatus,
              onSubmit: (value) {
                modifyReStatus = true;
                if (widget.category.equals('anime')) {
                  updateAdvancedStatus(
                      timesRewatched: int.tryParse(value),
                      onDone: () {
                        modifyReStatus = false;
                      });
                } else {
                  updateAdvancedStatus(
                      timesReread: int.tryParse(value),
                      onDone: () {
                        modifyReStatus = false;
                      });
                }
              },
            ),
          ),
          field(
            (widget.category.equals('anime')
                    ? S.current.Rewatch
                    : S.current.Reread) +
                S.current.Value,
            _modifyWidget(
                modifyReStatus,
                SelectButton(
                  iconToUse: Icons.arrow_drop_down,
                  onChanged: (value) {
                    modifyReStatus = true;
                    if (widget.category.equals('anime')) {
                      updateAdvancedStatus(
                          rewatchValue: int.tryParse(value),
                          onDone: () {
                            modifyReStatus = false;
                          });
                    } else {
                      updateAdvancedStatus(
                          rereadValue: int.tryParse(value),
                          onDone: () {
                            modifyReStatus = false;
                          });
                    }
                  },
                  showSelectWhenNull: true,
                  displayValues: [
                    S.current.Very_Low,
                    S.current.Low,
                    S.current.Medium,
                    S.current.High,
                    S.current.Very_High
                  ],
                  selectedOption: widget.category.equals('anime')
                      ? contentDetailed?.myListStatus?.rewatchValue?.toString()
                      : contentDetailed?.myListStatus?.rereadValue?.toString(),
                  options: List.generate(5, (i) => (i).toString()),
                )),
          )
        ],
      );

  Widget field(String text, Widget child,
      [String? toolTip,
      double? height = 40,
      CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
      EdgeInsetsGeometry padding = EdgeInsets.zero]) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          children: [
            Padding(
              padding: padding,
              child: title(text),
            ),
            if (toolTip != null)
              ToolTipButton(
                message: toolTip,
                child: Icon(Icons.info, size: 12),
                padding: EdgeInsets.only(left: 5, top: 2),
              )
          ],
        ),
        const SizedBox(height: 10),
        Container(height: height, child: child)
      ],
    );
  }

  Widget _modifyWidget(bool modify, Widget child) {
    return modify
        ? Container(
            height: 40,
            // padding: EdgeInsets.only(top: 7),
            child: Center(
              child: loadingCenter(),
            ),
          )
        : child;
  }

  Widget animeStatusWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: expandedChild(S.current.Status, statusWidget())),
                SB.w20,
                Expanded(
                    child: expandedChild(
                        S.current.Episodes_seen, episodesWidget())),
              ],
            ),
            _barWidget(),
            SB.h20,
          ],
        ));
  }

  Widget expandedChild(String text, Widget child) {
    return Column(
      children: [
        SB.h10,
        Text(text),
        SB.h10,
        SizedBox(width: double.infinity, child: child),
      ],
    );
  }

  Widget _barWidget() {
    final value = myStarMap[starValue];
    final keys = myStarMap.keys.toList();
    return Column(
      children: [
        SB.h20,
        Text('${S.current.Score}${value == null ? '' : ' · ${value}'}'),
        SB.h15,
        SizedBox(
          height: 45.0,
          child: modifyStars
              ? loadingCenter()
              : ScrollablePositionedList.builder(
                  itemScrollController: itemScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: ClampingScrollPhysics(),
                  initialAlignment: 0.5,
                  padding: EdgeInsets.symmetric(horizontal: 160.0),
                  initialScrollIndex: keys.indexOf(starValue ?? 0),
                  itemCount: keys.length,
                  itemBuilder: (context, e) =>
                      _buildScoreButton(keys, e, context),
                ),
        ),
      ],
    );
  }

  Padding _buildScoreButton(List<int> keys, int e, BuildContext context) {
    final value = keys[e];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ShadowButton(
        onPressed: () async {
          itemScrollController.scrollTo(
            index: e,
            alignment: 0.5,
            duration: const Duration(milliseconds: 200),
          );
          updateRatingStatus(value);
        },
        child: Text(value == 0 ? S.current.Select : value.toString()),
        padding: EdgeInsets.zero,
        shape: value == starValue
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
                side: BorderSide(
                    color: Theme.of(context).dividerColor, width: 1.0))
            : RoundedRectangleBorder(),
      ),
    );
  }

  Widget mangaStatusWidget() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                expandedChild(
                  S.current.Reading_Status,
                  statusWidget(),
                ),
                SB.h5,
                Row(
                  children: [
                    Expanded(
                      child: expandedChild(
                          "${S.current.Chapters} " +
                              ((!(contentDetailed is MangaDetailed) ||
                                      contentDetailed?.numChapters == null ||
                                      contentDetailed.numChapters == 0)
                                  ? S.current.Read
                                  : "(${contentDetailed.numChapters})"),
                          chaptersWidget()),
                    ),
                    SB.w20,
                    Expanded(
                      child: expandedChild(
                          "${S.current.Volumes} " +
                              ((!(contentDetailed is MangaDetailed) ||
                                      contentDetailed?.numVolumes == null ||
                                      contentDetailed.numVolumes == 0)
                                  ? S.current.Read
                                  : "(${contentDetailed.numVolumes})"),
                          volumesWidget()),
                    ),
                  ],
                ),
                _barWidget(),
                SB.h20,
              ],
            ),
          ],
        ));
  }

  Widget episodesWidget() {
    return Container(
      // width: 150,
      height: 50,
      child: ShadowButton(
        onPressed: () {},
        padding: EdgeInsets.symmetric(horizontal: 3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (!modifyEpisodes) updateEpisodeCount(add: -1);
              },
              icon: Icon(Icons.remove),
            ),
            Flexible(
              child: SizedBox(
                child: modifyEpisodes
                    ? Center(
                        child: loadingCenter(),
                      )
                    : TextFormField(
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (value) {
                          updateEpisodeCount(episodes: int.tryParse(value));
                        },
                        controller: episodeController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            )),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            ))),
                      ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (!modifyEpisodes) updateEpisodeCount(add: 1);
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget volumesWidget() {
    return Container(
      // width: 150,
      height: 50,
      child: ShadowButton(
        onPressed: () {},
        padding: EdgeInsets.symmetric(horizontal: 3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (!modifyVolumes) updateVolumeCount(add: -1);
              },
              icon: Icon(Icons.remove),
            ),
            Flexible(
              child: SizedBox(
                child: modifyVolumes
                    ? Center(
                        child: loadingCenter(),
                      )
                    : TextFormField(
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (value) {
                          updateVolumeCount(volumes: int.tryParse(value));
                        },
                        controller: volumesController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            )),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            ))),
                      ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (!modifyVolumes) updateVolumeCount(add: 1);
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget chaptersWidget() {
    return Container(
      // width: 150,
      height: 50,
      child: ShadowButton(
        onPressed: () {},
        padding: EdgeInsets.symmetric(horizontal: 3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (!modifyChapters) updateChapterCount(add: -1);
              },
              icon: Icon(Icons.remove),
            ),
            Flexible(
              child: SizedBox(
                child: modifyChapters
                    ? Center(
                        child: loadingCenter(),
                      )
                    : TextFormField(
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (value) {
                          updateChapterCount(chapters: int.tryParse(value));
                        },
                        controller: chapterController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            )),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            ))),
                      ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (!modifyChapters) updateChapterCount(add: 1);
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget statusWidget() {
    final Widget child;
    Map<String, String> myStatusMap =
        widget.category.equals("anime") ? myAnimeStatusMap : myMangaStatusMap;
    if (modifyStatus)
      child = Center(
        child: loadingCenter(),
      );
    else
      child = SelectButton(
        options: myStatusMap.keys.toList(),
        displayValues: myStatusMap.values.toList(),
        selectedOption: statusValue,
        useShadowChild: true,
        popupText: S.current.Status,
        onChanged: (value) => updateWatchingStatus(value),
      );
    return SizedBox(
      height: 50,
      child: child,
    );
  }

  Widget plusMinusWidget(
    ValueChanged<int?> onChange, {
    required bool modify,
    Function(String)? onSubmit,
    String? initialValue,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return Container(
      height: 50,
      width: 120.0,
      child: ShadowButton(
        onPressed: () {},
        padding: EdgeInsets.symmetric(horizontal: 3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                onChange((int.tryParse(initialValue ?? "1") ?? 1) - 1);
              },
              icon: Icon(Icons.remove),
            ),
            Flexible(
              child: SizedBox(
                child: modify
                    ? Center(
                        child: loadingCenter(),
                      )
                    : TextFormField(
                        initialValue: initialValue,
                        keyboardType: keyboardType,
                        onFieldSubmitted: (value) {
                          onChange((int.tryParse(value) ?? 1) - 1);
                        },
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            )),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                              style: BorderStyle.none,
                            ))),
                      ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                onChange((int.tryParse(initialValue ?? "0") ?? 0) + 1);
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
