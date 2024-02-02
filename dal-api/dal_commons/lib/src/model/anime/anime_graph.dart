// To parse this JSON data, do
//
//     final animeGraph = animeGraphFromJson(jsonString);

import 'dart:convert';

AnimeGraph animeGraphFromJson(String str) => AnimeGraph.fromJson(json.decode(str));

String animeGraphToJson(AnimeGraph data) => json.encode(data.toJson());

class AnimeGraph {
    final List<GraphNode>? nodes;
    final List<GraphEdge>? edges;

    AnimeGraph({
        this.nodes,
        this.edges,
    });

    factory AnimeGraph.fromJson(Map<String, dynamic> json) => AnimeGraph(
        nodes: json["nodes"] == null ? [] : List<GraphNode>.from(json["nodes"]!.map((x) => GraphNode.fromJson(x))),
        edges: json["edges"] == null ? [] : List<GraphEdge>.from(json["edges"]!.map((x) => GraphEdge.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "nodes": nodes == null ? [] : List<dynamic>.from(nodes!.map((x) => x.toJson())),
        "edges": edges == null ? [] : List<dynamic>.from(edges!.map((x) => x.toJson())),
    };
}

class GraphEdge {
    final int? source;
    final int? target;
    final GRelationType? relationType;
    final String? relationTypeFormatted;

    GraphEdge({
        this.source,
        this.target,
        this.relationType,
        this.relationTypeFormatted,
    });

    factory GraphEdge.fromJson(Map<String, dynamic> json) => GraphEdge(
        source: json["source"],
        target: json["target"],
        relationType: relationTypeValues.map[json["relation_type"]]!,
        relationTypeFormatted: json["relation_type_formatted"],
    );

    Map<String, dynamic> toJson() => {
        "source": source,
        "target": target,
        "relation_type": relationTypeValues.reverse[relationType],
        "relation_type_formatted": relationTypeFormatted,
    };
}

enum GRelationType {
    sequel,
    prequel,
    alternative_setting,
    alternative_version,
    side_story,
    parent_story,
    summary,
    full_story,
    spin_off,
    character,
    other,
}

final relationTypeValues = GEnumValues({
    "alternative_version": GRelationType.alternative_version,
    "alternative_setting": GRelationType.alternative_setting,
    "character": GRelationType.character,
    "full_story": GRelationType.full_story,
    "other": GRelationType.other,
    "parent_story": GRelationType.parent_story,
    "prequel": GRelationType.prequel,
    "sequel": GRelationType.sequel,
    "side_story": GRelationType.side_story,
    "spin_off": GRelationType.spin_off,
    "summary": GRelationType.summary
});

class GraphNode {
    final int? id;
    final String? title;
    final GMainPicture? mainPicture;
    final double? mean;
    final String? mediaType;
    final String? status;
    final GStartSeason? startSeason;

    GraphNode({
        this.id,
        this.title,
        this.mainPicture,
        this.mean,
        this.mediaType,
        this.status,
        this.startSeason,
    });

    factory GraphNode.fromJson(Map<String, dynamic> json) => GraphNode(
        id: json["id"],
        title: json["title"],
        mainPicture: json["main_picture"] == null ? null : GMainPicture.fromJson(json["main_picture"]),
        mean: json["mean"]?.toDouble(),
        mediaType: json["media_type"],
        status: json["status"],
        startSeason: json["start_season"] == null ? null : GStartSeason.fromJson(json["start_season"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "main_picture": mainPicture?.toJson(),
        "mean": mean,
        "media_type": mediaType,
        "status": status,
        "start_season": startSeason?.toJson(),
    };
}

class GMainPicture {
    final String? medium;
    final String? large;

    GMainPicture({
        this.medium,
        this.large,
    });

    factory GMainPicture.fromJson(Map<String, dynamic> json) => GMainPicture(
        medium: json["medium"],
        large: json["large"],
    );

    Map<String, dynamic> toJson() => {
        "medium": medium,
        "large": large,
    };
}

class GStartSeason {
    final int? year;
    final GSeason? season;

    GStartSeason({
        this.year,
        this.season,
    });

    factory GStartSeason.fromJson(Map<String, dynamic> json) => GStartSeason(
        year: json["year"],
        season: seasonValues.map[json["season"]]!,
    );

    Map<String, dynamic> toJson() => {
        "year": year,
        "season": seasonValues.reverse[season],
    };
}

enum GSeason {
    FALL,
    SPRING,
    SUMMER,
    WINTER
}

final seasonValues = GEnumValues({
    "fall": GSeason.FALL,
    "spring": GSeason.SPRING,
    "summer": GSeason.SUMMER,
    "winter": GSeason.WINTER
});

class GEnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    GEnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}
