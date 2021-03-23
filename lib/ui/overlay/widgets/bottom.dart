import 'dart:typed_data';

import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/bloc/controller.dart';

import 'package:video_viewer/ui/overlay/widgets/progress_bar.dart';
import 'package:video_viewer/ui/overlay/widgets/background.dart';
import 'package:video_viewer/ui/video_core/widgets/aspect_ratio.dart';
import 'package:video_viewer/ui/widgets/play_and_pause.dart';
import 'package:video_viewer/ui/widgets/helpers.dart';

class OverlayBottom extends StatefulWidget {
  OverlayBottom({Key? key}) : super(key: key);

  @override
  _OverlayBottomState createState() => _OverlayBottomState();
}

class _OverlayBottomState extends State<OverlayBottom> {
  ValueNotifier<Uint8List?> _image = ValueNotifier<Uint8List?>(null);
  late VideoViewerController _controller;
  final VideoQuery _query = VideoQuery();

  bool _showRemaingText = false;

  @override
  void initState() {
    super.initState();
    Misc.onLayoutRendered(() {
      _controller = _query.video(context);
      _controller.video!.addListener(_thumbnailListener);
    });
  }

  @override
  void dispose() {
    _controller.video!.removeListener(_thumbnailListener);
    super.dispose();
  }

  void _thumbnailListener() async {
    if (_controller.isDraggingProgressBar) {
      _image.value = await VideoThumbnail.thumbnailData(
        video:
            "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
        imageFormat: ImageFormat.WEBP,
        maxHeight: 64,
        quality: 75,
        timeMs: _controller.video!.value.position.inMilliseconds,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _query.videoStyle(context);
    final video = _query.video(context, listen: true);

    final isFullscreen = video.isFullScreen;
    final controller = video.video!;
    final barStyle = style.progressBarStyle;
    final padding = barStyle.paddingBeetwen;

    final halfPadding = Margin.all(padding / 2);

    final value = controller.value;
    final position = value.position;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientBackground(
          child: Row(children: [
            PlayAndPause(
              type: PlayAndPauseType.bottom,
              padding: Margin.all(padding),
            ),
            ValueListenableBuilder(
              valueListenable: _image,
              builder: (_, Uint8List? bytes, __) => VideoCoreAspectRadio(
                child: bytes != null ? Image.memory(bytes) : SizedBox(),
              ),
            ),
            Expanded(child: VideoProgressBar()),
            SizedBox(width: padding),
            SplashCircularIcon(
              padding: halfPadding,
              onTap: () {
                setState(() => _showRemaingText = !_showRemaingText);
                video.cancelCloseOverlay();
              },
              child: AutoSizeText(
                _showRemaingText
                    ? _query.durationFormatter(position)
                    : _query.durationFormatter(position - value.duration),
                style: style.textStyle,
              ),
            ),
            SplashCircularIcon(
              padding: halfPadding,
              onTap: video.openSettingsMenu,
              child: style.settingsStyle.settings,
            ),
            SplashCircularIcon(
              padding: halfPadding + Margin.right(padding / 2),
              onTap: () async {
                if (!isFullscreen)
                  await video.openFullScreen(context);
                else
                  await video.closeFullScreen(context);
              },
              child:
                  isFullscreen ? barStyle.fullScreenExit : barStyle.fullScreen,
            ),
          ]),
        ),
      ],
    );
  }
}
