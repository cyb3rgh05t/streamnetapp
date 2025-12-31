class LiveStream {
  final int streamId;
  final int num;
  final String name;
  final String? streamIcon;
  final String? epgChannelId;
  final int? isAdult;
  final String categoryId;
  final String? tvArchive;
  final int? tvArchiveDuration;
  final String? customSid;
  final String? directSource;

  LiveStream({
    required this.streamId,
    required this.num,
    required this.name,
    this.streamIcon,
    this.epgChannelId,
    this.isAdult,
    required this.categoryId,
    this.tvArchive,
    this.tvArchiveDuration,
    this.customSid,
    this.directSource,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      streamId: int.tryParse(json['stream_id']?.toString() ?? '0') ?? 0,
      num: int.tryParse(json['num']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      streamIcon: json['stream_icon'],
      epgChannelId: json['epg_channel_id'],
      isAdult: int.tryParse(json['is_adult']?.toString() ?? '0'),
      categoryId: json['category_id']?.toString() ?? '',
      tvArchive: json['tv_archive']?.toString(),
      tvArchiveDuration: int.tryParse(
        json['tv_archive_duration']?.toString() ?? '0',
      ),
      customSid: json['custom_sid'],
      directSource: json['direct_source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stream_id': streamId,
      'num': num,
      'name': name,
      'stream_icon': streamIcon,
      'epg_channel_id': epgChannelId,
      'is_adult': isAdult,
      'category_id': categoryId,
      'tv_archive': tvArchive,
      'tv_archive_duration': tvArchiveDuration,
      'custom_sid': customSid,
      'direct_source': directSource,
    };
  }
}
