import 'dart:convert';
import 'dart:io';

// import 'package:dal_commons/dal_commons.dart';
import 'package:dal_commons/dal_commons.dart' as commons;
import 'package:shelf/shelf.dart';

T? queryParams<T>(Request request, String key, [T? defaultValue]) {
  return commons.queryParamsUri(request.url, key, defaultValue);
}

Response okResponse(Map<String, dynamic> data) {
  return Response.ok(
    jsonEncode(data),
    headers: {
      'Content-Type': ContentType.json.mimeType,
    },
  );
}

const animeFields =
    "?fields=id,title,main_picture,alternative_titles,ending_themes,opening_themes,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status{is_rewatching,is_rereading,num_times_rewatched,num_times_reread,priority,rewatch_value,reread_value,start_date,finish_date,tags,comments},num_episodes,start_season,broadcast,source,average_episode_duration,rating,pictures,background,related_anime{mean,num_list_users},related_manga,recommendations{mean,num_list_users},studios,statistics";

const mangaFields =
    "?fields=id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status{is_rewatching,is_rereading,num_times_rewatched,num_times_reread,priority,rewatch_value,reread_value,start_date,finish_date,tags,comments},num_volumes,num_chapters,authors{first_name,last_name},pictures,background,related_anime,related_manga{mean,num_list_users},recommendations{mean,num_list_users},serialization{name}";
