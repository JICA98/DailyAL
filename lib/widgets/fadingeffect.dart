import 'package:flutter/cupertino.dart';

class FadingEffect extends CustomPainter {
  final Color color;
  int start, end;
  double widthOffset, heightOffset;
  final double extend;
  FadingEffect(
      {required this.color,
      this.widthOffset = 0,
      this.heightOffset = 0,
      this.start = 200,
      this.end = 255,
      this.extend = 10});
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromPoints(Offset(widthOffset, heightOffset),
        Offset(size.width, size.height + extend));
    LinearGradient lg = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(start, color.red, color.green, color.blue),
          Color.fromARGB(end, color.red, color.green, color.blue)
        ]);
    Paint paint = Paint()..shader = lg.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(FadingEffect linePainter) => false;
}
