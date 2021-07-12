import 'package:flutter/material.dart';
import 'package:helpers/helpers/size.dart';
import 'package:helpers/helpers/widgets/widgets.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoCoreAdViewer extends StatelessWidget {
  const VideoCoreAdViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final style = query.videoStyle(context);
    final video = query.video(context, listen: true);

    return CustomOpacityTransition(
      visible: video.activeAd != null,
      child: Stack(
        children: [
          video.activeAd?.child ?? SizedBox(),
          if (video.activeAd != null)
            Align(
              alignment: style.skipAdAlignment,
              child: SplashTap(
                onTap: (video.adTimeWatched ?? Duration.zero) >=
                        video.activeAd!.durationToSkip
                    ? video.skipAd
                    : null,
                child: Builder(builder: (_) {
                  final int remaing = (video.activeAd!.durationToSkip -
                          (video.adTimeWatched ?? Duration.zero))
                      .inSeconds;
                  return style.skipAdBuilder?.call(video.adTimeWatched!) ??
                      Container(
                        padding: const Margin.all(20),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            remaing > 0
                                ? "$remaing seconds remaing"
                                : "Skip ad",
                            style: style.textStyle,
                          ),
                          if (remaing <= 0)
                            Icon(Icons.skip_next, color: Colors.white)
                        ]),
                      );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
