class Servers {
  bool? bmacLink;
  String? discordLink;
  String? strategy;
  int? maxLoad;
  bool? errorLogging;
  bool? includeSilent;
  List<PreferredServers>? preferredServers;
  String? dalAPIUrl;

  Servers({
    this.bmacLink,
    this.strategy,
    this.preferredServers,
    this.discordLink,
    this.includeSilent,
    this.dalAPIUrl,
  });

  Servers.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    bmacLink = json['bmacLink'];
    strategy = json['strategy'];
    maxLoad = json['maxLoad'];
    discordLink = json['discordLink'];
    errorLogging = json['errorLogging'];
    includeSilent = json['includeSilent'];
    dalAPIUrl = json['dalAPIUrl'];
    if (json['preferredServers'] != null) {
      preferredServers = [];
      json['preferredServers'].forEach((v) {
        preferredServers?.add(PreferredServers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bmacLink'] = bmacLink;
    data['strategy'] = strategy;
    data['maxLoad'] = maxLoad;
    data['discordLink'] = discordLink;
    data['preferredServers'] =
        preferredServers?.map((v) => v.toJson()).toList();
    data['errorLogging'] = errorLogging;
    data['includeSilent'] = includeSilent;
    data['dalAPIUrl'] = dalAPIUrl;
    return data;
  }
}

class PreferredServers {
  String? url;
  int? load;

  PreferredServers({this.url, this.load});

  PreferredServers.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    url = json['url'];
    load = json['load'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['load'] = load;
    return data;
  }
}
