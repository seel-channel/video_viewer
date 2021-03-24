import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:video_viewer/data/repositories/video.dart';

enum RippleSide { left, right }

class ForwardAndRewindRippleSide extends StatelessWidget {
  const ForwardAndRewindRippleSide({
    Key? key,
    required this.side,
    required this.text,
  }) : super(key: key);

  final RippleSide side;
  final String text;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoStyle(context);
    final ripple = style.forwardAndRewindStyle.ripple;

    return CustomPaint(
      size: Size.infinite,
      painter: side == RippleSide.left
          ? _RippleLeftPainter(ripple)
          : _RippleRightPainter(ripple),
      child: Padding(
        padding: side == RippleSide.left ? Margin.right(20) : Margin.left(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            side == RippleSide.left
                ? style.forwardAndRewindStyle.rewind
                : style.forwardAndRewindStyle.forward,
            AutoSizeText(text, style: style.textStyle),
          ],
        ),
      ),
    );
  }
}

class _RippleLeftPainter extends CustomPainter {
  _RippleLeftPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 5;

    canvas.drawPath(
        Path()
          ..arcTo(Offset.zero & size, -1.5, 3, false)
          ..lineTo(0.0, size.height)
          ..lineTo(0.0, 0.0),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _RippleRightPainter extends CustomPainter {
  _RippleRightPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 5;
    //draw arc
    canvas.drawPath(
        Path()
          ..arcTo(Offset.zero & size, -1.5, -3.3, false)
          ..lineTo(size.width, size.height)
          ..lineTo(size.width, 0.0),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
