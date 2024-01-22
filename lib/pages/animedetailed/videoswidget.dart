import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/main.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dal_commons/dal_commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoTile {
  final String? title;
  final String? url;
  final String? imageUrl;
  VideoTile(this.title, this.url, this.imageUrl);
}

class VideosWidget extends StatefulWidget {
  final AnimeVideoV4? videos;
  final double horizPadding;
  final List<ThemeSong>? openingSongs;
  final List<ThemeSong>? endingSongs;
  const VideosWidget({
    required this.horizPadding,
    this.videos,
    Key? key,
    this.openingSongs,
    this.endingSongs,
  }) : super(key: key);

  @override
  State<VideosWidget> createState() => _VideosWidgetState();
}

class _VideosWidgetState extends State<VideosWidget> {
  late List<String> tabs;
  int pageIndex = 0;
  bool hasPromos = false;
  bool hasMusicVideos = false;
  bool hasEpisodes = false;
  bool hasOpenings = false;
  bool hasEnding = false;
  @override
  void initState() {
    super.initState();
    hasPromos = !nullOrEmpty(widget.videos?.promo);
    hasMusicVideos = !nullOrEmpty(widget.videos?.musicVideos);
    hasEpisodes = !nullOrEmpty(widget.videos?.episodes);
    hasOpenings = !nullOrEmpty(widget.openingSongs);
    hasEnding = !nullOrEmpty(widget.endingSongs);
    tabs = [
      if (hasPromos) S.current.Promotional,
      if (hasMusicVideos) S.current.Music_Videos,
      if (hasEpisodes) S.current.Episodes,
      if (hasOpenings) S.current.Opening_Songs,
      if (hasEnding) S.current.Ending_Songs,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tabBar,
          SB.h20,
          IndexedStack(index: pageIndex, children: [
            if (hasPromos) promoWidget,
            if (hasMusicVideos) musicVidoeWidget,
            if (hasEpisodes) episodesWidget,
            if (hasOpenings) themesWidget(widget.openingSongs!),
            if (hasEnding) themesWidget(widget.endingSongs!),
          ]),
        ],
      ),
    );
  }

  Widget get promoWidget {
    return videoTiles(widget.videos!.promo
            ?.map((e) => VideoTile(
                  e.title,
                  e.trailer?.url,
                  e.trailer?.images?.largeImageUrl,
                ))
            .toList() ??
        []);
  }

  Widget get musicVidoeWidget {
    return videoTiles(widget.videos?.musicVideos
            ?.map((e) => VideoTile(
                  e.title,
                  e.video?.url,
                  e.video?.images?.largeImageUrl,
                ))
            .toList() ??
        []);
  }

  Widget get episodesWidget {
    return videoTiles(
        widget.videos!.episodes
                ?.map((e) => VideoTile(
                    '${e.episode}: ${e.title}', e.url, e.images?.jpg?.imageUrl))
                .toList() ??
            [],
        false);
  }

  Widget videoTiles(List<VideoTile> tiles, [bool useYTIcon = true]) {
    BorderRadius borderRadius = BorderRadius.circular(6);
    return Container(
      height: 170,
      child: ListView.builder(
        itemCount: tiles.length,
        padding: EdgeInsets.symmetric(horizontal: widget.horizPadding + 10),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Container(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: borderRadius,
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                              tiles[i].imageUrl ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: borderRadius,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: _videoIconWidget(borderRadius, useYTIcon),
                        ),
                        onTap: tiles[i].url == null
                            ? () {}
                            : () => launchURLWithConfirmation(tiles[i].url!,
                                context: context),
                      ),
                    ),
                  ),
                ),
                SB.h10,
                title(tiles[i].title, textOverflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _videoIconWidget([
    BorderRadius? borderRadius,
    bool useYTIcon = true,
  ]) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(borderRadius: borderRadius),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(6),
        child: Image.asset(useYTIcon
            ? 'assets/images/youtube.png'
            : 'assets/images/mal-icon.png'),
      ),
    );
  }

  Widget get _tabBar => TabBar(
        isScrollable: true,
        onTap: (index) {
          if (mounted)
            setState(() {
              pageIndex = index;
            });
        },
        padding: EdgeInsets.symmetric(horizontal: widget.horizPadding),
        tabs: tabs
            .map((e) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                  child: Text(
                    e,
                    style: TextStyle(fontSize: 13.0),
                  ),
                ))
            .toList(),
      );

  Widget themesWidget(List<ThemeSong> data) {
    return Container(
      height: 170,
      child: GridView.builder(
        itemCount: data.length,
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: .3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 0,
          crossAxisCount: 2,
        ),
        padding: EdgeInsets.symmetric(
            horizontal: widget.horizPadding + 10, vertical: 4),
        itemBuilder: (context, index) => _buildThemeSongTile(data[index]),
      ),
    );
  }

  Widget _buildThemeSongTile(ThemeSong song) {
    return Card(
      child: InkWell(
        onTap: () {
          var songname = getSongName(song.name);
          launchURLWithConfirmation(
              'https://www.youtube.com/results?search_query=' +
                  (songname == null ? song.name! : songname),
              context: context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _videoIconWidget(),
              SB.w10,
              Expanded(
                child: title(
                  song.name ?? '',
                  textOverflow: TextOverflow.fade,
                  selectable: false,
                ),
              ),
              ToolTipButton(
                onTap: () => Clipboard.setData(ClipboardData(text: song.name!)),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                usePadding: true,
                child: Icon(
                  Icons.copy,
                  size: 16,
                ),
                message: S.current.Copy,
              )
            ],
          ),
        ),
      ),
    );
  }

  String? getSongName(String? text) {
    try {
      text = text?.substring(text.indexOf('"') + 1) ?? '';
      return text.substring(0, text.indexOf('"'));
    } catch (e) {}
    return null;
  }
}
