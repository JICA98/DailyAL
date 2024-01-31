import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/extensions.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:flutter/material.dart';
import 'package:dal_commons/dal_commons.dart';

class AllRankingWidget extends StatelessWidget {
  final String category;
  final bool fullScreen;
  static const horizPadding = 20.0;
  static final radius = 12.0;
  static final borderRadius = BorderRadius.circular(radius);
  const AllRankingWidget({
    required this.category,
    this.fullScreen = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAnime = category.equals('anime');
    void _onCategoryTap(String? type, BuildContext context) {
      if (type != null && type.equals('ona')) {
        gotoPage(
          context: context,
          newPage: GeneralSearchScreen(
            filterOutputs: {
              CustomFilters.animeTypeFilter.apiFieldName!:
                  CustomFilters.animeTypeFilter..value = type
            },
            category: category,
            autoFocus: false,
          ),
        );
      } else {
        gotoPage(
          context: context,
          newPage: GeneralSearchScreen(
            category: category,
            searchQuery: '#$type' + (isAnime ? '' : '@manga'),
            autoFocus: false,
          ),
        );
      }
    }

    Widget _buildBody(BuildContext context, Map<Enum, String> rankingMap,
        Map<Enum, String> rankingTypeMap) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            children: rankingMap.keys
                .chunked(2)
                .map(
                  (e) => SizedBox(
                    height: 140,
                    child: Row(
                      children: e.map(
                        (e) {
                          final type = rankingTypeMap[e];
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: imageTextCard(
                                context: context,
                                borderRadius: borderRadius,
                                bottomPadding: EdgeInsets.symmetric(vertical: 5.0),
                                onTap: () => _onCategoryTap(type, context),
                                imageUrl:
                                    '${CredMal.dalWeb}assets/${type}_$category.jpg',
                                text: rankingMap[e]!,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    final _rankingMap = isAnime ? desiredTopAnimeOrder : desiredMangaRankingMap;
    final _rankingTypeMap = isAnime ? rankingMap : mangaRankingMap;
    if (fullScreen) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${S.current.Categories} $category',
          ),
        ),
        body: _buildBody(context, _rankingMap, _rankingTypeMap),
      );
    }

    return Container(
      height: 130,
      child: ListView.builder(
        itemCount: _rankingMap.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: horizPadding),
        itemBuilder: (context, index) {
          final entry = _rankingMap.entries.elementAt(index);
          final type = _rankingTypeMap[entry.key];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: imageTextCard(
              context: context,
              borderRadius: borderRadius,
              onTap: () => _onCategoryTap(type, context),
              imageUrl: '${CredMal.dalWeb}assets/${type}_$category.jpg',
              text: entry.value,
            ),
          );
        },
      ),
    );
  }
}

Widget imageTextCard({
  required BuildContext context,
  required BorderRadius borderRadius,
  required VoidCallback onTap,
  required String imageUrl,
  required String text,
  Widget? child,
  double width = 140.0,
  EdgeInsetsGeometry? bottomPadding,
}) {
  return Container(
    width: width,
    padding: bottomPadding ?? const EdgeInsets.only(bottom: 25),
    child: Material(
      color: Theme.of(context).cardColor,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: Opacity(
                  opacity: .3,
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: child ??
                    title(
                      text,
                      opacity: .8,
                      fontSize: 15.0,
                      align: TextAlign.center,
                      colorVal: Colors.white.value,
                    ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
