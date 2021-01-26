import 'package:helpers/helpers.dart';
import 'package:flutter/cupertino.dart';

import 'package:video_viewer/data/repositories/provider.dart';
import 'package:video_viewer/widgets/overlay/widgets/play_and_pause.dart';
import 'package:video_viewer/widgets/overlay/widgets/background.dart';
import 'package:video_viewer/widgets/overlay/bottom.dart';
import 'package:video_viewer/widgets/settings_menu.dart';
import 'package:video_viewer/widgets/helpers.dart';

class VideoOverlay extends StatelessWidget {
  const VideoOverlay({
    Key key,
    @required this.visible,
    @required this.onTapPlayAndPause,
    @required this.cancelOverlayTimer,
    @required this.videoListener,
  }) : super(key: key);

  final bool visible;
  final void Function() videoListener;
  final void Function() onTapPlayAndPause;
  final void Function() cancelOverlayTimer;

  @override
  Widget build(BuildContext context) {
    final query = ProviderQuery();
    final style = query.getVideoStyle(context);
    final header = style.header;
    final setting = ValueNotifier<bool>(false);
    final controller = query.getVideoController(context);

    return Stack(children: [
      if (header != null)
        CustomSwipeTransition(
          direction: SwipeDirection.fromTop,
          visible: visible,
          child: Align(
            alignment: Alignment.topLeft,
            child: GradientBackground(
              child: header,
              direction: Direction.top,
            ),
          ),
        ),
      CustomSwipeTransition(
        direction: SwipeDirection.fromBottom,
        visible: visible,
        child: ValueListenableBuilder(
          valueListenable: setting,
          builder: (_, value, ___) => OverlayBottomButtons(
            onPlayAndPause: onTapPlayAndPause,
            onShowSettings: () => setting.value = !value,
            onCancelOverlayTimer: cancelOverlayTimer,
          ),
        ),
      ),
      AnimatedBuilder(
        animation: controller,
        builder: (_, __) => CustomOpacityTransition(
          visible: visible && !controller.value.isPlaying,
          child: Center(child: PlayAndPause(onTap: onTapPlayAndPause)),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: setting,
        builder: (_, value, ___) => CustomOpacityTransition(
          visible: value,
          child: SettingsMenu(
            videoListener: videoListener,
            onChangeVisible: () => setting.value = !value,
          ),
        ),
      ),
    ]);
  }
}
