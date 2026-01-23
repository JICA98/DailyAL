import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:flutter/material.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:dailyanimelist/util/responsive_helper.dart';

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

    /// Get adaptive grid column count for category cards
    int _getCategoryGridCount(BuildContext context) {
      final screenSize = ResponsiveHelper.getScreenSize(context);
      return switch (screenSize) {
        ScreenSize.compact => 2, // Phone: 2 columns
        ScreenSize.medium => 3, // Small tablet: 3 columns
        ScreenSize.expanded => 4, // Large tablet: 4 columns
        ScreenSize.large => 5, // Desktop: 5 columns
        ScreenSize.extraLarge => 6, // Ultra-wide: 6 columns
      };
    }

    Widget _buildBody(BuildContext context, Map<Enum, String> rankingMap,
        Map<Enum, String> rankingTypeMap) {
      final entries = rankingMap.entries.toList();
      final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
      final crossAxisCount = _getCategoryGridCount(context);

      return GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 20.0,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6, // Wider cards for category images
        ),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final type = rankingTypeMap[entry.key];
          return imageTextCard(
            context: context,
            borderRadius: borderRadius,
            bottomPadding: EdgeInsets.zero,
            onTap: () => _onCategoryTap(type, context),
            imageUrl: '${CredMal.webAssetsUrl}${type}_$category.jpg',
            text: entry.value,
          );
        },
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
              imageUrl: '${CredMal.webAssetsUrl}${type}_$category.jpg',
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
                      colorVal: Theme.of(context).colorScheme.onSurface.value,
                    ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
