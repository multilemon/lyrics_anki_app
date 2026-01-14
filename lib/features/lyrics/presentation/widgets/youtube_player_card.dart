import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubePlayerCard extends StatefulWidget {
  const YouTubePlayerCard({required this.videoId, super.key});

  final String videoId;

  @override
  State<YouTubePlayerCard> createState() => _YouTubePlayerCardState();
}

class _YouTubePlayerCardState extends State<YouTubePlayerCard> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
      ),
    );

    // Debugging: Log player errors
    // Note: The iframe api doesn't always expose detailed error codes directly
    // through the stream in this package version, but we can try to listen to state changes
    // or known error events if available.
    // However, for now, we'll assume visual feedback is primary, but we can log
    // if the state goes to 'unknown' or similar unexpected states immediately.
    // (A more robust implementation might use the underlying web events).
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(
              controller: _controller,
            ),
          ),
          Container(
            color: Colors.black, // Match player background
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: TextButton.icon(
              onPressed: () {
                // Open YouTube link
                final url = 'https://www.youtube.com/watch?v=${widget.videoId}';
                html.window.open(url, '_blank');
              },
              icon: const Icon(Icons.open_in_new,
                  size: 16, color: Colors.white70),
              label: const Text(
                'Watch on YouTube',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
