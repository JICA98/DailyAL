import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/generated/anime_genres.dart' as anime_gen;
import 'package:dailyanimelist/generated/manga_genres.dart' as manga_gen;
import 'package:dailyanimelist/generated/anime_producers.dart' as producers_gen;
import 'package:dailyanimelist/generated/manga_magazines.dart' as magazines_gen;

/// Previous/Next Page
enum PageDirection {
  /// Previous Page
  PREVIOUS,

  /// Next Page
  NEXT
}

/// Ranking Type for the anime list
enum RankingType {
  /// Top Anime Series
  ALL,

  /// Top Airing Anime
  AIRING,

  /// Top Upcoming Anime
  UPCOMING,

  /// Top Anime TV Series
  TV,

  /// Top Anime OVA Series
  OVA,

  /// Top Anime Movies
  MOVIE,

  /// Top Anime Specials
  SPECIAL,

  /// Top Anime by Popularity
  BYPOPULARITY,

  /// Top Favorited Anime
  FAVOURITE,

  ONA,
}

/// Ranking Type for the manga list
enum MangaRanking {
  all,

  manga,

  oneshots,

  doujin,

  lightnovels,

  novels,

  manhwa,

  manhua,

  bypopularity,

  favorite
}

enum StatusType {
  airing,
  complete,
  to_be_aired,
  upcoming,
  publishing,
  to_be_published,
  hiatus,
  discontinued,
}

enum RatedType {
  g, //	G - All Ages
  pg, //	PG - Children
  pg13, //	PG-13 - Teens 13 or older
  r17, //	R - 17+ recommended (violence & profanity)
  r, //	R+ - Mild Nudity (may also contain violence & profanity)
  rx, //	Rx - Hentai (extreme sexual content/nudity)
}

enum OrderType {
  mal_id,
  title,
  start_date,
  end_date,
  score,
  type,
  members,
  id,
  episodes,
  chapters,
  rating,
  volumes,
  scored_by,
  rank,
  popularity,
  favorites,
}

enum ContentSortType { asc, desc }

enum AnimeType { tv, ova, movie, special, ona, music }

enum MangaType { manga, novel, oneshot, doujin, manhwa, manhua, lightnovel }

const mangaRankingMap = {
  MangaRanking.all: 'all',
  MangaRanking.manga: 'manga',
  MangaRanking.oneshots: 'oneshots',
  MangaRanking.doujin: 'doujin',
  MangaRanking.lightnovels: 'lightnovels',
  MangaRanking.novels: 'novels',
  MangaRanking.manhwa: 'manhwa',
  MangaRanking.manhua: 'manhua',
  MangaRanking.bypopularity: 'bypopularity',
  MangaRanking.favorite: 'favorite',
};

Map<MangaType, String> mangaTypeMap = {
  MangaType.manga: "manga",
  MangaType.novel: "novel",
  MangaType.oneshot: "oneshot",
  MangaType.doujin: "doujin",
  MangaType.manhwa: "manhwa",
  MangaType.manhua: "manhua",
  MangaType.lightnovel: 'lightnovel'
};

Map<ContentSortType, String> sortTypeMap = {
  ContentSortType.asc: "ascending",
  ContentSortType.desc: "descending"
};

Map<OrderType, String> animeOrderType = {
  OrderType.title: "title",
  OrderType.start_date: "start_date",
  OrderType.end_date: "end_date",
  OrderType.score: "score",
  OrderType.members: "members",
  OrderType.episodes: "episodes",
  OrderType.rating: "rating",
  OrderType.scored_by: "scored_by",
  OrderType.rank: "rank",
  OrderType.popularity: "popularity",
  OrderType.mal_id: 'mal_id',
  OrderType.favorites: "favorites",
};

Map<OrderType, String> mangaOrderType = {
  OrderType.title: "title",
  OrderType.start_date: "start_date",
  OrderType.end_date: "end_date",
  OrderType.score: "score",
  OrderType.members: "members",
  OrderType.chapters: "chapters",
  OrderType.volumes: "volumes",
  OrderType.scored_by: "scored_by",
  OrderType.rank: "rank",
  OrderType.popularity: "popularity",
  OrderType.favorites: "favorites",
  OrderType.mal_id: 'mal_id',
};

Map<RatedType, String> ratedMap = {
  RatedType.g: "G - All Ages",
  RatedType.pg: "PG - Children",
  RatedType.pg13: "PG-13 - Teens 13 or older",
  RatedType.r17: "R - 17+ recommended (violence & profanity)",
  RatedType.r: "R+ - Mild Nudity (may also contain violence & profanity)",
  RatedType.rx: "Rx - Hentai (extreme sexual content/nudity)"
};

Map<String, String> inverseRatedMap = {
  'g': "G - All Ages",
  'pg': "PG - Children",
  'pg_13': "PG-13 - Teens 13 or older",
  'r': "R - 17+ recommended (violence & profanity)",
  'r+': "R+ - Mild Nudity (may also contain violence & profanity)",
  'rx': "Rx - Hentai (extreme sexual content/nudity)"
};

Map<RatedType, String> ratedMapSFW = {
  RatedType.g: "G - All Ages",
  RatedType.pg: "PG - Children",
  RatedType.pg13: "PG-13 - Teens 13 or older",
  RatedType.r17: "R - 17+ recommended (violence & profanity)"
};

Map<StatusType, String> animeStatusMap = {
  StatusType.airing: "airing",
  StatusType.complete: "complete",
  StatusType.to_be_aired: "to_be_aired",
  StatusType.upcoming: "upcoming"
};

Map<StatusType, String> mangaStatusMap = {
  StatusType.publishing: "publishing",
  StatusType.complete: "complete",
  StatusType.hiatus: "hiatus",
  StatusType.upcoming: "upcoming",
  StatusType.discontinued: "discontinued"
};

const Map<StatusType, String> jikanAnimeStatusMap = {
  StatusType.airing: "airing",
  StatusType.complete: "complete",
  StatusType.upcoming: "upcoming"
};

const Map<String, String> animeStatusInverseMap = {
  "airing": 'currently_airing',
  "complete": 'finished_airing',
  "upcoming": 'not_yet_aired',
};

const Map<String, String> mangaStatusInverseMap = {
  "publishing": 'publishing',
  "hiatus": 'hiatus',
  "discontinued": 'discontinued',
  'complete': 'finished',
};

const Map<StatusType, String> jikanMangaStatusMap = {
  StatusType.publishing: "publishing",
  StatusType.complete: "complete",
  StatusType.upcoming: "upcoming"
};

Map<RankingType, String> rankingMap = {
  RankingType.ALL: "all",
  RankingType.AIRING: "airing",
  RankingType.BYPOPULARITY: "bypopularity",
  RankingType.FAVOURITE: "favorite",
  RankingType.MOVIE: "movie",
  RankingType.OVA: "ova",
  RankingType.SPECIAL: "special",
  RankingType.TV: "tv",
  RankingType.UPCOMING: "upcoming",
  RankingType.ONA: "ona",
};

Map<RankingType, String> desiredTopAnimeOrder = {
  RankingType.UPCOMING: S.current.Top_Upcoming_Anime,
  RankingType.BYPOPULARITY: S.current.Most_Popular_Anime,
  RankingType.ALL: S.current.Top_Anime_by_Score,
  RankingType.AIRING: S.current.Top_Airing_Anime,
  RankingType.FAVOURITE: S.current.All_time_Favorites,
  RankingType.MOVIE: S.current.Top_Anime_Movies,
  RankingType.OVA: S.current.Top_OVA,
  RankingType.SPECIAL: S.current.Top_Specials,
  RankingType.TV: S.current.Top_TV_Shows,
  RankingType.ONA: S.current.Top_ONA,
};

Map<RankingType, String> desiredTopAnimeOrderSS(S ss) {
  return {
    RankingType.UPCOMING: ss.Top_Upcoming_Anime,
    RankingType.BYPOPULARITY: ss.Most_Popular_Anime,
    RankingType.ALL: ss.Top_Anime_by_Score,
    RankingType.AIRING: ss.Top_Airing_Anime,
    RankingType.FAVOURITE: ss.All_time_Favorites,
    RankingType.MOVIE: ss.Top_Anime_Movies,
    RankingType.OVA: ss.Top_OVA,
    RankingType.SPECIAL: ss.Top_Specials,
    RankingType.TV: ss.Top_TV_Shows,
    RankingType.ONA: ss.Top_ONA,
  };
}

Map<MangaRanking, String> desiredMangaRankingMap = {
  MangaRanking.manhwa: S.current.Top_Manhwa,
  MangaRanking.all: S.current.Top_All_Manga,
  MangaRanking.manga: S.current.Top_Manga,
  MangaRanking.favorite: S.current.Top_Favorite_Manga,
  MangaRanking.bypopularity: S.current.Top_Manga_Bypopularity,
  MangaRanking.lightnovels: S.current.Top_Light_Novels,
  MangaRanking.manhua: S.current.Top_Manhua,
  MangaRanking.novels: S.current.Top_Novels,
  MangaRanking.oneshots: S.current.Top_Oneshots,
  MangaRanking.doujin: S.current.Top_Doujin,
};

Map<MangaRanking, String> desiredMangaRankingMapSS(S ss) => {
      MangaRanking.all: ss.Top_All_Manga,
      MangaRanking.manga: ss.Top_Manga,
      MangaRanking.oneshots: ss.Top_Oneshots,
      MangaRanking.doujin: ss.Top_Doujin,
      MangaRanking.lightnovels: ss.Top_Light_Novels,
      MangaRanking.novels: ss.Top_Novels,
      MangaRanking.manhwa: ss.Top_Manhwa,
      MangaRanking.manhua: ss.Top_Manhua,
      MangaRanking.bypopularity: ss.Top_Manga_Bypopularity,
      MangaRanking.favorite: ss.Top_Favorite_Manga
    };

enum SeasonType {
  ///January, February, March,
  WINTER,

  /// April, May, June
  SPRING,

  /// July, August, September
  SUMMER,

  /// October, November, December
  FALL
}

Map<SeasonType, String> seasonMap = {
  SeasonType.WINTER: "winter",
  SeasonType.SPRING: "spring",
  SeasonType.SUMMER: "summer",
  SeasonType.FALL: "fall",
};

Map<SeasonType, String> seasonMapCaps = {
  SeasonType.WINTER: "Winter",
  SeasonType.SPRING: "Spring",
  SeasonType.SUMMER: "Summer",
  SeasonType.FALL: "Fall",
};

Map<String, SeasonType> seasonMapInverse = {
  "fall": SeasonType.FALL,
  "summer": SeasonType.SUMMER,
  "spring": SeasonType.SPRING,
  "winter": SeasonType.WINTER
};

enum SortType { AnimeScore, AnimeNumListUsers }

Map<SortType, String> sortMap = {
  SortType.AnimeScore: "anime_score",
  SortType.AnimeNumListUsers: "anime_num_list_users"
};

/// watching
/// completed
/// on_hold
/// dropped
/// plan_to_watch
class MyStatus {
  static final String watching = "watching";
  static final String completed = "completed";
  static final String onHold = "on_hold";
  static final String dropped = "dropped";
  static final String planToWatch = "plan_to_watch";
  static final String reading = "reading";
  static final String planToRead = "plan_to_read";
}

Map<String, String> myAnimeStatusMap = {
  "watching": "Watching",
  "completed": "Completed",
  "on_hold": "On Hold",
  "dropped": "Dropped",
  "plan_to_watch": "Plan to Watch"
};

const allAnimeStatusMap = {
  "all": "All",
  "watching": "Watching",
  "completed": "Completed",
  "on_hold": "On Hold",
  "dropped": "Dropped",
  "plan_to_watch": "Plan to Watch"
};

Map<String, String> myMangaStatusMap = {
  "reading": "Reading",
  "completed": "Completed",
  "on_hold": "On Hold",
  "dropped": "Dropped",
  "plan_to_read": "Plan to Read"
};

const allMangaStatusMap = {
  "all": "All",
  "reading": "Reading",
  "completed": "Completed",
  "on_hold": "On Hold",
  "dropped": "Dropped",
  "plan_to_read": "Plan to Read"
};

final combinedStatusMap = {...allAnimeStatusMap, ...allMangaStatusMap};

enum SortOrder {
  Ascending,
  Descending,
}

enum AnimeListSortType {
  ///Descending
  list_score,

  ///Descending
  list_updated_at,

  ///Ascending
  anime_title,

  ///Descending
  anime_start_date,
}

Map<AnimeListSortType, String> animeListSortTypeMap = {
  AnimeListSortType.anime_start_date: "anime_start_date",
  AnimeListSortType.anime_title: "anime_title",
  AnimeListSortType.list_score: "list_score",
  AnimeListSortType.list_updated_at: "list_updated_at",
};

Map<AnimeListSortType, String> animeListSortTypeMapText = {
  AnimeListSortType.anime_title: "Anime Title",
  AnimeListSortType.list_updated_at: "List Updated At",
  AnimeListSortType.anime_start_date: "Anime Start Date",
  AnimeListSortType.list_score: "List Score",
};

Map<String, String> animeListSortMap = {
  "anime_title": "Title",
  "list_score": "List Score",
  "anime_start_date": "Start Date",
  "list_updated_at": "Updated At",
};

Map<String, SortOrder> animeListDefaultOrderMap = {
  "anime_title": SortOrder.Ascending,
  "list_score": SortOrder.Descending,
  "anime_start_date": SortOrder.Descending,
  "list_updated_at": SortOrder.Descending,
};

enum MangaListSortType {
  ///Descending
  list_score,

  ///Descending
  list_updated_at,

  ///Ascending
  manga_title,

  ///Descending
  manga_start_date,
}

Map<MangaListSortType, String> mangaListSortTypMap = {
  MangaListSortType.manga_start_date: "manga_start_date",
  MangaListSortType.manga_title: "manga_title",
  MangaListSortType.list_score: "list_score",
  MangaListSortType.list_updated_at: "list_updated_at",
};

Map<MangaListSortType, String> mangaListSortTypMapText = {
  MangaListSortType.manga_start_date: "Start Date",
  MangaListSortType.manga_title: "Manga Title",
  MangaListSortType.list_score: "List Score",
  MangaListSortType.list_updated_at: "List Updated At",
};

Map<String, String> mangaListSortMap = {
  "manga_title": "Title",
  "list_score": "List Score",
  "manga_start_date": "Start Date",
  "list_updated_at": "Updated At",
};

Map<String, SortOrder> mangaListDefaultOrderMap = {
  "manga_title": SortOrder.Ascending,
  "list_score": SortOrder.Descending,
  "manga_start_date": SortOrder.Descending,
  "list_updated_at": SortOrder.Descending,
};

List<String> contentTypes = ["anime", "manga"];
List<String> searchTypes = [
  "all",
  "anime",
  "manga",
  "forum",
  "character",
  "person",
  "user",
  "featured",
  "news",
  "club",
  "interest_stack"
];

/// <option selected="selected" value="0">Select</option>
/// <option value="10">(10) Masterpiece</option>
/// <option value="9">(9) Great</option>
/// <option value="8">(8) Very Good</option>
/// <option value="7">(7) Good</option>
/// <option value="6">(6) Fine</option>
/// <option value="5">(5) Average</option>
/// <option value="4">(4) Bad</option>
/// <option value="3">(3) Very Bad</option>
/// <option value="2">(2) Horrible</option>
/// <option value="1">(1) Appalling</option>
Map<int, String> myStarMap = {
  0: S.current.SelectARating,
  1: S.current.Appalling,
  2: S.current.Horrible,
  3: S.current.Very_Bad,
  4: S.current.Bad,
  5: S.current.Average,
  6: S.current.Fine,
  7: S.current.Good,
  8: S.current.Very_Good,
  9: S.current.Great,
  10: S.current.Masterpiece,
};

class Mal {
  static Map<String, List<String>> get genreTypeMap =>
      anime_gen.animeGenreTypeMap;
  static final reverseGenreMap = Map.fromEntries(genreTypeMap.entries
      .expand((e) => e.value.map((k) => MapEntry(k, e.key))));
  static String getGenreCategory(String genre) {
    return reverseGenreMap[genre] ?? S.current.Genres;
  }

  static Map<int, String> animeGenresEng = anime_gen.animeGenresEng;

  static Map<int, String> get animeGenres => anime_gen.animeGenres;

  static Map<int, String> get mangaGenres => manga_gen.mangaGenres;

  static Map<int, String> mangaGenresEng = manga_gen.mangaGenresEng;

  static Map<int, String> animeStudios = producers_gen.animeStudios;

  static Map<int, String> mangaMagazines = magazines_gen.mangaMagazines;
}

class ForumConstants {
  static Map<int, String> boards = {
    1: S.current.Anime_Discussion,
    2: S.current.Manga_Discussion,
    3: S.current.Support,
    4: S.current.Suggestions,
    5: S.current.Updates_Announcements,
    6: S.current.Current_Events,
    7: S.current.Games_Computers_Tech_Support,
    8: S.current.Introductions,
    9: S.current.Forum_Games,
    10: S.current.Music_Entertainment,
    11: S.current.Casual_Discussion,
    12: S.current.Creative_Corner,
    13: S.current.MAL_Contests,
    14: S.current.MAL_Guidelines_FAQ,
    15: S.current.News_Discussion,
    16: S.current.Anime_Manga_Recommendations,
    17: S.current.DB_Modification_Requests,
    19: S.current.Series_Discussion
  };

  static Map<int, String> subBoards = {
    1: S.current.Anime_Series,
    2: S.current.Anime_DB,
    3: S.current.Character_People_DB,
    4: S.current.Manga_Series,
    5: S.current.Manga_DB
  };

  static Map<String, String> tags = {
    "All": S.current.All,
    "Interview": S.current.Interview,
    "Live Action": S.current.Live_Action,
    "Recap": S.current.Recap,
    "Recommendation": S.current.Recommendation,
    "Collection": S.current.Collection,
    "Analysis": S.current.Analysis,
    "Location": S.current.Location,
    "Japanese Life": S.current.Japanese_Life,
    "Anime Terms": S.current.Anime_Terms,
    "Quotes": S.current.Quotes,
    "Anime Archetypes": S.current.Anime_Archetypes,
    "Studios": S.current.Studios,
    "Action": S.current.Action,
    "Animals": S.current.Animals,
    "Arch Enemies": S.current.Arch_Enemies,
    "Background Analysis": S.current.Background_Analysis,
    "Brother complex": S.current.Brother_complex,
    "Character Analysis": S.current.Character_Analysis,
    "Cold hearted": S.current.Cold_hearted,
    "Cute Girls": S.current.Cute_Girls,
    "Cute Guys": S.current.Cute_Guys,
    "Despair": S.current.Despair,
    "Director": S.current.Director,
    "Fan Made": S.current.Fan_Made,
    "Fashion": S.current.Fashion,
    "Figures": S.current.Figures,
    "First Impression": S.current.First_Impression,
    "Friendship": S.current.Friendship,
    "Funny": S.current.Funny,
    "Games": S.current.Games,
    "Heart-warming": S.current.Heart_warming,
    "History and Culture": S.current.History_and_Culture,
    "Honor": S.current.Honor,
    "Horror": S.current.Horror,
    "Kawaii": S.current.Kawaii,
    "Love": S.current.Love,
    "Magical": S.current.Magical,
    "Mangaka": S.current.Mangaka,
    "Moe": S.current.Moe,
    "Monsters": S.current.Monsters,
    "Music": S.current.Music,
    "Plot twist": S.current.Plot_twist,
    "Review": S.current.Review,
    "Seiyuu": S.current.Seiyuu,
    "Sister Complex": S.current.Sister_Complex,
    "School Life": S.current.School_Life,
    "Attack on Titan": S.current.Attack_on_Titan,
    "Weapons": S.current.Weapons,
    "Sports": S.current.Sports,
    "Hot": S.current.Hot,
    "Food": S.current.Food,
    "Family": S.current.Family,
    "Supernatural": S.current.Supernatural,
    "Superhuman": S.current.Superhuman,
    "Game Adaptation": S.current.Game_Adaptation,
    "Sci-fi": S.current.Sci_fi,
    "GIF": S.current.GIF,
    "Art": S.current.Art,
    "One Piece": S.current.One_Piece,
    "Naruto": S.current.Naruto,
    "Dragon Ball": S.current.Dragon_Ball,
    "Bleach": S.current.Bleach,
    "Fairy Tail": S.current.Fairy_Tail,
    "Ghibli": S.current.Ghibli,
    "SAO": S.current.SAO,
    "Sailor Moon": S.current.Sailor_Moon,
    "Tokyo Ghoul": S.current.Tokyo_Ghoul,
    "Hunter x Hunter": S.current.Hunter_x_Hunter,
    "Death Note": S.current.Death_Note,
    "Video": S.current.Video,
    "Trivia": S.current.Trivia,
    "One Punch Man": S.current.One_Punch_Man,
    "Meme": S.current.Meme,
    "Events": S.current.Events,
    "Technology": S.current.Technology,
    "Editorial": S.current.Editorial,
    "Cosplay": S.current.Cosplay,
    "Crowdfunding": S.current.Crowdfunding
  };

  static Map<String, Map<String, String>> newsTags = {
    S.current.Include: {"All": S.current.All},
    "anime": {
      "New Anime": S.current.New_Anime,
      "Spring 2015": S.current.Spring_2015,
      "Summer 2015": S.current.Summer_2015,
      "Fall 2015": S.current.Fall_2015,
      "Winter 2016": S.current.Winter_2016,
      "Spring 2016": S.current.Spring_2016,
      "Preview": S.current.Preview,
      "Broadcast": S.current.Broadcast,
      "English Dub": S.current.English_Dub,
      "BD DVD": S.current.BD_DVD,
      "More Info": S.current.More_Info,
      "Summer 2016": S.current.Summer_2016,
      "Fall 2016": S.current.Fall_2016,
      "Winter 2017": S.current.Winter_2017,
      "Spring 2017": S.current.Spring_2017,
      "Summer 2017": S.current.Summer_2017,
      "Fall 2017": S.current.Fall_2017,
      "Spring 2007": S.current.Spring_2007,
      "Summer 2007": S.current.Summer_2007,
      "Fall 2007": S.current.Fall_2007,
      "Winter 2008": S.current.Winter_2008,
      "Spring 2008": S.current.Spring_2008,
      "Summer 2008": S.current.Summer_2008,
      "Fall 2008": S.current.Fall_2008,
      "Winter 2009": S.current.Winter_2009,
      "Spring 2009": S.current.Spring_2009,
      "Summer 2009": S.current.Summer_2009,
      "Fall 2009": S.current.Fall_2009,
      "Winter 2010": S.current.Winter_2010,
      "Spring 2010": S.current.Spring_2010,
      "Summer 2010": S.current.Summer_2010,
      "Fall 2010": S.current.Fall_2010,
      "Winter 2011": S.current.Winter_2011,
      "Spring 2011": S.current.Spring_2011,
      "Summer 2011": S.current.Summer_2011,
      "Fall 2011": S.current.Fall_2011,
      "Winter 2012": S.current.Winter_2012,
      "Spring 2012": S.current.Spring_2012,
      "Summer 2012": S.current.Summer_2012,
      "Fall 2012": S.current.Fall_2012,
      "Winter 2013": S.current.Winter_2013,
      "Spring 2013": S.current.Spring_2013,
      "Summer 2013": S.current.Summer_2013,
      "Fall 2013": S.current.Fall_2013,
      "Winter 2014": S.current.Winter_2014,
      "Spring 2014": S.current.Spring_2014,
      "Summer 2014": S.current.Summer_2014,
      "Fall 2014": S.current.Fall_2014,
      "Winter 2015": S.current.Winter_2015,
      "Winter 2018": S.current.Winter_2018,
      "Spring 2018": S.current.Spring_2018,
      "Summer 2018": S.current.Summer_2018,
      "Fall 2018": S.current.Fall_2018,
      "Winter 2019": S.current.Winter_2019,
      "Spring 2019": S.current.Spring_2019,
      "Summer 2019": S.current.Summer_2019,
      "Fall 2019": S.current.Fall_2019,
      "Winter 2020": S.current.Winter_2020,
      "Spring 2020": S.current.Spring_2020,
      "Fall 2020": S.current.Fall_2020,
      "Summer 2020": S.current.Summer_2020,
      "Screening": S.current.Screening,
      "Winter 2021": S.current.Winter_2021,
      "Spring 2021": S.current.Spring_2021,
      "Summer 2021": S.current.Summer_2021,
      "Fall 2021": S.current.Fall_2021,
      "Winter 2022": S.current.Winter_2022,
      "Spring 2022": S.current.Spring_2022,
      "Summer 2022": S.current.Summer_2022,
      "Fall 2022": S.current.Fall_2022
    },
    "manga": {
      "Adapts Manga": S.current.Adapts_Manga,
      "Light Novels": S.current.Light_Novels,
      "New Manga": S.current.New_Manga,
      "Series End": S.current.Series_End,
      "Hiatus": S.current.Hiatus,
      "Special Chapter": S.current.Special_Chapter
    },
    "people": {
      "Seiyuu": S.current.Seiyuu,
      "Mangaka": S.current.Mangaka,
      "Life Event": S.current.Life_Event,
      "Staff": S.current.Staff,
      "Interview": S.current.Interview,
    },
    "music": {
      "Musician": S.current.Musician,
      "New CD": S.current.New_CD,
      "OP ED": S.current.OP_ED,
    },
    "events": {
      "Anime Expo": S.current.Anime_Expo,
      "Exhibition": S.current.Exhibition,
      "Interest": S.current.Interest,
      "Manga Awards": S.current.Manga_Awards,
      "Live": S.current.Live,
      "Anime Awards": S.current.Anime_Awards,
      "People Awards": S.current.People_Awards,
      "Otakon": S.current.Otakon,
      "Anime Festival Asia": S.current.Anime_Festival_Asia,
      "Comiket": S.current.Comiket,
      "Wonder Festival": S.current.Wonder_Festival,
      "Japan Expo": S.current.Japan_Expo,
      "AnimeJapan": S.current.AnimeJapan,
      "Machi Asobi": S.current.Machi_Asobi,
      "Anime NYC": S.current.Anime_NYC,
      "Sakura-con": S.current.Sakura_con,
      "Anime Central": S.current.Anime_Central,
      "SMASH": S.current.SMASH,
      "NYCC": S.current.NYCC,
      "Jump Festa": S.current.Jump_Festa,
    },
    "industry": {
      "Anime Sales": S.current.Anime_Sales,
      "Licenses": S.current.Licenses,
      "Manga Sales": S.current.Manga_Sales,
      "Music Sales": S.current.Music_Sales,
      "Light Novel Sales": S.current.Light_Novel_Sales,
      "First Volume Sales": S.current.First_Volume_Sales,
      "Live Action": S.current.Live_Action,
      "Magazines": S.current.Magazines,
      "Companies": S.current.Companies,
      "KonoSugoi": S.current.KonoSugoi,
      "Yearly Rankings": S.current.Yearly_Rankings,
      "Crowdfunding": S.current.Crowdfunding,
      "Editorial": S.current.Editorial,
    }
  };
}
