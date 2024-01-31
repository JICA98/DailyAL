import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/api/dalapi.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/extensions.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/pages/search/allrankingwidget.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:dailyanimelist/widgets/headerwidget.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dailyanimelist/widgets/loading/loadingcard.dart';
import 'package:dailyanimelist/widgets/shimmecolor.dart';
import 'package:dailyanimelist/widgets/slivers.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';

class AllGenreWidget extends StatelessWidget {
  final String category;
  const AllGenreWidget({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return StateFullFutureWidget<List<GenreType>>(
      done: (data) => _buildExpandableGenreCategories(data.data ?? [], context),
      loadingChild: _loading(),
      future: () => DalApi.i.getGenreTypes(category),
    );
  }

  Widget _loading() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (int i = 0; i < 3; ++i)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ShimmerColor(
                LoadingCard(
                  height: 120.0,
                  width: 140,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandableGenreCategories(
    List<GenreType> genreTypes,
    BuildContext context,
  ) {
    final map = genreTypes
        .where((e) => user.pref.nsfw || 'Explicit Genres'.notEquals(e.type))
        .fold(<String, List<MalGenre>>{}, (map, element) {
      var type = element.type ?? '';
      if (map.containsKey(type)) {
        map[type]!.addAll(element.genres ?? []);
      } else {
        map[type] = element.genres ?? [];
      }
      return map;
    });

    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: map.keys
            .toList()
            .asMap()
            .entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: imageTextCard(
                  context: context,
                  borderRadius: BorderRadius.circular(12.0),
                  onTap: () => _showGenresDialog(
                      context, e.value, map.values.toList()[e.key], category),
                  imageUrl:
                      '${CredMal.dalWeb}assets/genres/${e.value.replaceAll(' ', '_').toLowerCase()}_$category.webp',
                  text: e.value,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showGenresDialog(
    BuildContext context,
    String genreType,
    List<MalGenre> genres,
    String category,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        width: double.infinity,
        child: Material(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text(genreType),
                  pinned: true,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  actions: [CloseButton()],
                ),
                SB.lh20,
                ...genres
                    .map((g) => SliverWrapper(PlainButton(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        alignment: Alignment.centerLeft,
                        onPressed: () => onGenrePress(g, category, context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                convertGenre(g, category).replaceAll('_', ' ')),
                            // SB.h,
                            Text(
                              '${userCountFormat.format(g.count ?? 0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(fontSize: 9),
                            ),
                          ],
                        ))))
                    .toList(),
                SB.lh40,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
