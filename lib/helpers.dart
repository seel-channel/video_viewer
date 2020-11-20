import 'package:flutter/material.dart';
import 'package:helpers/misc_helpers.dart';
import 'package:helpers/size_helpers.dart';

class BooleanTween extends StatefulWidget {
  BooleanTween(
      {Key key,
      @required this.animate,
      @required this.tween,
      Duration duration,
      @required this.builder,
      this.curve = Curves.linear})
      : this.duration = duration ?? Duration(milliseconds: 200),
        super(key: key);

  final bool animate;
  final Duration duration;
  final Tween<dynamic> tween;
  final Widget Function(dynamic value) builder;
  final Curve curve;

  @override
  BooleanTweenState createState() => BooleanTweenState();
}

class BooleanTweenState extends State<BooleanTween>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<dynamic> animation;

  set changeTween(Tween<dynamic> tween) {
    setState(() {
      animation = tween.animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
    });
  }

  @override
  void initState() {
    _controller = AnimationController(duration: widget.duration, vsync: this);
    animation = widget.tween.animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    widget.animate ? _controller.forward() : _controller.reverse();
    super.initState();
  }

  @override
  void didUpdateWidget(BooleanTween oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.animate && widget.animate)
      _controller.forward();
    else if (oldWidget.animate && !widget.animate) _controller.reverse();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => widget.builder(animation.value),
    );
  }
}

class SwipeTransition extends StatefulWidget {
  SwipeTransition({
    Key key,
    @required this.visible,
    @required this.child,
    Duration duration,
    this.curve = Curves.ease,
    this.direction = SwipeDirection.fromBottom,
  })  : this.duration = duration ?? Duration(milliseconds: 400),
        super(key: key);

  final Widget child;
  final bool visible;
  final Curve curve;
  final Duration duration;
  final SwipeDirection direction;

  @override
  _SwipeTransitionState createState() => _SwipeTransitionState();
}

enum SwipeDirection { fromTop, fromLeft, fromRight, fromBottom }

class _SwipeTransitionState extends State<SwipeTransition> {
  GlobalKey<BooleanTweenState> tweenKey = GlobalKey<BooleanTweenState>();
  Offset direction = Offset.zero;
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
    Misc.onLayoutRendered(() {
      setState(() {
        Size size = GetKey.size(key);
        switch (widget.direction) {
          case SwipeDirection.fromTop:
            direction = Offset(0.0, -size.height);
            break;
          case SwipeDirection.fromLeft:
            direction = Offset(-size.width, 0.0);
            break;
          case SwipeDirection.fromRight:
            direction = Offset(size.width, 0.0);
            break;
          case SwipeDirection.fromBottom:
            direction = Offset(0.0, size.height);
            break;
        }
        tweenKey.currentState.changeTween = createTween();
      });
    });
  }

  Tween createTween() => Tween<Offset>(begin: direction, end: Offset.zero);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BooleanTween(
        key: tweenKey,
        tween: createTween(),
        curve: widget.curve,
        animate: widget.visible,
        duration: widget.duration,
        builder: (value) {
          return Transform.translate(
            offset: value,
            child: Container(key: key, child: widget.child),
          );
        },
      ),
    );
  }
}
