import 'package:flutter/material.dart';

class TimelineRuler extends StatelessWidget {
  final double pixelsPerSecond;
  final int maxMs;
  final double height;

  const TimelineRuler({
    super.key,
    required this.pixelsPerSecond,
    required this.maxMs,
    this.height = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: (maxMs / 1000.0) * pixelsPerSecond,
      child: CustomPaint(
        painter: _TimelineRulerPainter(
          pixelsPerSecond: pixelsPerSecond,
          maxMs: maxMs,
          colorScheme: Theme.of(context).colorScheme,
        ),
      ),
    );
  }
}

class _TimelineRulerPainter extends CustomPainter {
  final double pixelsPerSecond;
  final int maxMs;
  final ColorScheme colorScheme;

  _TimelineRulerPainter({
    required this.pixelsPerSecond,
    required this.maxMs,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = colorScheme.surfaceContainer;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final tickPaint = Paint()
      ..color = colorScheme.onSurfaceVariant
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: colorScheme.onSurfaceVariant,
      fontSize: 10,
    );

    final seconds = (maxMs / 1000.0).ceil();

    for (var s = 0; s <= seconds; s++) {
      final x = s * pixelsPerSecond;
      final isMajor = s % 5 == 0;
      final tickHeight = isMajor ? size.height : size.height * 0.5;

      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, size.height - tickHeight),
        tickPaint,
      );

      if (isMajor) {
        final tp = TextPainter(
          text: TextSpan(text: _formatSeconds(s), style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(canvas, Offset(x + 2, 2));
      }
    }
  }

  String _formatSeconds(int s) {
    final min = s ~/ 60;
    final sec = s % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  @override
  bool shouldRepaint(covariant _TimelineRulerPainter oldDelegate) {
    return oldDelegate.pixelsPerSecond != pixelsPerSecond || oldDelegate.maxMs != maxMs || oldDelegate.colorScheme != colorScheme;
  }
}
