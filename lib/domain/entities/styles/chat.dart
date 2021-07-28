import 'package:flutter/material.dart';

class VideoViewerChatStyle {
  const VideoViewerChatStyle({
    Widget? chatIcon,
    this.chat = const SizedBox(),
  }) : chatIcon = chatIcon ??
            const Icon(Icons.chat_outlined, color: Colors.white, size: 20);

  final Widget chatIcon;

  final Widget chat;
}
