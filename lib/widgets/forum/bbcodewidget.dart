import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constant.dart';
import '../../main.dart';

class BbcodeWidget extends StatelessWidget {
  static const tagsToReplace = {
    "<right>": "<div style='text-align: right;'>",
    "<list>": "<ul>",
    "<code>": "</div>",
    "</right>": "</div>",
    "</list>": "</ul>",
    "</url>": "</a>",
    "</color>": "</span>",
    "</span>": "</span>",
    "</center>": "</div>",
    "</img>": "",
    "<quote>": "<div>",
    "</quote>": "</div>",
    "<*>": "</li><li>",
    "< * >": "</li><li>",
    "</yt>": "</iframe>",
    "</code>": "</div>",
    "<br /><br />": "",
    "<Level>": "",
    "<Total Items Needed>": ""
  };
  static const validTags = [
    "<color",
    "<size",
    "<list",
    "<url",
    "<img",
    "<yt",
    "<spoiler",
    "<center",
  ];

  final String body;
  final Color? color;
  final bool minimize;
  final bool alignCenter;
  final bool isYTVideo;
  final bool shrinkWrap;
  const BbcodeWidget(
      {Key? key,
      required this.body,
      this.color,
      this.shrinkWrap = true,
      this.minimize = false,
      this.alignCenter = false,
      this.isYTVideo = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Html(
      data:
          '<div ${alignCenter ? 'style="text-align:center;"' : ''}> ${applyTransform(body)}</div>',
      shrinkWrap: shrinkWrap,
      style: {
        "body": Style(
          color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
          textAlign: alignCenter ? TextAlign.center : null,
          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
          fontSize: minimize ? FontSize.small : FontSize.medium,
        ),
        "a": Style(color: Theme.of(context).textTheme.bodyMedium?.color)
      },
      onLinkTap: (url, _, __) => onLinkTap(url, context),
      onAnchorTap: (url, _, __) => onLinkTap(url, context),
      doNotRenderTheseTags: {
        if (minimize) ...['img', 'iframe', 'spoiler'],
      },
      extensions: commonExtensions(context),
    );
  }

  String applyTransform(String text) {
    int index = 0;
    String _text = text;
    var nestedTagStack = [];
    var replaceContent = {};
    while (index < (text.length)) {
      for (String tag in validTags) {
        try {
          String st = "";
          if ((index + tag.length) < text.length)
            st = text.substring(index, index + tag.length).toLowerCase();
          String et = "";
          if ((index + getClosingTag(tag).length - 1) < text.length)
            et = text
                .substring(index, index + getClosingTag(tag).length)
                .toLowerCase();
          if (st.equals(tag)) {
            nestedTagStack.add(index);
          }
          if (et.equals(getClosingTag(tag))) {
            int startIndex = nestedTagStack.removeLast();
            var tagContent = text.substring(startIndex, index);
            var tagHeader = tagContent.substring(0, tagContent.indexOf(">"));
            var newContent = "", tagValue = "";
            if (tagHeader.contains("=")) {
              tagValue = tagContent.substring(
                  tagContent.indexOf("=") + 1, tagContent.indexOf(">"));
            }
            var tagBody = tagContent.substring(tagContent.indexOf(">") + 1);
            if (tag.equals("<color")) {
              newContent = "<span style='color: $tagValue;'>$tagBody";
            } else if (tag.equals("<size")) {
              var sizeValue = int.tryParse(tagValue);
              if (sizeValue != null && sizeValue >= 130) {
                newContent = "<span style='font-size: 130%;'>$tagBody";
              } else {
                newContent = "<span style='font-size: $tagValue%;'>$tagBody";
              }
            } else if (tag.equals("<list")) {
              if (tagValue.notEquals("")) {
                newContent = "<ol type='$tagValue'>$tagBody";
              } else {
                newContent = "<ul>$tagBody";
              }
              newContent = newContent
                  .replaceFirst("<*>", "<li>")
                  .replaceFirst("< * >", "<li>");
            } else if (tag.equals("<url")) {
              newContent = "<a style='' href='$tagValue'>$tagBody";
            } else if (tag.equals("<img")) {
              newContent =
                  "<img src='$tagBody' style='vertical-align: $tagValue;' />";
            } else if (tag.equals("<spoiler")) {
              newContent =
                  "<spoiler ${tagValue.equals("") ? '' : "name='$tagValue';"}>$tagBody";
            } else if (tag.equals("<center")) {
              newContent = "<div style='text-align: center;'>$tagBody";
            } else if (tag.equals("<yt")) {
              if (isYTVideo) {
                newContent = """
                 <iframe height="315"
                src="$tagBody">
                """;
              } else
                newContent = """
              <div style='text-align: center;'>
                <iframe height="315"
                src="http://www.youtube.com/embed/$tagBody?autoplay=1">
              </div>
              """;
            }

            replaceContent[tagContent] = newContent;

            if (nestedTagStack.isEmpty) {
              for (var tc in replaceContent.keys.toList().reversed) {
                _text = _text.replaceAll(tc, replaceContent[tc]);
              }
            }
          }
        } catch (e) {
          logDal(e);
        }
      }

      index++;
    }

    _text = replaceBBTags(_text);
    return _text;
  }

  String replaceBBTags(String _text) {
    for (String tag in tagsToReplace.keys) {
      _text = _text.replaceAll(tag, tagsToReplace[tag]!);
      _text = _text.replaceAll(tag.toUpperCase(), tagsToReplace[tag]!);
    }
    return _text;
  }

  String getClosingTag(String tag) {
    return "</${tag.substring(1)}>";
  }
}
// <div> It feels like I knew this character but can&#039;t remember. Anyone?<br />
// <br />
// <div style='text-align: center'><spoiler  ><img src='https://i.ibb.co/th8V24N/11.gif' style='vertical-align: ;' /></spoiler></div> </div>
/*
How to use BBcode
BBcode is used to format text, insert url's and pictures in a post on the forums, profile, comments and in PM's. BBcode is similar to HTML. The only difference is BBcode uses square braces [] instead of <> in HTML. Written by Cheesebaron.
Text Formatting
You can change the style of the text the following ways:
[b]bo-rudo[/b] - this makes the text bold
[u]anda-rain[/u] - this underlines the text
[i]itarikku[/i] - this italicises the text
[s]sutoraiki[/s] - this strikes through the text
[center]text[/center] - this centers the text
[right]text[/right] - this right justifies the text
Changing the text color and size
[color=blue]buru[/color] - this changes the text color to blue

You can also use colour codes to define what colour you want your text to be
[color=#FFFFFF]Shiroi[/color] - this changes the text color to white

You can change the text size by using the [size=][/size] tag, the size is dependant on what value written. You can choose 20 to 200, which is representing the size in percent.
[size=30]KOMAKAI[/size] - will give a very small text size [size=200]KOUDAI[/size] - will give a huge text size
Posting a YouTube Video
[yt]_YL7t_QbQ2M[/yt]

Posts a YouTube video.
Creating lists
You can create a list by using the [list][/list] tag.

To create an un-ordered list:
[list]
[*]kawaii
[*]fugu
[*]shouen
[/list]
To create an ordered, numbered list:
[list=1]
[*]kawaii
[*]fugu
[*]shouen
[/list]
Creating links and showing images
[url=https://myanimelist.net]Visit MyAnimeList[/url] - this would display Visit MyAnimeList as an URL.

To insert a picture to your post you can use the [img][/img] tag.
[img]http://UrlToPicture.net/Path/To/Picture.jpg[/img]
To insert a left/right aligned picture you can use the [img align=(left or right)][/img].
[img align=left]http://UrlToPicture.net/Path/To/Picture.jpg[/img]
[img align=right]http://UrlToPicture.net/Path/To/Picture.jpg[/img]
Making a spoiler button
To make a spoiler button use the [spoiler][/spoiler] tag, and the text in between the tags become invisible until the "Show spoiler" button is clicked.
[spoiler]This is a spoiler for an episode of an anime that could make people angry[/spoiler]
To make a named spoiler button you can use the [spoiler=name][/spoiler].
[spoiler=secret]Secret[/spoiler]
[spoiler="big secret"]Big Secret[/spoiler]
[spoiler='big secret']Big Secret[/spoiler]
Writing raw text
To write raw text use the [code][/code] tag.
[code]You can make the text bold with [b]text[/b] tag.[/code]
Combining BBcode
You can combine BBcodes, but you have to remember to end the tags in the right order
This example is WRONG:
[url=https://myanimelist.net][img]https://myanimelist.net/ picture.jpg[/url][/img]
This example is RIGHT:
[url=https://myanimelist.net][img]https://myanimelist.net/ picture.jpg[/img][/url]
User Mention
To mention another user on the forum add an @ symbol before their name. For example @user_name
*/
