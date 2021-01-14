import 'dart:convert' show utf8;
import 'package:http/http.dart' as http;

class SubtitleData {
  final Duration start;
  final Duration end;
  final String text;

  SubtitleData({this.start, this.end, this.text});
}

enum SubtitleType { webvtt, srt }

class VideoViewerSubtitle {
  final SubtitleType type;
  String content;
  String _url;

  Stream<List<SubtitleData>> _subtitleStream;

  VideoViewerSubtitle.network(
    String url, {
    this.type = SubtitleType.webvtt,
  }) : this._url = url;

  Future<void> initialized() async {
    final http.Response response = await http.get(_url);
    if (response.statusCode == 200) {
      content = utf8.decode(
        response.bodyBytes,
        allowMalformed: true,
      );
      _subtitleStream = _getSubtitlesData();
    }
  }

  Stream<List<SubtitleData>> get subtitles => _subtitleStream;

  Stream<List<SubtitleData>> _getSubtitlesData() async* {
    RegExp regExp;

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
    List<SubtitleData> subtitleList = [];

    for (int i = 0; i < matches.length; i++) {
      final RegExpMatch regExpMatch = matches[i];

      final Duration start = Duration(
        hours: int.parse(regExpMatch.group(2)),
        minutes: int.parse(regExpMatch.group(3)),
        seconds: int.parse(regExpMatch.group(4)),
        milliseconds: int.parse(regExpMatch.group(5)),
      );

      final Duration end = Duration(
        hours: int.parse(regExpMatch.group(7)),
        minutes: int.parse(regExpMatch.group(8)),
        seconds: int.parse(regExpMatch.group(9)),
        milliseconds: int.parse(regExpMatch.group(10)),
      );

      final String text = _removeAllHtmlTags(regExpMatch.group(11));

      subtitleList.add(SubtitleData(
        start: start,
        end: end,
        text: text.trim(),
      ));

      yield subtitleList;
    }
  }

  String _removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r'(<[^>]*>)', multiLine: true, caseSensitive: true);
    String newHtmlText = htmlText;

    exp.allMatches(htmlText).toList().forEach((RegExpMatch regExpMathc) {
      if (regExpMathc.group(0) == '<br>') {
        newHtmlText = newHtmlText.replaceAll(regExpMathc.group(0), '\n');
      } else {
        newHtmlText = newHtmlText.replaceAll(regExpMathc.group(0), '');
      }
    });
    return newHtmlText;
  }
}
