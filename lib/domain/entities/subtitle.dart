import 'dart:convert';
import 'package:http/http.dart' as http;

enum SubtitleType { webvtt, srt }
enum _SubtitleIntializeType { network, string }

class SubtitleData {
  SubtitleData({
    this.start = Duration.zero,
    this.end = Duration.zero,
    this.text = "",
  });

  final Duration start;
  final Duration end;
  final String text;
}

class VideoViewerSubtitle {
  _SubtitleIntializeType _intializedType;
  final SubtitleType type;
  late String content;
  late String _url;

  List<SubtitleData> _subtitles = [];

  VideoViewerSubtitle.network(
    String url, {
    this.type = SubtitleType.webvtt,
  })  : this._url = url,
        this._intializedType = _SubtitleIntializeType.network;

  VideoViewerSubtitle.content(
    String content, {
    this.type = SubtitleType.webvtt,
  })  : this.content = content,
        this._intializedType = _SubtitleIntializeType.string;

  Future<void> initialize() async {
    switch (_intializedType) {
      case _SubtitleIntializeType.network:
        final response = await http.get(Uri.parse(_url));
        if (response.statusCode == 200) {
          content = utf8.decode(response.bodyBytes);
          _getSubtitlesData();
        }
        break;
      case _SubtitleIntializeType.string:
        _getSubtitlesData();
        break;
    }
  }

  List<SubtitleData> get subtitles => _subtitles;

  void _getSubtitlesData() {
    late RegExp regExp;

    switch (type) {
      case SubtitleType.webvtt:
        regExp = RegExp(
          r'((\d{2}):(\d{2}):(\d{2})\.(\d+)) +--> +((\d{2}):(\d{2}):(\d{2})\.(\d{3})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*(\r\n|\r|\n)(?:.*))',
          caseSensitive: false,
          multiLine: true,
        );
        break;
      case SubtitleType.srt:
        regExp = RegExp(
          r'((\d{2}):(\d{2}):(\d{2})\,(\d+)) +--> +((\d{2}):(\d{2}):(\d{2})\,(\d{3})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*(\r\n|\r|\n)(?:.*))',
          caseSensitive: false,
          multiLine: true,
        );
        break;
    }

    List<RegExpMatch> matches = regExp.allMatches(content).toList();

    matches.forEach((regExpMatch) {
      final Duration start = Duration(
        hours: int.parse(regExpMatch.group(2)!),
        minutes: int.parse(regExpMatch.group(3)!),
        seconds: int.parse(regExpMatch.group(4)!),
        milliseconds: int.parse(regExpMatch.group(5)!),
      );

      final Duration end = Duration(
        hours: int.parse(regExpMatch.group(7)!),
        minutes: int.parse(regExpMatch.group(8)!),
        seconds: int.parse(regExpMatch.group(9)!),
        milliseconds: int.parse(regExpMatch.group(10)!),
      );

      final String text = _removeAllHtmlTags(regExpMatch.group(11)!);

      subtitles.add(SubtitleData(
        start: start,
        end: end,
        text: text.trim(),
      ));
    });
  }

  String _removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r'(<[^>]*>)', multiLine: true, caseSensitive: true);
    String newHtmlText = htmlText;

    exp.allMatches(htmlText).toList().forEach((RegExpMatch regExpMathc) {
      if (regExpMathc.group(0) == '<br>') {
        newHtmlText = newHtmlText.replaceAll(regExpMathc.group(0)!, '\n');
      } else {
        newHtmlText = newHtmlText.replaceAll(regExpMathc.group(0)!, '');
      }
    });
    return newHtmlText;
  }
}
