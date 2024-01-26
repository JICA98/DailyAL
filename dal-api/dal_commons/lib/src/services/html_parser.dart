import 'dart:convert';

import 'package:dal_commons/dal_commons.dart';
import 'package:dal_commons/src/model/global/node.dart' as dal;
import 'package:dal_commons/src/model/html/anime/additional_title.dart';
import 'package:dal_commons/src/model/html/anime/animelinks.dart';
import 'package:dal_commons/src/model/html/anime/intereststack.dart';
import 'package:dal_commons/src/model/html/anime/mangacharahtml.dart';
import 'package:html/dom.dart';
import 'package:html_unescape/html_unescape_small.dart';

class HtmlParsers {
  static final unescape = HtmlUnescape();
  static String? parseCharacterPage(Element e) {
    return e.querySelector('a')?.attributes['href'];
  }

  static Map<String, String> parseMagazines(Document? d, ContentType type) {
    if (d == null) return {};
    try {
      final toReplace =
          type == ContentType.anime ? "/anime/producer/" : "/manga/magazine/";
      final gLink = d.querySelectorAll('.genre-link')[4];
      final gList = gLink.querySelectorAll('.genre-list a') ?? [];
      final prodMap = <String, String>{};
      for (var e in gList) {
        String? href = e.attributes['href'] ?? '';
        if (href.isNotBlank) {
          href = href.replaceAll(toReplace, '');
          final split = href.split('/');
          if (split.isNotEmpty) {
            final id = int.tryParse(split[0]);
            final name = split[1].replaceAll('_', ' ');
            if (id != null && name.isNotBlank) {
              prodMap['$id'] = name;
            }
          }
        }
      }
      return prodMap;
    } catch (e) {
      logDal(e);
    }
    return {};
  }

  static Map<String, dynamic> parseCharacterPeopleHome(
      Document doc, ContentType type) {
    final map = <String, dynamic>{};
    var list = [];
    final className = type == ContentType.people
        ? '.people-favorites-ranking-table'
        : '.characters-favorites-ranking-table';
    final rows = doc.querySelectorAll('$className .ranking-list') ?? [];
    if (rows.isNotEmpty) {
      list = rows
          .map((e) {
            int? rank, id, favorites;
            String? name, otherName;

            rank = int.tryParse(e.querySelector('.rank')?.text.trim() ?? '');
            final peopleDiv = e.querySelector('.people');
            if (peopleDiv != null) {
              id = PathUtils.getIdUrl(
                  peopleDiv.querySelector('a')?.attributes['href']);
              final info = peopleDiv.querySelector('.information');
              if (info != null) {
                name = info.querySelector('a')?.text.trim();
                otherName = info.querySelector('span')?.text.trim();
                otherName =
                    otherName?.substring(1, otherName.length - 1).trim();
              }
            }

            if (name == null) return null;

            favorites = int.tryParse(e
                    .querySelector('.favorites')
                    ?.text
                    .trim()
                    .replaceAll(',', '') ??
                '');

            final object = {
              'id': id,
              'rank': rank,
              'name': name,
              'otherName': otherName,
              'image': getImageSrcSet(peopleDiv),
              'favorites': favorites,
            };
            if (type == ContentType.character) {
              object['animeRef'] =
                  getNodes(e.querySelectorAll('.animeography a') ?? []);
              object['mangaRef'] =
                  getNodes(e.querySelectorAll('.mangaography a') ?? []);
            } else {
              object['birthday'] = e.querySelector('.birthday')?.text.trim();
            }
            return object;
          })
          .where((e) => e != null)
          .toList();
    }
    map['data'] = list;
    return map;
  }

  static Map<String, dynamic> getImageSrcSet(Element? element) {
    String? medImageUrl, highImageUrl;
    final image = element?.querySelector('img');
    if (image != null) {
      final srcSet = image.attributes['data-srcset']?.split(',') ?? [];

      if (srcSet.isNotEmpty) {
        medImageUrl = srcSet.tryAt()?.replaceFirst('1x', '').trim();
        highImageUrl = srcSet.tryAt(1)?.replaceFirst('2x', '').trim();
      } else {
        final src = image.attributes['data-src']?.split(',') ?? [];
        final url = src.tryAt();
        medImageUrl = url;
        highImageUrl = url;
      }
    }
    return {
      'medium': medImageUrl,
      'large': highImageUrl,
    };
  }

  static String getPictureUrl(Element element) {
    final image = getImageSrcSet(element);
    return image['large'] ?? image['medium'];
  }

  static Picture getPicture(Element? element) {
    final image = getImageSrcSet(element);
    return Picture(
      large: image['large'],
      medium: image['medium'],
    );
  }

  static List<dynamic> getNodes(List<Element> elements) {
    return elements
        .map((a) =>
            {'title': a.text, 'id': PathUtils.getIdUrl(a.attributes['href'])})
        .where((a) => a['id'] != null)
        .toList();
  }

  static Map<String, dynamic> getReviews(Document p0) {
    final map = <String, dynamic>{};
    map['data'] = (p0.querySelectorAll('.review-element') ?? [])
        .map((e) => animeReviewHtmlfromHtml(e))
        .toList();
    return map;
  }

  static Map<String, dynamic> getRecommendations(Document doc, bool isHome) {
    final map = <String, dynamic>{};
    if (isHome) {
      _getHomeRecommendations(doc, map);
    } else {
      map['data'] = doc
          .querySelectorAll('div.borderClass')
          .where((e) => e.className.equals('borderClass'))
          .map((e) {
        final pic = e.querySelector('.picSurround');
        final textElements = e.querySelectorAll('.detail-user-recs-text');
        final moreLink =
            e.querySelector('.js-similar-recommendations-button strong');
        return {
          'relatedNode': getNodeFromElement(pic),
          'count': int.tryParse(moreLink?.text.trim() ?? '0'),
          'recommendations': textElements.map((textEle) {
            final text = unescape
                .convert(textEle.text.replaceFirst('read more', '').trim());
            final sibs = textEle.nextElementSibling?.querySelectorAll('a');
            final reportSib = sibs?.tryAt();
            return {
              'text': text,
              'id': queryParamsUrl<int>(
                  reportSib?.attributes.tryAt('href'), 'id'),
              'username': sibs?.tryAt(1)?.text.trim(),
            };
          }).toList(),
        };
      }).toList();
    }
    return map;
  }

  static dal.Node getNodeFromElement(Element? ele) {
    return dal.Node(
      id: PathUtils.getIdAnchor(ele),
      mainPicture: getPicture(ele),
      title: PathUtils.getTitleAnchor(ele),
      nodeCategory: PathUtils.getCategoryAnchor(ele),
    );
  }

  static void _getHomeRecommendations(Document doc, Map<String, dynamic> map) {
    final recDivs = doc.querySelectorAll('#content .spaceit.borderClass');
    map['data'] = recDivs
        .map((e) {
          dal.Node first, second;
          final pics = e.querySelectorAll('.picSurround');
          if (pics.length == 2) {
            first = getNodeFromElement(pics[0]);
            second = getNodeFromElement(pics[1]);
          } else {
            return null;
          }
          final lightLinks = e.querySelectorAll('.lightLink a');
          String? timeAgo;
          final lightLinksText =
              e.querySelector('.lightLink.spaceit')?.text.trim() ?? '';
          if (lightLinksText.contains('-')) {
            timeAgo = lightLinksText
                .substring(lightLinksText.indexOf('-') + 1)
                .trim();
          }
          return {
            'first': first,
            'second': second,
            'username': lightLinks.tryAt(1)?.text.trim(),
            'timeAgo': timeAgo,
            'id': queryParamsUrl<int>(
                lightLinks.tryAt()?.attributes.tryAt('href'), 'id'),
            'text': unescape.convert(e
                    .querySelector('.recommendations-user-recs-text')
                    ?.text
                    .trim() ??
                ''),
          };
        })
        .where((e) => e != null)
        .toList();
  }

  static ClubListHtml clubListHtmlFromHtml(Document document) {
    ClubListHtml? clubListHtml;
    var tableClass = document.getElementsByClassName("club-list");
    if (tableClass.isNotEmpty) {
      var table = tableClass.first;
      var rows = table.getElementsByClassName("table-data");
      var list = rows.isNotEmpty
          ? rows.map((row) {
              var tdList = row.getElementsByTagName("td");
              var clubId,
                  createdBy,
                  createdTime,
                  noOfMembers,
                  lastPostBy,
                  clubName,
                  desc,
                  lastPostTime;
              String? imgUrl;
              if (tdList.isNotEmpty) {
                try {
                  var firstTd = tdList.first;

                  try {
                    var img = firstTd.getElementsByTagName("img");
                    imgUrl = img.first.attributes["data-srcset"] ?? '';
                    imgUrl = imgUrl.substring(
                        imgUrl.indexOf("1x,") + 3, imgUrl.indexOf(" 2x"));
                  } catch (e) {}

                  try {
                    var dom = firstTd.getElementsByClassName("fw-b");
                    clubName = dom.first.text;
                    var cUrl = dom.first.attributes["href"] ?? "";
                    clubId =
                        int.tryParse(cUrl.substring(cUrl.indexOf("cid=") + 4));

                    desc = firstTd
                        .getElementsByClassName("pt4 pb4 word-break")
                        .first
                        .text
                        .trim();

                    createdBy = firstTd
                        .getElementsByClassName("pt4 pb4 word-break")
                        .first
                        .nextElementSibling
                        ?.text
                        .trim();
                  } catch (e) {}

                  noOfMembers = tdList.elementAt(1).text.trim() ?? "";

                  var thirdTd = tdList.elementAt(2);

                  try {
                    lastPostTime =
                        thirdTd.getElementsByClassName("di-ib").first.text;
                  } catch (e) {}

                  try {
                    lastPostBy = thirdTd.getElementsByTagName("a").first.text;
                  } catch (e) {}

                  try {
                    createdTime = tdList.elementAt(3).text;
                  } catch (e) {}
                } catch (e) {}
              }

              return ClubHtml(
                  createdBy: createdBy,
                  createdTime: createdTime,
                  lastPostBy: lastPostBy,
                  lastPostTime: lastPostTime,
                  imgUrl: imgUrl,
                  noOfMembers: noOfMembers,
                  clubName: clubName,
                  desc: desc,
                  clubId: clubId);
            }).toList()
          : <ClubHtml>[];
      clubListHtml = ClubListHtml(
          clubs: list,
          data: list.map((e) => ClubBaseNode(content: e)).toList(),
          lastUpdated: DateTime.now(),
          fromCache: false);
    }
    return clubListHtml ?? ClubListHtml();
  }

  static Featured featuredFromHtml(Document? document, int? id,
      {String category = "featured"}) {
    if (document == null) {
      return Featured();
    }
    List<String> tags = [];
    String? body, summary, title;
    String? postedBy, postedDate, views;
    Map<String, List<BaseNode>>? relatedDatabaseEntries = {};
    Map<String, List<BaseNode>>? relatedNews = {};
    int? topicId;
    try {
      var container = document.getElementByClass("news-container");
      if (container != null) {
        title = container.getElementByClass("title")?.text.trim();
        summary = container.getElementByClass("summary")?.text.trim();

        var tagsEle = container.getElementByClass("tags");
        if (tagsEle != null) {
          var list = tagsEle.getElementsByClassName("tag");
          for (var tagE in list) {
            if (tagE.text.isNotBlank) {
              tags.add(tagE.text.trim());
            }
          }
        }

        var newsInfoEle = container.getElementByClass("news-info-block");
        if (newsInfoEle != null) {
          var infoEle = newsInfoEle.getElementByClass("information");
          postedBy = infoEle?.getElementByTag("a")?.text.trim() ?? "";
          if (category.equals("featured")) {
            views = infoEle?.getElementByTag("b")?.text.trim();
          } else {
            var comment = infoEle?.getElementByClass("comment");
            if (comment != null) {
              views = comment.text.getOnlyDigits();
              topicId = PathUtils.getId(
                  Uri.tryParse(comment.attributes["href"] ?? ''));
            }
          }
          postedDate = infoEle?.text.substring(0, infoEle.text.indexOf("|"));
          postedDate = postedDate?.replaceAll("by $postedBy", '').trim();
        }

        body = container.getElementByClass("content")?.innerHtml;
      }

      var mt24 = document.getElementByClass("mt24");
      if (mt24 != null) {
        var table = mt24.nextElementSibling;
        if (table != null) {
          var trList = table.getElementsByTagName("tr") ?? [];
          if (trList.isNotEmpty) {
            for (var tr in trList) {
              List<BaseNode> nodes = [];
              var tdL = tr.getElementsByTagName("td") ?? [];
              if (tdL.length == 2) {
                var category = getCategory(tdL.first.text) ?? '';
                if (category.isNotBlank) {
                  var anchors = tdL[1].getElementsByTagName("a") ?? [];
                  for (var a in anchors) {
                    String href = a.attributes["href"] ?? '';
                    href = href.substring(0, href.lastIndexOf("/"));
                    href = href.substring(href.lastIndexOf("/") + 1);
                    nodes.add(BaseNode(
                        content: dal.Node(
                            id: int.tryParse(href),
                            title: a.text.trim() ?? "??")));
                  }
                  relatedDatabaseEntries[category] = nodes;
                }
              }
            }
          }
        }
      }

      var newsEles = document.getElementsByClassName("news-side-block") ?? [];
      for (var ele in newsEles) {
        var header = ele.getElementByClass("header");
        if (header != null) {
          var relNews = featuredResultFromElement(ele,
              category: "news", unitName: "news");
          if (relNews.data != null && relNews.data!.isNotEmpty) {
            relatedNews[header.text.trim()] = relNews.data ?? [];
          }
        }
      }
    } catch (e) {
      logDal(e);
    }
    return Featured(
      body: body,
      id: id,
      title: title,
      summary: summary,
      tags: tags,
      views: views,
      relatedArticles:
          featuredResultFromHtml(document).data as List<FeaturedBaseNode>?,
      relatedDatabaseEntries: relatedDatabaseEntries,
      postedBy: postedBy,
      postedDate: postedDate,
      relatedNews: relatedNews,
      topidId: topicId,
    );
  }

  static String? getCategory(String text) {
    if (text.isNotBlank) {
      text = text.trim().toLowerCase();
      if (text.contains("anime")) {
        return "anime";
      } else if (text.contains("manga")) {
        return "manga";
      } else if (text.contains("people")) {
        return "person";
      } else if (text.contains("character")) {
        return "character";
      }
    }
    return null;
  }

  static FeaturedResult featuredResultFromHtml(Document? doc,
      {String category = "featured", String containerName = "news-list"}) {
    if (doc == null) return FeaturedResult(data: []);
    return featuredResultFromElement(
      doc.getElementByClass(containerName),
      category: category,
      containerName: containerName,
    );
  }

  static FeaturedResult featuredResultFromElement(Element? data,
      {String category = "featured",
      String containerName = "news-list",
      String unitName = "news-unit"}) {
    if (data == null) return FeaturedResult(data: []);
    List<FeaturedBaseNode> list = [];
    bool notDefault = containerName.notEquals("news-list");
    try {
      String unitRight = "news-unit-right";
      String unitInfo = "information";
      if (unitName.notEquals("news-unit")) {
        unitRight = "di-tc";
      }
      if (notDefault) {
        unitName = "clearfix";
        unitRight = "spaceit";
        unitInfo = "lightLink";
      }
      var unitEle = data.getElementsByClassName(unitName) ?? [];
      if (notDefault) {
        unitEle.removeWhere(
            (element) => element.getElementByClass("clearfix") == null);
      }
      for (var unit in unitEle) {
        int? id;
        String? imgUrl, postedDate;
        List<String> tags = [];

        var anchor = unit.getElementByTag("a");
        if (anchor != null) {
          var href = anchor.attributes["href"] ?? '';
          if (href.isNotBlank) {
            if (category.equals("featured")) {
              href = href.substring(0, href.lastIndexOf("/"));
            }
            href = href.substring(href.lastIndexOf("/") + 1);
            id = int.tryParse(href);
          }
          var img = anchor.getElementByTag("img");
          if (img != null) {
            if (category.equals("featured") || notDefault) {
              imgUrl = img.attributes["data-src"];
            } else {
              imgUrl = img.attributes["src"]?.replaceAll("r/100x156/", '');
            }
          }
        }
        var right = unit.getElementByClass(unitRight);
        var info = right?.getElementByClass(unitInfo);
        var tagsEle = right?.getElementByClass("tags");
        if (tagsEle != null) {
          var tagsL = tagsEle.getElementsByClassName("tag") ?? [];
          for (var tag in tagsL) {
            tags.add(tag.text);
          }
        }
        if (id != null) {
          list.add(FeaturedBaseNode(Featured(
            body: "",
            id: id,
            mainPicture: Picture(large: imgUrl, medium: imgUrl),
            postedBy: notDefault
                ? info?.text.trim()
                : info?.getElementByClass("info")?.getElementByTag("a")?.text,
            postedDate: postedDate,
            relatedArticles: [],
            relatedDatabaseEntries: {},
            summary: right?.getElementByClass("text")?.text.trim(),
            tags: tags,
            title: notDefault
                ? right?.text.trim()
                : right?.getElementByClass("title")?.text.trim(),
            views: info?.getElementByClass("di-tc")?.getElementByTag("b")?.text,
          )));
        }
      }
    } catch (e) {}
    return FeaturedResult(data: list);
  }

  static ForumHtml forumHtmlFromHtml(Element forumHTML) {
    var tableDataList = forumHTML.getElementsByTagName("td");
    if (tableDataList.isEmpty) return ForumHtml();
    var createdByBoard,
        replies,
        lastPostByBoard,
        createdTime,
        title,
        topicId,
        createdBy;
    var lastPostBy, lastPostTime;

    try {
      createdByBoard = tableDataList[1];
      createdTime = createdByBoard.getElementsByTagName("span")[1].innerHtml;

      title = createdByBoard.getElementsByTagName("a")[0].innerHtml;
      topicId = Uri.parse(
              createdByBoard.getElementsByTagName("a")[0].attributes["href"])
          .queryParameters["topicid"];
      createdBy =
          createdByBoard.getElementsByClassName("forum_postusername")[0].text;
    } catch (e) {}

    try {
      replies = tableDataList[2].innerHtml;
    } catch (e) {}

    try {
      lastPostByBoard = tableDataList[3];
      lastPostBy = lastPostByBoard.getElementsByTagName("a")[0].innerHtml;
      lastPostTime = lastPostByBoard.innerHtml
          .substring(lastPostByBoard.innerHtml.lastIndexOf("<br>") + 4);
    } catch (e) {}

    return ForumHtml(
        createdByName: createdBy,
        createdTime: createdTime,
        lastPostBy: lastPostBy,
        lastPostTime: lastPostTime,
        replies: replies,
        title: title,
        topicId: int.tryParse(topicId ?? ''));
  }

  // "<html><head></head><body><a href="https://myanimelist.net/login.php?from=%2Fanime%2F39486%2FGintama__The_Final%2Fforum&amp;error…"

  static ForumTopicsHtml forumTopicsHtmlFromHtml(Document? document) {
    if (document == null && document?.getElementById("forumTopics") == null) {
      return ForumTopicsHtml(data: [], fromCache: false);
    }
    var forumTR =
        document!.getElementById("forumTopics")?.getElementsByTagName("tr");
    if ((forumTR?.length ?? 0) < 1) return ForumTopicsHtml();
    if ((forumTR?.first.getElementsByClassName("forum-table-header").length ??
            0) !=
        0) {
      forumTR?.removeAt(0);
    } else if (forumTR!.first.className
        .equalsIgnoreCase("forum-table-header")) {
      forumTR.removeAt(0);
    }
    return ForumTopicsHtml(
        fromCache: false,
        data:
            forumTR!.map((forumHTML) => forumHtmlFromHtml(forumHTML)).toList());
  }

  static const allTypes = [
    "anime",
    "manga",
    "character",
    "person",
    "forum",
    "club",
    "featured",
    "news"
  ];

  static AllSearchResult allSearchResultFromHtml(Document? doc) {
    Map<String, List<BaseNode>> allData = {};
    try {
      if (doc == null) {
        for (var types in allTypes) {
          allData[types] = [];
        }
        return AllSearchResult(allData: allData);
      }
      var articles = doc.getElementsByTagName("article") ?? [];
      for (var i = 0; i < articles.length; i++) {
        var article = articles.elementAt(i);
        var items = article.getElementsByClassName("list") ?? [];
        List<BaseNode> data = [];
        String? category;
        for (var j = 0; j < items.length; j++) {
          var item = items.elementAt(j);
          var node = AddtionalNode(title: 'Unknown');
          var picEleList = item.getElementsByClassName("picSurround") ?? [];

          if (picEleList.isNotEmpty) {
            var picEle = picEleList[0];
            var aEleList = picEle.getElementsByTagName("a") ?? [];
            if (aEleList.isNotEmpty) {
              var anchor = aEleList[0];
              var href = anchor.attributes["href"];
              if (href != null) {
                category ??= getCategoryAllSearch(href.toString());
                if (category!.equals("news")) {
                  node.id =
                      int.tryParse(href.substring(href.indexOf("news/") + 5));
                } else if (["forum", "club"].contains(category)) {
                  node.id =
                      int.tryParse(href.substring(href.lastIndexOf("=") + 1));
                } else {
                  href = href.substring(0, href.lastIndexOf("/"));
                  href = href.substring(href.lastIndexOf("/") + 1);
                  node.id = int.tryParse(href);
                }
              }
              var imgList = picEle.getElementsByTagName("img") ?? [];
              String imgPpty = "data-src";
              if (["news", "featured"].contains(category)) {
                imgPpty = "src";
              }
              if (imgList.isNotEmpty) {
                var img = imgList[0]
                    .attributes[imgPpty]
                    ?.replaceAll("r/100x140/", '')
                    .replaceAll("r/50x50/", '');
                node.mainPicture = Picture(large: img, medium: img);
              }
            }
          }

          var infoList = item.getElementsByClassName("information") ?? [];
          if (infoList.isNotEmpty) {
            var info = infoList.first;
            var aEleList = info.getElementsByTagName("a") ?? [];

            if (aEleList.isNotEmpty) {
              var anchor = aEleList.first;
              node.title = anchor.text;
            }
            var pt4List = info.getElementsByClassName("fn-grey4") ?? [];
            if (pt4List.isNotEmpty) {
              node.additional = pt4List.first.text.trim();
            }
          }

          data.add(BaseNode(content: node));
        }
        if (category != null &&
            allTypes.contains(category) &&
            !allData.containsKey(category)) {
          allData[category] = data ?? [];
        }
      }
    } catch (e) {}
    for (var types in allTypes) {
      if (!allData.keys.contains(types)) allData[types] = [];
    }
    return AllSearchResult(allData: allData);
  }

  static String? getCategoryAllSearch(String href) {
    try {
      if (href.contains("clubs.php")) {
        return "club";
      }
      href = href.substring(
          href.indexOf(Constants.htmlEnd) + Constants.htmlEnd.length);
      var category = href.substring(0, href.indexOf("/"));
      switch (category) {
        case "people":
          return "person";
        default:
          return category;
      }
    } catch (e) {}
    return null;
  }

  static UserResult userResultfromHtml(Document? document) {
    if (document == null) return UserResult();
    List<Content> Cdata = [];
    bool isUser = false;
    try {
      document.head?.namespaceUri;
      var tables = document.getElementsByTagName("table");
      if (tables.length == 2) {
        var searchTable = tables[1];
        var datas = searchTable.getElementsByTagName("td") ?? [];
        for (var data in datas) {
          String username, imgUrl, lastOnline;
          var picDiv = data
              .getElementsByClassName("picSurround")
              .first
              .getElementsByTagName("a")
              .first;
          var href = picDiv.attributes["href"];
          username = href?.substring(href.lastIndexOf("/") + 1) ?? 'Unknown';
          var img = picDiv.getElementsByTagName("img").first;
          imgUrl = img.attributes["data-src"] ?? '';
          lastOnline = data.getElementsByClassName("spaceit_pad").first.text;
          Cdata.add(Content(MUser(username, imgUrl, lastOnline)));
        }
      }
      isUser = 'report'.equalsIgnoreCase(document
          .querySelector('#contentWrapper')
          ?.querySelector('a')
          ?.text
          ?.trim());
    } catch (e) {}

    return UserResult(data: Cdata, isUser: isUser);
  }

  static AnimeCharacterHtml? animeCharacterHtmlfromHtml(Element? character) {
    if (character == null) return null;
    var dataList = character.getElementsByTagName("td");
    var animePicture = dataList
        .elementAt(0)
        .getElementsByTagName("img")
        .first
        .attributes["data-src"];
    if (animePicture != null) {
      animePicture = animePicture
          .replaceAll("r/42x62/", "")
          .substring(0, animePicture.indexOf("?"));
    }
    var characterName =
        dataList.elementAt(1).getElementsByTagName("a").first.innerHtml;
    dynamic characterId = dataList
        .elementAt(1)
        .getElementsByTagName("a")
        .first
        .attributes["href"];
    if (characterId != null) {
      characterId = int.tryParse(characterId.substring(
          characterId.indexOf("character/") + "character/".length,
          characterId.lastIndexOf("/")));
    }
    var characterType =
        dataList.elementAt(1).getElementsByTagName("small").first.innerHtml;
    var seiyuuName, seiyuuOrigin, seiyuuPicture;
    dynamic seiyuuId;

    if (dataList.length > 1) {
      var seiyuuDataList = dataList[2].getElementsByTagName("td");
      if (seiyuuDataList.length > 1) {
        seiyuuName =
            seiyuuDataList.first.getElementsByTagName("a").first.innerHtml;
        seiyuuId = seiyuuDataList.first
            .getElementsByTagName("a")
            .first
            .attributes["href"];
        if (seiyuuId != null) {
          seiyuuId = int.tryParse(seiyuuId.substring(
              seiyuuId.indexOf("people/") + "people/".length,
              seiyuuId.lastIndexOf("/")));
        }
        seiyuuOrigin =
            seiyuuDataList.first.getElementsByTagName("small").first.innerHtml;
        seiyuuPicture = seiyuuDataList
            .elementAt(1)
            .getElementsByTagName("img")
            .first
            .attributes["data-src"];
        if (seiyuuPicture != null) {
          seiyuuPicture = seiyuuPicture
              ?.replaceAll("r/42x62/", "")
              ?.substring(0, seiyuuPicture.indexOf(".jpg") + 4);
        }
      }
    }

    return AnimeCharacterHtml(
        characterId: characterId,
        seiyuuId: seiyuuId,
        animePicture: animePicture,
        characterName: characterName,
        seiyuuName: seiyuuName,
        seiyuuOrigin: seiyuuOrigin,
        seiyuuPicture: seiyuuPicture,
        characterType: characterType);
  }

  static AnimeDetailedHtml animeDetailedHtmlfromHtml(Document? animeDetailed,
      {ContentType type = ContentType.anime}) {
    if (animeDetailed == null) return AnimeDetailedHtml();

    var charactersAndStaffs = animeDetailed
            .getElementsByClassName("detail-characters-list clearfix") ??
        [];

    var videoPromotion =
        animeDetailed.getElementsByClassName("video-promotion") ?? [];
    String? videoUrl;
    if (videoPromotion.isNotEmpty) {
      videoUrl = videoPromotion.first
          .getElementsByTagName("a")
          .first
          .attributes["href"];
    }

    return AnimeDetailedHtml(
      fromCache: false,
      videoUrl: videoUrl,
      lastUpdated: DateTime.now(),
      featured: featuredFromHtml(animeDetailed, null),
      news: featuredFromHtml(animeDetailed, null, category: 'news'),
      forumTopicsHtml: forumTopicsHtmlFromHtml(animeDetailed),
      links: _getAnimeLinks(animeDetailed),
      animeReviewList: [],
      adaptedNodes: _getAdaptedNodes(animeDetailed),
      additionalTitles: _getAddtionaTitles(animeDetailed),
      mangaCharaList: type == ContentType.anime
          ? []
          : animeDetailed
              .querySelectorAll('.detail-characters-list table')
              .map((e) {
              final tds = e.querySelectorAll('td');
              final pictureUrl = getPictureUrl(tds[0]);
              final node = getNodeFromElement(tds[0]);
              return MangaCharacterHtml(
                characterId: node.id,
                characterName: node.title,
                animePicture: pictureUrl,
                characterType: tds[1].querySelector('small')?.text.trim(),
              );
            }).toList(),
      characterHtmlList: charactersAndStaffs.isEmpty
          ? []
          : charactersAndStaffs.first
              .getElementsByTagName("tr")
              .where((element) =>
                  (element
                          .getElementsByClassName("h3_characters_voice_actors")
                          .length ??
                      0) !=
                  0)
              .map((row) => animeCharacterHtmlfromHtml(row))
              .where(_nonNull)
              .map((e) => e!)
              .toList(),
      interestStacks: interestStackListFromHtml(
          animeDetailed.querySelectorAll('.detail-stack-block .column-item')),
    );
  }

  static List<AdditionalTitle> _getAddtionaTitles(Document document) {
    return document
        .querySelectorAll('.js-alternative-titles .spaceit_pad')
        .expand((e) {
          final langElement = e.querySelector('.dark_text');
          final language = langElement?.text.trim() ?? '';
          if (!language.equalsIgnoreCase('English:')) {
            langElement?.remove();
            final title = e.text.trim();
            if (title.isNotBlank && language.isNotBlank) {
              return [AdditionalTitle(title: title, language: language)];
            }
          }
          return [null];
        })
        .where(_nonNull)
        .map((e) => e!)
        .toList();
  }

  static List<AnimeLink> _getAnimeLinks(Document document) {
    final streamLinks =
        document.querySelectorAll('.broadcasts .broadcast a').map((e) {
      var title = e.attributes['title'] ?? e.text.trim();
      return AnimeLink(
        url: e.attributes['href'] ?? '',
        name: title,
        linkType: LinkType.streaming,
        imageUrl: getDomainAsset(title),
      );
    }).toList();
    final externalLinks =
        document.querySelectorAll('.external_links').expand((element) {
      LinkType linkType = LinkType.resources;
      var previousElementSibling = element.previousElementSibling;
      if (previousElementSibling != null) {
        if (previousElementSibling.text
            .trim()
            .toLowerCase()
            .contains('available')) {
          linkType = LinkType.availableAt;
        } else {
          linkType = LinkType.resources;
        }
      }
      return element.querySelectorAll('a.link').map((e) {
        return AnimeLink(
          url: e.attributes['href'] ?? '',
          name: e.text.trim(),
          linkType: linkType,
          imageUrl: e.querySelector('img')?.attributes['src'],
        );
      });
    }).toList();

    return [
      ...streamLinks,
      ...externalLinks,
    ];
  }

  static List<dal.Node> _getAdaptedNodes(Document document) {
    return (document.querySelectorAll('.anime_detail_related_anime tr') ?? [])
        .expand((e) {
          var tds = e.querySelectorAll('td') ?? [];
          var tryAt = tds.tryAt(0);
          if (tryAt?.text != null &&
              tryAt!.text.contains('Adaptation') &&
              tds.tryAt(1) != null) {
            return tds[1]
                .querySelectorAll('a')
                .map((e) => getNodeFromElement(e))
                .where(_nonNull)
                .where((e) =>
                    e.id != null && e.title != null && e.nodeCategory != null)
                .toList();
          }
          return <dal.Node>[];
        })
        .where(_nonNull)
        .toList();
  }

  static List<InterestStack> interestStackListContentFromHtml(
    Document p0, [
    bool forContent = true,
  ]) {
    return interestStackListFromHtml(p0.querySelectorAll(
        '${forContent ? ".stacks" : ".search-list"} .column-item'));
  }

  static List<InterestStack> interestStackListFromHtml(List<Element> elements) {
    return elements
            .map((e) => InterestStack(
                  id: PathUtils.getIdAnchor(e),
                  updatedAt: _getBefore(_getText(e, '.detail .stat'),
                      startPattern: '·'),
                  title: unescape.convert(
                      e.querySelector('.detail .title')?.text.trim() ?? ''),
                  username: e.querySelector('.detail .tag a')?.text.trim(),
                  description: _getText(e, '.text'),
                  entries: _getBeforeInt(
                      e.querySelector('.detail .stat')?.text ?? '',
                      endPattern: 'Entries'),
                  reStacks: _getInt(e, '.foot .stack-balloon') ??
                      _getBeforeInt(
                          e.querySelector('.detail .stat')?.text ?? '',
                          endPattern: 'Restacks',
                          startPattern: '·'),
                  imageUrls: e
                      .querySelectorAll('.img .edge img')
                      .map((f) => f.attributes['src'])
                      .where(_nonNull)
                      .map((e) => e!)
                      .toList(),
                ))
            .toList() ??
        [];
  }

  static InterestStackDetailed? interestStackDetailedFromHtml(
      Document document, int id) {
    final sd = document.querySelector('.stacks-detail');
    if (sd == null) return null;

    final List<AnimeDetailed> entries =
        sd.querySelectorAll('.seasonal-anime-list .seasonal-anime').map((e) {
      final prodsrc = e.querySelectorAll('.prodsrc .info .item') ?? [];
      final title = e.querySelector('.link-title')?.text.trim();
      return AnimeDetailed(
        title: title,
        alternateTitles: AlternateTitles(
          en: e.querySelector('.h3_anime_subtitle')?.text.trim(),
          ja: title,
        ),
        id: PathUtils.getIdAnchor(e.querySelector('.title')),
        mediaType: prodsrc.tryAt()?.text.trim(),
        status: prodsrc.tryAt(1)?.text.trim(),
        additonalInfo: prodsrc.tryAt(2)?.text.trim(),
        mainPicture: getPicture(e.querySelector('.image')),
        synopsis: _escape(e.querySelector('.synopsis .preline')?.text ?? ''),
        mean: double.tryParse(
            e.querySelector('.information .score')?.text.trim() ?? ''),
        numListUsersFormatted:
            _escape(e.querySelector('.information .member')?.text.trim() ?? ''),
        genres: e
            .querySelectorAll('.genres .genre')
            .map((f) => MalGenre(
                  id: PathUtils.getIdAnchor(f),
                  name: f.text.trim(),
                ))
            .toList(),
      );
    }).toList();

    final String? username = sd.querySelector('.information a')?.text.trim();
    sd.querySelector('.information a')?.remove();
    sd.querySelector('.information span')?.remove();
    final information = sd.querySelector('.information')?.text.trim();

    return InterestStackDetailed(
      node: InterestStack(
        updatedAt: _getBefore(information ?? '', startPattern: '|'),
        id: id,
        entries: entries.length,
        description: _escape(sd.querySelector('.introduction')?.text ?? ''),
        username: username,
        reStacks: int.tryParse(
            sd.querySelector('.stack-balloon p')?.text.trim() ?? ''),
        title:
            unescape.convert(sd.querySelector('h2.title')?.text.trim() ?? ''),
      ),
      myAnimeListStacks: interestStacksFromHtml(
        document.querySelectorAll('.content-right .side-list').tryAt(1),
        'MyAnimeList',
      ),
      similarStacks: interestStacksFromHtml(
        document.querySelectorAll('.content-right .side-list').tryAt(),
        'removed-user',
      ),
      createdAt: _getBefore(information ?? '', endPattern: '|'),
      contentDetailedList: entries,
    );
  }

  static List<InterestStack>? interestStacksFromHtml(Element? elemet,
      [String? defaultUsernam]) {
    String? imageUrl(Element e) =>
        tryGet(e.querySelector('img')?.attributes, 'src');
    return elemet
        ?.querySelectorAll('.column-item')
        .map((e) => InterestStack(
              id: PathUtils.getIdAnchor(e),
              title: _getText(e, '.detail .title'),
              username: e
                      .querySelector('.detail .by')
                      ?.nextElementSibling
                      ?.text
                      .trim() ??
                  defaultUsernam,
              imageUrls: imageUrl(e) != null ? [imageUrl(e)!] : [],
              entries: _getBeforeInt(
                  e.querySelector('.detail span')?.text ?? '',
                  endPattern: 'Entries'),
              reStacks: _getBeforeInt(
                  e.querySelector('.detail span')?.text ?? '',
                  endPattern: 'Restacks',
                  startPattern: '·'),
            ))
        .toList();
  }

  static int? _getInt(Element element, String selector) {
    return int.tryParse(_getText(element, selector));
  }

  static String _getText(Element element, String selector) {
    return _escape(element.querySelector(selector)?.text ?? '');
  }

  static String _escape(String? text) {
    return unescape.convert(text?.trim() ?? '');
  }

  static int? _getBeforeInt(String text,
      {String? endPattern, String? startPattern}) {
    return int.tryParse(
        _getBefore(text, endPattern: endPattern, startPattern: startPattern) ??
            '');
  }

  static String? _getBefore(
    String text, {
    String? endPattern,
    String? startPattern,
  }) {
    try {
      text = unescape.convert(text);
      int startIndex = 0;
      startIndex = text.indexOf(startPattern ?? '');
      if (startIndex != -1) {
        int endIndex;
        endIndex = text.indexOf(endPattern ?? '');
        if (endIndex != -1) {
          startIndex = startPattern != null ? (startIndex + 1) : startIndex;
          return text.substring(startIndex, endIndex).trim();
        }
      }
    } catch (e) {
      logDal(e);
    }
    return null;
  }

  static AnimeReviewHtml? animeReviewHtmlfromHtml(Element? review) {
    if (review == null) return null;

    String? userName, timeAdded, userPicture, overallRating, reviewText;
    List<String> tags = [], reactionBox = [];
    dal.Node? relatedNode;

    final img = review.querySelector('.thumb img');
    final body = review.querySelector('.body');

    if (img != null) {
      userPicture = img.attributes['src'];
    }

    if (body != null) {
      timeAdded = body.querySelector('.update_at')?.text;
      userName = body.querySelector('.username a')?.text;
      reviewText = HtmlUnescape()
          .convert((body.querySelector('.text')?.text ?? '').trim());
      overallRating = body.querySelector('.rating .num')?.text;

      tags = body.querySelectorAll('.tags .tag').map((e) {
            final tag = e.firstChild?.text?.trim() ?? '';
            return tag.isNotEmpty ? tag : (e.text.trim() ?? '');
          }).toList() ??
          [];
    }

    final thumb = review.querySelector('.thumb-right');
    if (thumb != null) {
      final href = thumb.querySelector('a')?.attributes['href'];
      final image = HtmlParsers.getImageSrcSet(thumb);
      relatedNode = dal.Node(
        id: PathUtils.getIdUrl(href),
        title: PathUtils.getTitle(href),
        url: href,
        mainPicture: Picture(large: image['large'], medium: image['medium']),
      );
    }

    final dataReactions = review.attributes['data-reactions'] ?? '{}';
    if (dataReactions.isNotEmpty) {
      final jsonDecoded = jsonDecode(dataReactions);
      if (jsonDecoded != null && jsonDecoded['count'] != null) {
        final count = jsonDecoded['count'] ?? <String>[];
        reactionBox = (count as List)
            .map((e) => e?.toString())
            .where((e) => e != null)
            .map((e) => e!)
            .toList();
      }
    }

    return AnimeReviewHtml(
      overallRating: overallRating,
      reviewText: reviewText,
      timeAdded: timeAdded,
      userName: userName,
      userPicture: userPicture,
      reactionBox: reactionBox,
      tags: tags,
      relatedNode: relatedNode,
      fromCache: true,
    );
  }

  static parseLiveChartSchedule(Document? doc) {
    if (doc == null) return null;
    final cards = doc.querySelectorAll('.anime-card') ?? [];
    return cards
        .map((e) {
          final countDownEle = e.querySelector('.episode-countdown');
          if (countDownEle != null) {
            final timestamp =
                int.tryParse(countDownEle.attributes['data-timestamp'] ?? '');
            final episode = int.tryParse(
                countDownEle.attributes['data-label']?.replaceAll('EP', '') ??
                    '');
            if (timestamp != null && episode != null) {
              final relatedLinksMap = {};
              e.querySelectorAll('.related-links a').forEach((rl) {
                final className = rl.className;
                final href = rl.attributes['href'];
                if (href != null) {
                  relatedLinksMap[className.replaceAll("-icon", '')] = href;
                }
              });

              if (relatedLinksMap.isNotEmpty) {
                return {
                  'timestamp': timestamp,
                  'episode': episode,
                  'relatedLinks': relatedLinksMap,
                };
              }
            }
          }
        })
        .where((e) => e != null)
        .toList();
  }

  static parseUserAboutPage(Document? p0) {
    if (p0?.body != null) {
      bool modern = false;
      String? about = p0
          ?.querySelector('.user-profile-about .word-break')
          ?.innerHtml
          .trim();
      if (about == null) {
        about = p0?.querySelector('#modern-about-me')?.innerHtml.trim();
        if (about != null) {
          modern = true;
        }
      }
      return {
        'about': about,
        'modern': modern,
      };
    }
  }

  static parseUserFriends(Document? p0) {
    final body = p0?.body;
    if (body != null) {
      final friends = body
          .querySelectorAll('.friend .boxlist')
          .map((e) => getUserFromElement(e, true))
          .where((e) => e['username'] != null)
          .map((e) {
        final username = e['username'];
        final picture = e['mainPicture'] as Picture;
        final extras = (e['e'] as Element).querySelectorAll('.fn-grey2');
        final first = extras.tryAt();
        final second = extras.tryAt(1);
        return FriendV4(
          friendsSince: second?.innerHtml.trim(),
          lastOnline: first?.innerHtml.trim(),
          user: UserV4(
            username: username,
            images: Images(
              jpg: ImageUrl(imageUrl: picture.large ?? picture.medium),
            ),
          ),
        );
      }).toList();
      return friends;
    }
  }

  static getUserFromElement(Element? ele, [bool includeElement = false]) {
    var username = PathUtils.getTitleAnchor(ele);
    return {
      'username': username,
      'mainPicture': getPicture(ele),
      if (includeElement) 'e': ele,
    };
  }

  static parseCharacterAllPage(Document p0, String category) {
    var allchars = [];
    var allStaff = [];
    if (p0.body != null) {
      allchars = p0.body!
          .querySelectorAll('.$category-character-container table tr')
          .map((e) {
            final tdAll = e.querySelectorAll('td');
            final charImageE = tdAll.tryAt(0);
            final charInfoE = tdAll.tryAt(1);
            final staffInfoE = tdAll.tryAt(2);
            final charInfo = _extractCharcInfo(charInfoE, category);
            final staffInfoList = _extractStaffInfoList(staffInfoE);
            if (charInfo['name'] == null || charInfo['id'] == null) return null;
            return {
              'charInfo': charInfo,
              'characterImage': getImageSrcSet(charImageE),
              'staffInfoList': staffInfoList,
            };
          })
          .where(_nonNull)
          .toList();
      var staffBorder = p0.body!.querySelectorAll('.border_solid').tryAt(1);
      while (staffBorder?.nextElementSibling != null &&
          (staffBorder?.nextElementSibling?.localName ?? '').equals('table')) {
        staffBorder = staffBorder!.nextElementSibling;
        final staffInfo = getNodeFromElement(staffBorder);
        if (staffInfo.id != null && staffInfo.title != null) {
          allStaff.add({
            'id': staffInfo.id,
            'name': staffInfo.title,
            'image': staffInfo.mainPicture?.toJson(),
            'role': staffBorder?.querySelector('.spaceit_pad')?.text.trim(),
          });
        }
      }
    }
    return {
      'characters': allchars,
      'staffs': allStaff,
    };
  }

  static List<dynamic> _extractStaffInfoList(Element? staffInfoE) {
    var vaEL =
        staffInfoE?.querySelectorAll('.js-anime-character-va-lang') ?? [];
    return vaEL
        .map((vaE) {
          final va = {};
          va['id'] = PathUtils.getIdAnchor(vaE);
          va['name'] = vaE.querySelector('a')?.text.trim();
          va['language'] =
              vaE.querySelector('.js-anime-character-language')?.text.trim();
          va['image'] = getImageSrcSet(vaE);
          if (va['id'] == null || va['name'] == null) return null;
          return va;
        })
        .where(_nonNull)
        .toList();
  }

  static Map<dynamic, dynamic> _extractCharcInfo(
      Element? charInfoE, String? category) {
    Map<dynamic, dynamic> charInfo = {};
    charInfo['id'] = PathUtils.getIdAnchor(charInfoE);
    var roleAndName =
        charInfoE?.querySelector('.js-chara-roll-and-name')?.text.trim();
    if (roleAndName != null && roleAndName.contains('_')) {
      var indexOf = roleAndName.indexOf('_');
      charInfo['role'] = roleAndName.substring(0, roleAndName.indexOf('_'));
      charInfo['name'] = roleAndName.substring(indexOf + 1);
    }
    charInfo['favorites'] = int.tryParse(charInfoE
                ?.querySelector('.js-$category-character-favorites')
                ?.text
                .trim() ??
            '') ??
        0;
    return charInfo;
  }

  static bool _nonNull(dyna) {
    return dyna != null;
  }

  static parseClubPage(Document? p0) {
    final body = p0?.body;
    if (body != null) {
      final wrapper = body.querySelector('#contentWrapper');
      if (wrapper != null) {
        String? title = wrapper.querySelector('h1.h1')?.text;
        final content = wrapper.querySelector('#content');
        if (content != null) {
          final tds =
              content.querySelector('table tbody tr')?.children.toList();
          final left = tds?.tryAt();
          final right = tds?.tryAt(1);
          if (left != null && right != null) {
            String? clubInfo =
                left.querySelector('.clearfix')?.innerHtml.trim();
            final headers = left.querySelectorAll('.normal_header');
            final members = headers
                .tryAt(1)
                ?.nextElementSibling
                ?.querySelectorAll('.borderClass')
                .map((e) => getUserFromElement(e))
                .toList();
            final clubPictures = headers
                .tryAt(2)
                ?.nextElementSibling
                ?.querySelectorAll('.picSurround')
                .map((e) => getPicture(e))
                .toList();
            final forumTopics = _forumTopics(left);
            final commentsSection =
                _getElementByContent(headers, 'Club Comments')
                    ?.nextElementSibling;
            final comments = _getComments(commentsSection);
            return {
              'title': title,
              'information': clubInfo,
              'members': members,
              'pictures': clubPictures,
              'forumTopics': forumTopics,
              'comments': comments,
              'details': _getClubDetails(right),
            };
          }
        }
      }
    }
  }

  static _forumTopics(Element ele) {
    return ele
            .querySelector('#forumTopics')
            ?.querySelectorAll('tr')
            .map((e) => forumHtmlFromHtml(e))
            .where((e) => e.id != null)
            .toList() ??
        [];
  }

  static _getClubDetails(Element element) {
    final headers = element.querySelectorAll('.normal_header');

    final stats = _getElementByContent(headers, 'Club Stats');
    int? members = int.tryParse(
        stats?.nextElementSibling?.text.replaceAll('Members:', '').trim() ??
            '');
    int? pictures = int.tryParse(stats
            ?.nextElementSibling?.nextElementSibling?.text
            .replaceAll('Pictures:', '')
            .trim() ??
        '');
    String? category = stats
        ?.nextElementSibling?.nextElementSibling?.nextElementSibling?.text
        .replaceAll('Category:', '')
        .trim();
    String? created = stats?.nextElementSibling?.nextElementSibling
        ?.nextElementSibling?.nextElementSibling?.text
        .trim();

    final staff = _getElementByContent(headers, 'Club Staff');
    final type = _getElementByContent(headers, 'Club Type');
    final staffList = [];
    final animeList = [];
    final mangaList = [];
    final characterList = [];
    _populateStaffList(staff, type, staffList);
    final animeRelations = _getElementByContent(headers, 'Anime Relations');
    final mangaRelations = _getElementByContent(headers, 'Manga Relations');
    final characterRelations =
        _getElementByContent(headers, 'Character Relations');
    _populateRelationsList(animeRelations, animeList, 'anime');
    _populateRelationsList(mangaRelations, mangaList, 'manga');
    _populateRelationsList(characterRelations, characterList, 'character');

    return {
      'picture': getPicture(element),
      'members': members,
      'category': category,
      'pictures': pictures,
      'created': created,
      'staffs': staffList,
      'clubRelations': {
        'anime': animeList,
        'manga': mangaList,
        'character': characterList,
      }
    };
  }

  static void _populateStaffList(
      Element? staff, Element? type, List<dynamic> staffList) {
    var currentStaff = staff?.nextElementSibling;
    int count = 0;
    while (type != null &&
        currentStaff != null &&
        currentStaff != type &&
        count < 20) {
      final staffA = currentStaff.querySelector('a');
      final user = getUserFromElement(staffA);
      staffA?.remove();
      if (user['username'] != null && user['username'].toString().isNotBlank) {
        staffList.add({'user': user, 'position': currentStaff.text.trim()});
      }
      currentStaff = currentStaff.nextElementSibling;
      count++;
    }
  }

  static void _populateRelationsList(
    Element? startElement,
    List<dynamic> list,
    String category, [
    int limit = 101,
  ]) {
    var currentElement = startElement?.nextElementSibling;
    int count = 0;
    while (currentElement != null &&
        !'BR'.equalsIgnoreCase(currentElement.localName) &&
        count < limit) {
      final anchor = currentElement.querySelector('a');
      if (anchor != null) {
        final href = anchor.attributes['href'];
        if (href != null) {
          final uri = Uri.tryParse(href);
          if (uri != null) {
            if (category.equalsIgnoreCase(uri.pathSegments.tryAt())) {
              final id = int.tryParse(uri.pathSegments.tryAt(1) ?? '');
              if (id != null) {
                list.add({
                  'id': id,
                  'title': anchor.text.trim(),
                });
              }
            }
          }
        }
      }
      currentElement = currentElement.nextElementSibling;
      count++;
    }
  }

  static _getComments(Element? element) {
    if (element != null) {
      final comments = element.querySelectorAll('.bgColor1');
      comments.addAll(element.querySelectorAll('.bgNone'));
      final formatted = comments
          .map((e) {
            String id = e.id.replaceAll('comment', '');
            final picLeading = e.querySelector('.picSurround');
            final user = getUserFromElement(picLeading);
            final parentTD = picLeading?.parent?.nextElementSibling;
            final small = parentTD?.children.tryAt()?.querySelector('small');
            final longAgo = small?.text.replaceAll('|', '').trim();
            small?.parent?.remove();
            final comment = parentTD?.innerHtml.trim();
            return {
              'id': int.tryParse(id),
              'by': user,
              'longAgo': longAgo,
              'content': comment,
            };
          })
          .where((e) => e['id'] != null)
          .toList();
      formatted.sort((a, b) => b['id'].compareTo(a['id']));
      return formatted;
    }
  }

  static Element? _getElementByContent(
      List<Element?>? elements, String searchText) {
    if (elements != null) {
      return elements
          .where((e) =>
              e?.text.toLowerCase().contains(searchText.toLowerCase()) ?? false)
          .toList()
          .tryAt();
    }
    return null;
  }

  static parseClubPageViewAll(Document? p0, String? type) {
    List data = [];
    final body = p0?.body;
    if (body == null) return data;
    switch (type) {
      case 'members':
        data = body
                .querySelector('#content')
                ?.querySelectorAll('.borderClass')
                .map((e) => getUserFromElement(e))
                .where((e) => e['username'] != null)
                .toList() ??
            [];
        break;
      case 'forum':
        data = _forumTopics(body);
        break;
      case 'comments':
        data = _getComments(body.querySelector('#content'));
        break;
    }
    return data;
  }

  static parseUserHistory(Document? p0, String? type) {
    final content = p0?.body?.querySelector('.history_content_wrapper');
    if (content != null) {
      final history = content
          .querySelectorAll('tr')
          .where((e) => e.querySelector('.normal_header') == null)
          .map((e) {
            final a = e.querySelector('a');
            final url = a?.attributes.tryAt('href') ?? '';
            final id = queryParamsUri(Uri.tryParse(url), 'id');
            final category = url.isBlank
                ? null
                : (url.contains('anime') ? 'anime' : 'manga');
            final title = a?.text.trim();
            e.querySelector('td.borderClass a')?.remove();
            final splits = e
                .querySelector('td.borderClass')
                ?.text
                .trim()
                .replaceAll('\n', '')
                .split(' ');
            final history = splits
                ?.map((e) => e.trim())
                .where((e) => e.isNotBlank)
                .join(' ');
            final time = unescape.convert(
                e.querySelectorAll('td.borderClass').tryAt(1)?.text.trim() ??
                    '');
            return {
              'id': id,
              'title': title,
              'history': history,
              'category': category,
              'time': time,
            };
          })
          .where((e) => e['id'] != null)
          .toList();
      return history;
    }
  }
}
