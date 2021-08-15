import 'package:flutter/material.dart';
import 'package:video_viewer/ui/widgets/helpers.dart';
import 'package:video_viewer/data/repositories/video.dart';

class SecondaryMenu extends StatelessWidget {
  const SecondaryMenu({
    Key? key,
    required this.children,
    this.width = 150,
  }) : super(key: key);

  final List<Widget> children;
  final double width;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final metadata = query.videoMetadata(context, listen: true);
    final style = metadata.style.settingsStyle;

    return Center(
      child: Container(
        width: width,
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInkWell(
                onTap: query.video(context).closeAllSecondarySettingsMenus,
                child: Row(children: [
                  style.chevron,
                  Expanded(
                    child: Text(
                      metadata.language.settings,
                      style: metadata.style.textStyle,
                    ),
                  ),
                ]),
              ),
              for (int i = 0; i < children.length; i++) ...[
                children[i],
              ]
            ],
          ),
        ),
      ),
    );
  }
}
