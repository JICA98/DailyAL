import 'package:dal_commons/src/model/global/animenode.dart';
import 'package:dal_commons/src/model/global/node.dart' as dal;
import 'package:dal_commons/src/model/global/picture.dart';
import 'package:dal_commons/src/model/global/searchresult.dart';

class AllSearchResult extends SearchResult {
  final Map<String, List<BaseNode>?>? allData;

  AllSearchResult({this.allData});
}

class AddtionalNode extends dal.Node {
  String? additional;
  AddtionalNode({int? id, String? title, Picture? mainPicture, this.additional})
      : super(title: title, id: id, mainPicture: mainPicture);
}
