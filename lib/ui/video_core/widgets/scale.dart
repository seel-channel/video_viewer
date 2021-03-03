import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:video_viewer/ui/video_core/widgets/aspect_ratio.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoCorePlayer extends StatefulWidget {
  VideoCorePlayer({Key key, @required this.onTap}) : super(key: key);

  final void Function([bool]) onTap;

  @override
  _VideoCorePlayerState createState() => _VideoCorePlayerState();
}

class _VideoCorePlayerState extends State<VideoCorePlayer> {
  final VideoQuery _query = VideoQuery();
  final ValueNotifier<double> _scale = ValueNotifier<double>(1.0);
  double _maxScale = 1.0, _minScale = 1.0, _initialScale = 1.0;

  void _onScaleStart(ScaleStartDetails details) {
    final size = context.media.size;
    final controller = _query.video(context).controller;
    final aspectWidth = size.height * controller.value.aspectRatio;

    _initialScale = _scale.value;
    _maxScale = size.width / aspectWidth;
    setState(() {});
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _initialScale * details.scale;
    if (newScale >= _minScale && newScale <= _maxScale) _scale.value = newScale;
  }

  @override
  Widget build(BuildContext context) {
    final video = _query.video(context, listen: true);
    return OrientationBuilder(
      builder: (_, Orientation orientation) {
        final isFullScreenLandscape =
            video.isFullScreen && orientation == Orientation.landscape;

        return Stack(children: [
          CustomOpacityTransition(
            visible: !video.isShowingThumbnail,
            child: isFullScreenLandscape
                ? ValueListenableBuilder(
                    valueListenable: _scale,
                    builder: (_, double value, __) {
                      return Transform.scale(
                        scale: value,
                        child: Center(
                          child: VideoAspectRadio(
                              child: VideoPlayer(video.controller)),
                        ),
                      );
                    },
                  )
                : VideoPlayer(video.controller),
          ),
          kIsWeb
              ? MouseRegion(
                  onHover: (_) {
                    if (!video.isShowingOverlay) widget.onTap(true);
                  },
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Container(color: Colors.transparent),
                  ),
                )
              : GestureDetector(
                  onTap: widget.onTap,
                  onScaleStart: isFullScreenLandscape ? _onScaleStart : null,
                  onScaleUpdate: isFullScreenLandscape ? _onScaleUpdate : null,
                  child: Container(color: Colors.transparent),
                ),
        ]);
      },
    );
  }
}
