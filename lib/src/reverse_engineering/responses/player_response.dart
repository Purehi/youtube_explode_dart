import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:youtube_explode_dart/src/reverse_engineering/responses/stream_info_provider.dart';

class PlayerResponse {
  // Json parsed map
  final Map<String, dynamic> _root;

  PlayerResponse(this._root);

  String get playabilityStatus => _root['playabilityStatus']['status'];

  bool get isVideoAvailable => playabilityStatus != 'error';

  bool get isVideoPlayable => playabilityStatus == 'ok';

  String get videoTitle => _root['videoDetails']['title'];

  String get videoAuthor => _root['videoDetails']['author'];

  //TODO: Check how this is formatted.
  DateTime get videoUploadDate => DateTime.parse(
      _root['microformat']['playerMicroformatRenderer']['uploadDate']);

  String get videoChannelId => _root['videoDetails']['channelId'];

  Duration get videoDuration =>
      Duration(seconds: int.parse(_root['videoDetails']['lengthSeconds']));

  Iterable<String> get videoKeywords =>
      _root['videoDetails']['keywords'].cast<String>() ?? const [];

  String get videoDescription => _root['videoDetails']['shortDescription'];

  int get videoViewCount => int.parse(_root['videoDetails']['viewCount']);

  // Can be null
  String get previewVideoId =>
      _root
          .get('playabilityStatus')
          ?.get('errorScreen')
          ?.get('playerLegacyDesktopYpcTrailerRenderer')
          ?.get('trailerVideoId') ??
      Uri.splitQueryString(_root
              .get('playabilityStatus')
              ?.get('errorScreen')
              ?.get('')
              ?.get('ypcTrailerRenderer')
              ?.get('playerVars') ??
          '')['video_id'];

  bool get isLive => _root['videoDetails'].get('isLive') ?? false;

  // Can be null
  String get hlsManifestUrl =>
      _root.get('streamingData')?.get('hlsManifestUrl');

  // Can be null
  String get dashManifestUrl =>
      _root.get('streamingData')?.get('dashManifestUrl');

  Iterable<StreamInfoProvider> get muxedStreams =>
      _root?.get('streamingData')?.get('formats')?.map((e) => _StreamInfo(e)) ??
      const [];

  Iterable<StreamInfoProvider> get adaptiveStreams =>
      _root
          ?.get('streamingData')
          ?.get('adaptiveFormats')
          ?.map((e) => _StreamInfo(e)) ??
      const [];

  Iterable<StreamInfoProvider> get streams =>
      [...muxedStreams, ...adaptiveStreams];

  Iterable<ClosedCaptionTrack> get closedCaptionTrack =>
      _root
          .get('captions')
          ?.get('playerCaptionsTracklistRenderer')
          ?.get('captionTracks')
          ?.map((e) => ClosedCaptionTrack(e)) ??
      const [];

  String getVideoPlayabilityError() =>
      _root.get('playabilityStatus')?.get('reason');

  PlayerResponse.parse(String raw) : _root = json.decode(raw);
}

class ClosedCaptionTrack {
  // Json parsed map
  final Map<String, dynamic> _root;

  ClosedCaptionTrack(this._root);

  String get url => _root['baseUrl'];

  String get languageCode => _root['languageCode'];

  String get languageName => _root['name']['simpleText'];

  bool get autoGenerated => _root['vssId'].toLowerCase().startsWith("a.");
}

class _StreamInfo extends StreamInfoProvider {
  // Json parsed map
  final Map<String, dynamic> _root;

  _StreamInfo(this._root);

  @override
  int get bitrate => _root['bitrate'];

  @override
  String get container => mimeType.subtype;

  @override
  int get contentLength =>
      _root['contentLength'] ??
      StreamInfoProvider.contentLenExp.firstMatch(url).group(1);

  @override
  int get framerate => int.tryParse(_root['fps'] ?? '');

  @override
  String get signature => Uri.splitQueryString(_root.get('cipher') ?? '')['s'];

  @override
  String get signatureParameter =>
      Uri.splitQueryString(_root['cipher'] ?? '')['sp'];

  @override
  int get tag => int.parse(_root['itag']);

  @override
  String get url =>
      _root?.get('url') ??
      Uri.splitQueryString(_root?.get('cipher') ?? '')['s'];

  @override
  // TODO: implement videoCodec,  gotta debug how the mimeType is formatted
  String get videoCodec => throw UnimplementedError();

  @override
  // TODO: implement videoHeight, gotta debug how the mimeType is formatted
  int get videoHeight => _root['height'];

  @override
  // TODO: implement videoQualityLabel
  String get videoQualityLabel => _root['qualityLabel'];

  @override
  // TODO: implement videoWidth
  int get videoWidth => _root['width'];

  // TODO: implement audioOnly, gotta debug how the mimeType is formatted
  bool get audioOnly => throw UnimplementedError();

  MediaType get mimeType => MediaType.parse(_root['mimeType']);

  String get codecs => mimeType?.parameters['codecs']?.toLowerCase();

  @override
  // TODO: Finish implementing this, gotta debug how the mimeType is formatted
  String get audioCodec => audioOnly ? codecs : throw UnimplementedError();
}

///
extension GetOrNull<K, V> on Map<K, V> {
  V get(K key) {
    var v = this[key];
    if (v == null) {
      return null;
    }
    return v;
  }
}
