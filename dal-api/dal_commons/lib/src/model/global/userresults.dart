import 'package:dal_commons/src/model/global/animenode.dart';
import 'package:dal_commons/src/model/global/node.dart' as n;
import 'package:dal_commons/src/model/global/paging.dart';
import 'package:dal_commons/src/model/global/picture.dart';
import 'package:dal_commons/src/model/global/searchresult.dart';

class Content extends BaseNode {
  @override
  final MUser? content;

  Content(this.content);
}

class MUser extends n.Node {
  final String username;
  final String imgUrl;
  final String lastOnline;

  MUser(this.username, this.imgUrl, this.lastOnline)
      : super(
            title: username,
            mainPicture: Picture(large: imgUrl, medium: imgUrl));
}

class UserResult extends SearchResult {
  @override
  final List<Content>? data;
  @override
  Paging? paging;
  @override
  String? url;
  @override
  bool? fromCache;
  @override
  DateTime? lastUpdated;
  bool? isUser;

  UserResult(
      {this.data, this.url, this.paging, this.fromCache, this.lastUpdated, this.isUser});
}
