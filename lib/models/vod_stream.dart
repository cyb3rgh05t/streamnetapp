class VodStream {
  final int streamId;
  final int num;
  final String name;
  final String? streamIcon;
  final double? rating;
  final double? rating5based;
  final String? added;
  final int? isAdult;
  final String categoryId;
  final String? containerExtension;
  final String? customSid;
  final String? directSource;
  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final String? releaseDate;
  final String? duration;
  final String? tmdbId;

  VodStream({
    required this.streamId,
    required this.num,
    required this.name,
    this.streamIcon,
    this.rating,
    this.rating5based,
    this.added,
    this.isAdult,
    required this.categoryId,
    this.containerExtension,
    this.customSid,
    this.directSource,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.releaseDate,
    this.duration,
    this.tmdbId,
  });

  factory VodStream.fromJson(Map<String, dynamic> json) {
    return VodStream(
      streamId: int.tryParse(json['stream_id']?.toString() ?? '0') ?? 0,
      num: int.tryParse(json['num']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      streamIcon: json['stream_icon'],
      rating: double.tryParse(json['rating']?.toString() ?? '0'),
      rating5based: double.tryParse(json['rating_5based']?.toString() ?? '0'),
      added: json['added']?.toString(),
      isAdult: int.tryParse(json['is_adult']?.toString() ?? '0'),
      categoryId: json['category_id']?.toString() ?? '',
      containerExtension: json['container_extension'],
      customSid: json['custom_sid'],
      directSource: json['direct_source'],
      plot: json['plot'],
      cast: json['cast'],
      director: json['director'],
      genre: json['genre'],
      releaseDate: json['release_date'],
      duration:
          json['episode_run_time']?.toString() ?? json['duration']?.toString(),
      tmdbId: json['tmdb_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stream_id': streamId,
      'num': num,
      'name': name,
      'stream_icon': streamIcon,
      'rating': rating,
      'rating_5based': rating5based,
      'added': added,
      'is_adult': isAdult,
      'category_id': categoryId,
      'container_extension': containerExtension,
      'custom_sid': customSid,
      'direct_source': directSource,
      'plot': plot,
      'cast': cast,
      'director': director,
      'genre': genre,
      'release_date': releaseDate,
      'duration': duration,
      'tmdb_id': tmdbId,
    };
  }
}
