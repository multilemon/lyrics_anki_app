import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class NativeVideoPlayer extends StatefulWidget {
  const NativeVideoPlayer({required this.videoId, super.key});

  final String videoId;

  @override
  State<NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<NativeVideoPlayer> {
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId =
        'youtube-player-${widget.videoId}-${DateTime.now().millisecondsSinceEpoch}';

    // Register the view factory
    // Use the platform view registry directly from dart:ui_web
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'https://www.youtube.com/embed/${widget.videoId}'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'autoplay; encrypted-media; picture-in-picture'
        ..allowFullscreen = true;
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        clipBehavior: Clip.antiAlias,
        child: HtmlElementView(viewType: _viewId),
      ),
    );
  }
}
