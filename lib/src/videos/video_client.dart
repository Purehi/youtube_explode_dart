import '../common/common.dart';
import '../reverse_engineering/responses/responses.dart';
import '../reverse_engineering/youtube_http_client.dart';
import 'closed_captions/closed_caption_client.dart';
import 'videos.dart';

/// Queries related to YouTube videos.
class VideoClient {
  final YoutubeHttpClient _httpClient;

  /// Queries related to media streams of YouTube videos.
  final StreamsClient streamsClient;

  /// Queries related to closed captions of YouTube videos.
  final ClosedCaptionClient closedCaptions;

  /// Initializes an instance of [VideoClient].
  VideoClient(this._httpClient)
      : streamsClient = StreamsClient(_httpClient),
        closedCaptions = ClosedCaptionClient(_httpClient);

  /// Gets the metadata associated with the specified video.
  Future<Video> get(VideoId id) async {
    var videoInfoResponse = await VideoInfoResponse.get(_httpClient, id.value);
    var playerResponse = videoInfoResponse.playerResponse;

    var watchPage = await WatchPage.get(_httpClient, id.value);
    return Video(
        id,
        playerResponse.videoTitle,
        playerResponse.videoAuthor,
        playerResponse.videoUploadDate,
        playerResponse.videoDescription,
        playerResponse.videoDuration,
        ThumbnailSet(id.value),
        playerResponse.videoKeywords,
        Engagement(playerResponse.videoViewCount ?? 0, watchPage.videoLikeCount,
            watchPage.videoDislikeCount));
  }
}
