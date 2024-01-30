import 'package:dailyanimelist/enums.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:flutter/material.dart';

class AllGenreWidget extends StatelessWidget {
  final String category;
  const AllGenreWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> genreTypeMap = Mal.genreTypeMap;
    return _buildExpandableGenreCategories(genreTypeMap, context);
  }

  Widget _buildExpandableGenreCategories(
    Map<String, List<String>> genreTypeMap,
    BuildContext context,
  ) {
    return ListView.builder(
      itemCount: genreTypeMap.length,
      itemBuilder: (context, index) {
        String genre = genreTypeMap.keys.elementAt(index);
        List<String> types = genreTypeMap[genre]!;
        return _buildExpandableGenreCategory(genre, types, context);
      },
    );
  }

  Widget _buildExpandableGenreCategory(
      String genre, List<String> types, BuildContext context) {
    return ExpansionTile(
      title: Text(genre),
      children: types.map((type) => _buildGenreType(type, context)).toList(),
    );
  }

  Widget _buildGenreType(String type, BuildContext context) {
    return ShadowButton(onPressed: () {}, child: Text(type));
  }
}
