import 'package:collection/collection.dart';
import 'package:dailyanimelist/api/malapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/screens/seasonal_screen.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:dal_commons/dal_commons.dart';

void onStudioTap(AnimeStudio e, BuildContext context) {
  final animeStudio = Mal.animeStudios[e.id];
  gotoPage(
      context: context,
      newPage: GeneralSearchScreen(
        autoFocus: false,
        showBackButton: true,
        category: 'anime',
        filterOutputs: {
          CustomFilters.animeStudiosFilter.apiFieldName!:
              CustomFilters.animeStudiosFilter
                ..value = (animeStudio ?? e.name?.replaceAll(' ', '_'))
        },
      ));
}

void onMediaTypeTap(
  String mediaType,
  String category,
  BuildContext context,
) {
  bool isValidSearchableType = rankingMap.values.contains(mediaType);
  if (isValidSearchableType) {
    gotoPage(
        context: context,
        newPage: GeneralSearchScreen(
          searchQuery: "#$mediaType",
          autoFocus: false,
          category: category,
          showBackButton: true,
        ));
  }
}

class MoreInfoAnime extends StatelessWidget {
  final dynamic contentDetailed;
  final String category;
  final double horizPadding;
  final bool isModal;
  final List<AdditionalTitle>? additionalTitles;
  MoreInfoAnime({
    this.contentDetailed,
    this.category = "anime",
    this.horizPadding = 15.0,
    this.isModal = false,
    this.additionalTitles,
  });
  @override
  Widget build(BuildContext context) {
    String? broadcastTime;

    if (category.equals('anime') && contentDetailed?.broadcast != null) {
      broadcastTime = MalApi.getFormattedAiringDate(contentDetailed.broadcast);
    }

    void _onPremierTap() {
      if (category.equals("anime")) {
        final seasonType =
            seasonMapInverse[contentDetailed?.startSeason?.season?.toString()];
        final year =
            int.tryParse(contentDetailed?.startSeason?.year?.toString() ?? '');
        if (seasonType != null && year != null)
          gotoPage(
            context: context,
            newPage: SeasonalScreen(seasonType: seasonType, year: year),
          );
      }
    }

    Widget _fieldChild(
      String label,
      Widget child, [
      VoidCallback? onTap,
    ]) {
      return Card(
        elevation: onTap != null ? 4.0 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.color
                          ?.withOpacity(.8)),
                ),
                SB.h10,
                child,
              ],
            ),
          ),
        ),
      );
    }

    Widget _field(
      String label,
      String content, [
      VoidCallback? onTap,
    ]) {
      return _fieldChild(
        label,
        Text(content),
        onTap,
      );
    }

    Widget _fieldList<T>(
      String label,
      List<T> list,
      void Function(T item) onItemTap,
      String Function(T item) itemName,
    ) {
      final child = Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: list
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: ShadowButton(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      onPressed: () => onItemTap(e),
                      child: Text(
                        itemName(e),
                        style: Theme.of(context).textTheme.bodySmall,
                      )),
                ))
            .toList(),
      );

      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SB.h10,
            child,
          ],
        ),
      );
    }

    List<Widget> _genreWidgets() {
      final List<MalGenre> genres = contentDetailed.genres ?? [];
      final items = genres
          .map((e) =>
              MapEntry(e, Mal.getGenreCategory(convertGenre(e, category))))
          .toList();
      final typeMap = groupBy<MapEntry<MalGenre, String>, String>(
          items, (item) => item.value);
      return typeMap.entries
          .map((e) => _fieldList<MalGenre>(
                e.key,
                e.value.map((e_) => e_.key).toList(),
                (e_) => onGenrePress(e_, category, context),
                (e_) => convertGenre(e_, category).replaceAll('_', ' '),
              ))
          .toList();
    }

    final scrollView = SingleChildScrollView(
        child: Padding(
      padding:
          EdgeInsets.only(left: horizPadding, right: horizPadding, top: 10),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _field(
            S.current.Media,
            ((contentDetailed.mediaType?.toString().toUpperCase() ?? "?")),
            () => onMediaTypeTap(
                contentDetailed.mediaType?.toString() ?? "", category, context),
          ),
          _field(
            category.equals("anime") ? "Episodes" : "Volumes",
            (category.equals("anime")
                ? (contentDetailed.numEpisodes != 0
                    ? (contentDetailed.numEpisodes?.toString() ??
                        S.current.UNKNOWN)
                    : S.current.UNKNOWN)
                : (contentDetailed.numVolumes != 0
                    ? (contentDetailed.numVolumes?.toString() ??
                        S.current.UNKNOWN)
                    : S.current.UNKNOWN)),
          ),
          _field(
            S.current.Status,
            (contentDetailed.status.toString().standardize() ??
                S.current.UNKNOWN),
          ),
          _field(
            category.equals("anime")
                ? "${S.current.Premiered} "
                : "${S.current.Chapters} ",
            category.equals("anime")
                ? (((contentDetailed?.startSeason?.season
                            ?.toString()
                            .capitalize() ??
                        "?") +
                    " " +
                    (contentDetailed?.startSeason?.year?.toString() ?? "?")))
                : (contentDetailed.numChapters != 0
                    ? (contentDetailed.numChapters?.toString() ??
                        S.current.UNKNOWN)
                    : S.current.UNKNOWN),
            category.equals("anime") ? _onPremierTap : null,
          ),
          _field(
            category.equals("anime")
                ? "${S.current.Aired} "
                : "${S.current.Published} ",
            (contentDetailed?.startDate?.toString().toDate() ?? "?") +
                " to " +
                (contentDetailed?.endDate?.toString().toDate() ?? '?'),
          ),
          if (category.equals('anime')) ...[
            _field(
              S.current.Source,
              (contentDetailed?.source?.toString().standardize() ?? "?"),
            ),
            if (broadcastTime != null)
              _field(
                S.current.Broadcast,
                broadcastTime,
              ),
            _field(
              S.current.Duration,
              (contentDetailed?.averageEpisodeDuration != null
                  ? (contentDetailed.averageEpisodeDuration / 60)
                          .round()
                          .toString() +
                      " min"
                  : "?"),
            ),
            _field(
              S.current.Rating,
              (contentDetailed?.rating
                      ?.toString()
                      .standardize()
                      ?.capitalize() ??
                  "?"),
            ),
          ] else
            _field(
              S.current.Serialization,
              ((contentDetailed.serialization == null ||
                      contentDetailed.serialization.length == 0)
                  ? "?"
                  : (contentDetailed.serialization?.map((e) => e.name)?.reduce(
                          (value, element) => value + "," + element)) ??
                      "?"),
            ),
          if (!nullOrEmpty(contentDetailed.alternateTitles?.synonyms))
            _field(
              S.current.Synonyms,
              (contentDetailed.alternateTitles.synonyms).join(','),
            ),
          _field(
            S.current.Title,
            contentDetailed.title +
                ", " +
                contentDetailed.alternateTitles.en +
                ", " +
                contentDetailed.alternateTitles.ja,
          ),
          if (category.equals('anime') && !nullOrEmpty(contentDetailed.studios))
            _fieldList<AnimeStudio>(
              S.current.Studios,
              contentDetailed.studios,
              (item) => onStudioTap(item, context),
              (item) => item.name ?? '?',
            ),
          if (category.equals('manga') && !nullOrEmpty(contentDetailed.authors))
            _fieldList<MangaAuthors>(
              S.current.Studios,
              contentDetailed.authors,
              (_) {},
              (e) =>
                  (e.author?.firstName ?? "?") +
                  " " +
                  (e.author?.lastName ?? "?") +
                  " (" +
                  (e.role ?? '?') +
                  " ) ",
            ),
          if (!nullOrEmpty(contentDetailed.genres)) ..._genreWidgets(),
          if (!nullOrEmpty(additionalTitles))
            _field(
              S.current.AdditionalTitles,
              additionalTitles!
                  .map((e) => '${e.language} ${e.title}')
                  .join(', '),
            ),
        ],
      ),
    ));

    if (isModal)
      return Scrollbar(
        interactive: true,
        child: scrollView,
      );
    else
      return scrollView;
  }
}
