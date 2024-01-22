import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/screens/generalsearchscreen.dart';
import 'package:dailyanimelist/widgets/search/filtermodal.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/extensions.dart';
import 'package:dal_commons/dal_commons.dart';

class TagsWidget extends StatelessWidget {
  final List<String> tags;
  final String category;
  const TagsWidget({Key? key, required this.tags, this.category = "featured"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        height: 34,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          children: tags
              .map<Widget>(
                (e) => Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      onTap: (e.toString().toLowerCase().equals("spoiler") ||
                              (category.equals("featured") &&
                                  !ForumConstants.tags.containsKeyIgnoreCase(e))
                          ? null
                          : () {
                              gotoPage(
                                  context: context,
                                  newPage: GeneralSearchScreen(
                                    autoFocus: false,
                                    category: category,
                                    filterOutputs:
                                        generateFilters(e.toString()),
                                    showBackButton: true,
                                  ));
                            }),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 20,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          e,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Map<String, FilterOption> generateFilters(String tag) {
    return {
      "tags": CustomFilters.featuredFilters.first..value = tag,
    };
  }
}
