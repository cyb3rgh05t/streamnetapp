class SeriesStream {
  final int seriesId;
  final int num;
  final String name;
  final String? cover;
  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final String? releaseDate;
  final String? lastModified;
  final double? rating;
  final double? rating5based;
  final List<String>? backdropPath;
  final String? youtubeTrailer;
  final String? episodeRunTime;
  final String categoryId;

  SeriesStream({
    required this.seriesId,
    required this.num,
    required this.name,
    this.cover,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.releaseDate,
    this.lastModified,
    this.rating,
    this.rating5based,
    this.backdropPath,
    this.youtubeTrailer,
    this.episodeRunTime,
    required this.categoryId,
  });

  factory SeriesStream.fromJson(Map<String, dynamic> json) {
    return SeriesStream(
      seriesId: int.tryParse(json['series_id']?.toString() ?? '0') ?? 0,
      num: int.tryParse(json['num']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      cover: json['cover'],
      plot: json['plot'],
      cast: json['cast'],
      director: json['director'],
      genre: json['genre'],
      releaseDate: json['releaseDate'] ?? json['release_date'],
      lastModified: json['last_modified']?.toString(),
      rating: double.tryParse(json['rating']?.toString() ?? '0'),
      rating5based: double.tryParse(json['rating_5based']?.toString() ?? '0'),
      backdropPath: json['backdrop_path'] != null
          ? List<String>.from(json['backdrop_path'])
          : null,
      youtubeTrailer: json['youtube_trailer'],
      episodeRunTime: json['episode_run_time']?.toString(),
      categoryId: json['category_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'series_id': seriesId,
      'num': num,
      'name': name,
      'cover': cover,
      'plot': plot,
      'cast': cast,
      'director': director,
      'genre': genre,
      'releaseDate': releaseDate,
      'last_modified': lastModified,
      'rating': rating,
      'rating_5based': rating5based,
      'backdrop_path': backdropPath,
      'youtube_trailer': youtubeTrailer,
      'episode_run_time': episodeRunTime,
      'category_id': categoryId,
    };
  }
}

class Season {
  final int seasonNumber;
  final String name;
  final int episodeCount;
  final String? cover;
  final String? coverBig;

  Season({
    required this.seasonNumber,
    required this.name,
    this.episodeCount = 0,
    this.cover,
    this.coverBig,
  });

  factory Season.fromJson(Map<String, dynamic> json, int seasonNum) {
    return Season(
      seasonNumber: seasonNum,
      name: json['name'] ?? 'Season $seasonNum',
      episodeCount: json['episode_count'] ?? 0,
      cover: json['cover'],
      coverBig: json['cover_big'],
    );
  }
}

class Episode {
  final int id;
  final int episodeNum;
  final String title;
  final String? containerExtension;
  final String? info;
  final String? customSid;
  final String? added;
  final int? season;
  final String? directSource;

  Episode({
    required this.id,
    required this.episodeNum,
    required this.title,
    this.containerExtension,
    this.info,
    this.customSid,
    this.added,
    this.season,
    this.directSource,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      episodeNum: int.tryParse(json['episode_num']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      containerExtension: json['container_extension'],
      info: json['info']?.toString(),
      customSid: json['custom_sid'],
      added: json['added']?.toString(),
      season: int.tryParse(json['season']?.toString() ?? '0'),
      directSource: json['direct_source'],
    );
  }
}
