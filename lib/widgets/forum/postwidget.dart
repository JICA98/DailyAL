import 'package:dailyanimelist/api/credmal.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/widgets/forum/bbcodewidget.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../constant.dart';
import '../../main.dart';
import '../avatarwidget.dart';

class PostWidgetBuilder extends StatefulWidget {
  final List<ForumTopicPost>? postList;
  final AutoScrollController controller;
  final bool reverse;
  final int offset;
  final int postLimit;
  final bool showOnlyPosts;
  final Function(Set<ForumTopicPost>) onPostsSelected;
  const PostWidgetBuilder({
    Key? key,
    required this.postList,
    required this.controller,
    this.reverse = false,
    required this.onPostsSelected,
    required this.offset,
    required this.showOnlyPosts,
    required this.postLimit,
  }) : super(key: key);

  @override
  _PostWidgetBuilderState createState() => _PostWidgetBuilderState();
}

class _PostWidgetBuilderState extends State<PostWidgetBuilder> {
  List<ForumTopicPost> _postList = [];
  Set<ForumTopicPost> selectedPosts = {};

  @override
  void initState() {
    super.initState();
    _postList = widget.postList ?? [];
    if (widget.reverse) _postList = _postList.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) => wrapScrollTag(
            index: index,
            controller: widget.controller,
            highlightColor: Theme.of(context).highlightColor,
            child: PostWidget(
              post: _postList.elementAt(index),
              isShareStarted: selectedPosts.isNotEmpty,
              context: context,
              index: widget.reverse
                  ? (widget.offset + (widget.postLimit - 1) - index)
                  : (widget.offset + index),
              isSelected: selectedPosts.contains(_postList.elementAt(index)),
              onQuoteTapped: (id) async {
                int? scrollIndex = getScrollIndexFromId(id);
                if (scrollIndex != null) {
                  await widget.controller.scrollToIndex(scrollIndex,
                      preferPosition: AutoScrollPosition.middle,
                      duration: Duration(milliseconds: 400));
                  widget.controller.highlight(scrollIndex);
                  return null;
                } else {
                  //("Post not found!");
                  return id;
                }
              },
              onSelected: (post) {
                if (!widget.showOnlyPosts) {
                  selectedPosts.add(post);
                  widget.onPostsSelected(selectedPosts);
                  setState(() {});
                }
              },
              onUnSelected: (post) {
                selectedPosts.remove(post);
                widget.onPostsSelected(selectedPosts);
                setState(() {});
              },
              getForumPostFromPostId: (id, callback) {
                callback(getForumPostFromPostId(id));
              },
            )),
        childCount: _postList.length,
      ),
    );
  }

  ForumTopicPost? getForumPostFromPostId(int? postId) {
    if (widget.postList == null || widget.postList!.isEmpty || postId == null)
      return null;
    for (var i = 0; i < widget.postList!.length; i++) {
      var post = widget.postList![i];
      if (post.id == postId) {
        return post;
      }
    }

    return null;
  }

  int? getScrollIndexFromId(int? postId) {
    if (widget.postList == null || widget.postList!.isEmpty || postId == null)
      return null;
    for (var i = 0; i < widget.postList!.length; i++) {
      var post = widget.postList![i];
      if (post.id == postId) {
        return i;
      }
    }

    return null;
  }
}

class PostWidget extends StatefulWidget {
  final ForumTopicPost post;
  final BuildContext context;
  final Function(int) onQuoteTapped;
  final int index;
  final void Function(int?, Function(ForumTopicPost?)) getForumPostFromPostId;
  final Function(ForumTopicPost) onSelected;
  final Function(ForumTopicPost) onUnSelected;
  final bool isSelected;
  final bool isShareStarted;

  const PostWidget({
    Key? key,
    required this.post,
    required this.context,
    required this.index,
    required this.getForumPostFromPostId,
    required this.onSelected,
    required this.onUnSelected,
    this.isSelected = false,
    this.isShareStarted = false,
    required this.onQuoteTapped,
  }) : super(key: key);
  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with AutomaticKeepAliveClientMixin {
  late String body;
  String? signature;
  List<String> quoteBodyList = [];
  List<ForumTopicPost> quotedPostList = [];
  bool showFullPost = true;
  final int bodyLimit = 700;

  @override
  void initState() {
    super.initState();
    body = widget.post.body ?? '';
    signature = widget.post.signature;

    getDetails();
  }

  void getDetails() {
    if (signature != null) {
      signature = signature
          // .replaceAll("<br />", "")
          ?.replaceAll("[", "<")
          .replaceAll("]", ">")
          .replaceAll("[\'", "<\'");
    }
    if (body != null) {
      body = body
          // .replaceAll("<br />", "")
          .replaceAll("[", "<")
          .replaceAll("]", ">")
          .replaceAll("[\'", "<\'");
      // var unescape = new HtmlUnescape();
      // body =  unescape.convert(body);
      try {
        if (body.contains("<quote")) {
          var quote = body.substring(0, body.lastIndexOf("</quote>") + 8);
          int index = 0;
          var quoteIndexList = [];
          while (index < (quote.length - 7)) {
            var oq = quote.substring(index, index + 6);
            var cq = quote.substring(index, index + 8);
            if (oq.equals("<quote")) {
              quoteIndexList.add(index);
            }
            if (cq.equals("</quote>")) {
              int startIndex = quoteIndexList.removeLast();
              var quoteBody = quote.substring(startIndex, index);
              int quoteIndex = quoteBody.lastIndexOf("</quote>");
              if (quoteIndex == -1) {
                quoteIndex = quoteBody.lastIndexOf("message=") + 17;
              } else {
                quoteIndex += 8;
              }

              var qid = int.tryParse(quoteBody.substring(
                  quoteBody.indexOf("message=") + 8,
                  quoteBody.indexOf("message=") + 16));
              var quotePost;
              widget.getForumPostFromPostId(qid, (_post) {
                quotePost = _post;
              });
              var forumUsername;
              if (quoteBody.indexOf("<quote=") != -1 &&
                  quoteBody.indexOf("message=") != -1)
                forumUsername = quoteBody.substring(
                    quoteBody.indexOf("<quote=") + 7,
                    quoteBody.indexOf("message="));
              if (quotePost == null && qid != null && forumUsername != null) {
                quotePost = ForumTopicPost(
                    id: qid, createdBy: ForumUser(name: forumUsername));
              }
              if (forumUsername != null) {
                quotedPostList.add(quotePost);
                quoteBodyList.add(
                    quoteBody.substring(quoteIndex).replaceAll("<br />", ""));
                var qq = quote.substring(startIndex, index);
                if (quoteIndexList.isEmpty) {
                  body = body.replaceAll(qq, "");
                }
              }
            }
            index++;
          }

          // body = body.substring(body.lastIndexOf("</quote>") + 8);
        }
      } catch (e) {
        logDal(e);
      }
    }
    body = "<div> $body </div>";
    // if (body.length > bodyLimit) {
    //   showFullPost = false;
    // }
  }

  void onSelected() {
    widget.onSelected(widget.post);
  }

  void onUnSelected() {
    widget.onUnSelected(widget.post);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 0),
      duration: const Duration(milliseconds: 300),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isSelected
                ? () => onUnSelected()
                : widget.isShareStarted
                    ? () => onSelected()
                    : null,
            onLongPress: widget.isSelected ? null : () => onSelected(),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _forumUserLeading(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          _buildPopupMenu()
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 46),
                  child: quotePostWidget(
                    quoteBodyList: quoteBodyList,
                    quotedPostList: quotedPostList,
                  ),
                ),
                Container(
                  height:
                      (body.length > bodyLimit && !showFullPost) ? 150 : null,
                  padding: const EdgeInsets.only(left: 46),
                  child: ClipRRect(
                    child: BbcodeWidget(
                      body: body,
                    ),
                  ),
                ),
                !showFullPost
                    ? GestureDetector(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              showFullPost = true;
                            });
                          }
                        },
                        child: title("Read more..",
                            opacity: 1, fontWeight: FontWeight.bold),
                      )
                    : const SizedBox(),
              ],
            ),
          )),
    );
  }

  Row _forumUserLeading({bool disableTap = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedContainer(
          height: 40,
          width: 40,
          curve: Curves.easeIn,
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isSelected ? Theme.of(context).canvasColor : null,
              border: Border.all(
                  color: widget.isSelected
                      ? (Theme.of(context).textTheme.bodySmall?.color ??
                          Colors.grey)
                      : Theme.of(context).canvasColor,
                  width: 2)),
          child: widget.isSelected
              ? Center(
                  child: Icon(Icons.check),
                )
              : _avatarWidget(disableTap: disableTap),
        ),
        const SizedBox(
          width: 8,
        ),
        title(widget.post?.createdBy?.name ?? "Name ?", opacity: 1),
        if (!disableTap)
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: title(displayTimeAgo(widget.post.createdAt!), fontSize: 11),
          ),
      ],
    );
  }

  AvatarWidget _avatarWidget({bool disableTap = false}) {
    return AvatarWidget(
      username: widget?.post?.createdBy?.name,
      onTap: () {
        if (disableTap) return;
        if (widget?.post?.createdBy?.name != null) {
          showUserPage(
              context: context, username: widget.post.createdBy!.name!);
        }
      },
      url: widget.post?.createdBy?.id == null
          ? null
          : getUserImage(widget.post.createdBy!.id!),
    );
  }

  PopupMenuButton<PostMenuItem> _buildPopupMenu() {
    final popupItems = <PostMenuItem>[
      if (signature != null && signature!.notEquals(""))
        PostMenuItem(PostMenuItemType.signature, S.current.Signature,
            Icons.design_services),
      PostMenuItem(
          PostMenuItemType.report_post, S.current.Report_Post, Icons.forum),
      PostMenuItem(
          PostMenuItemType.report_user, S.current.Report_User, Icons.person)
    ];
    return PopupMenuButton<PostMenuItem>(
        icon: Icon(
          Icons.more_horiz,
          size: 16,
        ),
        onSelected: (value) {
          switch (value.itemType) {
            case PostMenuItemType.signature:
              bbCodePopup(signature);
              break;
            case PostMenuItemType.report_post:
              reportWithConfirmation(
                type: ReportType.forummessage,
                context: context,
                content: quoteWidget(body, widget.post, disableTap: true),
                queryParams: {
                  'id': widget.index + 1,
                  'id2': widget.post.id,
                },
              );
              break;
            case PostMenuItemType.report_user:
              reportWithConfirmation(
                type: ReportType.profile,
                context: context,
                content: _forumUserLeading(disableTap: true),
                queryParams: {'id': widget.post?.createdBy?.id},
              );
              break;
            default:
          }
        },
        itemBuilder: (context) => [
              ...popupItems.map(
                (i) => PopupMenuItem(
                  value: i,
                  enabled: true,
                  child: iconAndText(i.icon, i.title),
                ),
              ),
            ]);
  }

  void bbCodePopup(content) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: 150, minWidth: double.infinity),
              child: Material(
                child: SingleChildScrollView(
                  child: BbcodeWidget(
                    shrinkWrap: false,
                    alignCenter: true,
                    body: "<div> $content </div>",
                  ),
                ),
              ),
            ));
  }

  Widget quotePostWidget(
      {List<String>? quoteBodyList,
      required List<ForumTopicPost> quotedPostList}) {
    if (quoteBodyList == null || quoteBodyList.length == 0) {
      return SB.z;
    }
    if (user.pref.showOnlyLastQuote) {
      return quoteWidget(quoteBodyList.last, quotedPostList.last);
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: quotedPostList.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        var quoteBody = quoteBodyList.elementAt(index).trim();
        var quotedPost = quotedPostList.elementAt(index);
        return quoteWidget(quoteBody, quotedPost);
      },
    );
  }

  Widget quoteWidget(
    String quoteBody,
    ForumTopicPost quotedPost, {
    bool disableTap = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 0, 0, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 40,
            child: Material(borderRadius: BorderRadius.circular(12)),
          ),
          SB.w10,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvatarWidget(
                  height: 30,
                  width: 30,
                  username: quotedPost?.createdBy?.name,
                  onTap: () {
                    if (!disableTap && quotedPost?.createdBy?.name != null)
                      showUserPage(
                          context: context,
                          username: quotedPost.createdBy!.name!);
                  },
                  url: quotedPost?.createdBy?.id == null
                      ? null
                      : getUserImage(quotedPost.createdBy!.id!)),
              const SizedBox(
                height: 3,
              ),
              Container(
                width: 40,
                child: title(quotedPost?.createdBy?.name ?? "User",
                    fontSize: 10,
                    opacity: .8,
                    align: TextAlign.center,
                    textOverflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                if (disableTap) return;
                final result = await widget.onQuoteTapped(quotedPost.id!);
                if (result != null) {
                  bbCodePopup(quoteBody);
                }
              },
              onLongPress: () {
                if (disableTap) return;
                showToast("Post by ${quotedPost?.createdBy?.name ?? 'User'}");
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: quoteBody.length > 300 ? 120 : null,
                child: BbcodeWidget(
                  body: quoteBody,
                  minimize: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

enum PostMenuItemType { signature, report_post, report_user }

class PostMenuItem {
  final PostMenuItemType itemType;
  final String title;
  final IconData icon;

  PostMenuItem(this.itemType, this.title, this.icon);
}
