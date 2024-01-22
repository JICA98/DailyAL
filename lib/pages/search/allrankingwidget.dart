import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:flutter/material.dart';
import 'package:dal_commons/dal_commons.dart';

class AllRankingWidget extends StatelessWidget {
  final String category;
  static const horizPadding = 20.0;
  static final radius = 12.0;
  static final borderRadius = BorderRadius.circular(radius);
  const AllRankingWidget({required this.category, Key? key}) : super(key: key);

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

    final _rankingMap = isAnime ? desiredTopAnimeOrder : desiredMangaRankingMap;
    final _rankingTypeMap = isAnime ? rankingMap : mangaRankingMap;
    return Container(
      height: 165,
      child: ListView.builder(
        itemCount: _rankingMap.length,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: horizPadding),
        itemBuilder: (context, index) {
          final entry = _rankingMap.entries.elementAt(index);
          final type = _rankingTypeMap[entry.key];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: 140,
              padding: const EdgeInsets.only(bottom: 25),
              child: Material(
                color: Theme.of(context).cardColor,
                borderRadius: borderRadius,
                child: InkWell(
                  onTap: () => _onCategoryTap(type, context),
                  borderRadius: borderRadius,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: borderRadius,
                          child: Opacity(
                            opacity: .3,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  '${CredMal.dalWeb}assets/${type}_$category.jpg',
                            ),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: title(
                            entry.value,
                            opacity: 1,
                            fontSize: 16,
                            align: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
