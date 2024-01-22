import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/home/animecard.dart';
import 'package:dal_commons/commons.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';

class ShareOutputProps {
  final bool includeTitle;
  final String prefix;
  final String termSpace;
  final String reducer;
  final bool forceReducer;
  ShareOutputProps({
    this.includeTitle = true,
    this.prefix = '',
    this.termSpace = '  ',
    this.reducer = '\n',
    this.forceReducer = false,
  });
}

void openShareBuilder(
  BuildContext context,
  List<ShareInput> shareInputs,
  String subject, {
  String? title,
  ShareOutputProps? props,
}) async {
  final result = await openAlertDialog(
    context: context,
    title: title ?? S.current.Share,
    content: ShareBuilder(shareInputs: shareInputs, props: props),
    yesText: S.current.Share,
    additionalAction: Padding(
      padding: const EdgeInsets.only(right: 15),
      child: PlainButton(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        onPressed: () {
          Clipboard.setData(
              ClipboardData(text: buildShareOutput(shareInputs, props: props)));
          Navigator.of(context, rootNavigator: true)
              .pop(false); // dismisses only the dialog and returns false
        },
        child: Text(S.current.Copy),
      ),
    ),
  );
  if (result) {
    await Share.share(
      buildShareOutput(shareInputs, props: props),
      subject: subject,
    );
  }
}

String buildShareOutput(
  List<ShareInput> shareInputs, {
  ShareOutputProps? props,
}) {
  if (props == null) props = ShareOutputProps();
  final selected = shareInputs.where((e) => e.isSelected).toList();
  if (selected.length == 1 && !props.forceReducer)
    return selected.first.content;
  return selected
      .map((e) => e.includeTitle
          ? '${props!.prefix}${e.title}:${props.termSpace}${e.content}'
          : '${props!.prefix}${e.content}')
      .reduce((e1, e2) => '$e1${props!.reducer}$e2');
}

class ShareInput {
  final String title;
  bool isSelected;
  final String content;
  final bool includeTitle;
  ShareInput({
    required this.title,
    this.isSelected = true,
    required this.content,
    this.includeTitle = true,
  });
}

List<ShareInput> buildShareInputs(
  dynamic node,
  String? url, {
  String? title,
  String category = 'anime',
}) {
  List<ShareInput> inputs = [];
  if (url != null) {
    inputs.add(ShareInput(
      title: S.current.Url,
      includeTitle: false,
      content: url,
    ));
  }
  if (node == null) return inputs;

  if (node is AnimeDetailed || node is MangaDetailed) {
    final dynamic contentDetailed = node;
    inputs.addAll([
      if (title != null || node.title != null)
        ShareInput(title: S.current.Title, content: title ?? node.title),
      if (contentDetailed.rank != null)
        ShareInput(
          title: S.current.Rank,
          content: "🏆 ${contentDetailed.rank}",
        ),
      if (contentDetailed.mean != null)
        ShareInput(
          title: S.current.Score,
          content:
              "⭐ ${contentDetailed.mean.toStringAsFixed(2)} (${userCountFormat.format(contentDetailed.numListUsers ?? 0)})",
        ),
      if (!nullOrEmpty(contentDetailed.genres))
        ShareInput(
          title: S.current.Genres,
          content: (contentDetailed.genres as List<MalGenre>)
              .map((e) => convertGenre(e, category))
              .reduce((g1, g2) => '$g1, $g2'),
        ),
      if (contentDetailed.synopsis != null &&
          contentDetailed.synopsis.isNotEmpty)
        ShareInput(
          title: S.current.Synopsis,
          content: contentDetailed?.synopsis,
        ),
    ]);
  } else if (node is PeopleV4Data || node is CharacterV4Data) {
    inputs.addAll([
      if (node.name != null)
        ShareInput(
          title: S.current.Name,
          content: node.name,
        ),
      if (node.favorites != null)
        ShareInput(
          title: S.current.Favorites,
          content: '♥️ ${node.favorites}',
        ),
      if (node.about != null)
        ShareInput(
          title: S.current.About,
          content: node.about,
        ),
    ]);
  } else if (node is InterestStack) {
    inputs.addAll([
      if (node.title!.isNotBlank)
        ShareInput(title: S.current.Title, content: node.title!),
      if (node.description!.isNotBlank)
        ShareInput(title: S.current.More_Info, content: node.description!),
      if (node.entries != null)
        ShareInput(
          title: S.current.Entries.standardize()!,
          content: '${node.entries} ${S.current.Entries}',
        ),
      if (node.reStacks != null)
        ShareInput(
          title: S.current.Restacks.standardize()!,
          content: '${node.reStacks} ${S.current.Restacks}',
        ),
    ]);
  }
  return inputs;
}

class ShareBuilder extends StatefulWidget {
  final List<ShareInput> shareInputs;
  final ShareOutputProps? props;
  const ShareBuilder({required this.shareInputs, Key? key, this.props})
      : super(key: key);

  @override
  State<ShareBuilder> createState() => _ShareBuilderState();
}

class _ShareBuilderState extends State<ShareBuilder> {
  late List<ShareInput> shareInputs;
  late ShareOutputProps props;
  @override
  void initState() {
    super.initState();
    shareInputs = widget.shareInputs;
    props = widget.props ?? ShareOutputProps();
  }

  List<ShareInput> get selectedInputs =>
      shareInputs.where((e) => e.isSelected).toList();

  @override
  Widget build(BuildContext context) {
    if (shareInputs.length == 1 && !props.forceReducer)
      return title(shareInputs.first.content);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ToolTipButton(
                message: S.current.Select_All,
                child: title(S.current.Select_All),
                onTap: () {
                  if (mounted)
                    setState(() {
                      shareInputs.forEach((e) => e.isSelected = true);
                    });
                },
              ),
              ToolTipButton(
                message: S.current.Select_One,
                child: title(S.current.Select_One),
                onTap: () {
                  if (mounted)
                    setState(() {
                      shareInputs.forEach((e) => e.isSelected = false);
                      shareInputs.first.isSelected = true;
                    });
                },
              )
            ],
          ),
          SB.h10,
          ...shareInputs
              .map((e) => CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                    value: e.isSelected,
                    title: title(e.title, opacity: 1, fontSize: 15),
                    subtitle:
                        title(e.content, textOverflow: TextOverflow.ellipsis),
                    onChanged: (s) {
                      if (s == null) return;
                      if (mounted)
                        setState(() {
                          if (!e.isSelected || selectedInputs.length != 1) {
                            e.isSelected = s;
                          }
                        });
                    },
                  ))
              .toList(),
        ],
      ),
    );
  }
}
