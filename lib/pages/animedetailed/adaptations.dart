import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/util/pathutils.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';

class AdaptationsWidget extends StatelessWidget {
  final String imageUrl;
  final List<Node> nodes;
  const AdaptationsWidget({Key? key, required this.nodes, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 17.0),
        itemBuilder: (context, index) => Card(
          child: InkWell(
            onTap: () => DalPathUtils.navigateByNode(nodes[index]),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 160,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Opacity(
                        opacity: .1,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: imageUrl,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SB.h10,
                          Expanded(
                            child: title(
                              nodes[index].title,
                              opacity: 1,
                              fontSize: 13,
                              align: TextAlign.center,
                              textOverflow: TextOverflow.fade,
                            ),
                          ),
                          SB.h5,
                          title(nodes[index].nodeCategory,
                              align: TextAlign.center),
                          SB.h10,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        itemCount: nodes.length,
      ),
    );
  }
}
