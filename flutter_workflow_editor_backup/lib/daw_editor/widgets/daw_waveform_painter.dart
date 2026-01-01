import 'package:flutter/material.dart';

/// Custom painter for rendering audio waveforms
class DawWaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final bool filled;
  final double strokeWidth;

  DawWaveformPainter({
    required this.waveformData,
    this.color = Colors.blue,
    this.filled = true,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke;

    final centerY = size.height / 2;
    final path = Path();
    final pathBottom = Path();

    // Calculate points per pixel
    final samplesPerPixel = waveformData.length / size.width;

    path.moveTo(0, centerY);
    pathBottom.moveTo(0, centerY);

    for (int x = 0; x < size.width.toInt(); x++) {
      final startSample = (x * samplesPerPixel).floor();
      final endSample = ((x + 1) * samplesPerPixel).ceil().clamp(0, waveformData.length);

      // Find max amplitude in this pixel's range
      double maxAmplitude = 0.0;
      for (int i = startSample; i < endSample; i++) {
        final amplitude = waveformData[i].abs();
        if (amplitude > maxAmplitude) {
          maxAmplitude = amplitude;
        }
      }

      // Normalize amplitude (0.0 to 1.0)
      final normalizedAmp = maxAmplitude.clamp(0.0, 1.0);
      
      // Calculate y positions
      final yTop = centerY - (normalizedAmp * centerY);
      final yBottom = centerY + (normalizedAmp * centerY);

      path.lineTo(x.toDouble(), yTop);
      pathBottom.lineTo(x.toDouble(), yBottom);
    }

    if (filled) {
      // Close the path to create a filled shape
      pathBottom.lineTo(size.width, centerY);
      
      // Reverse bottom path and add to main path
      final List<Offset> bottomPoints = [];
      for (int x = size.width.toInt(); x >= 0; x--) {
        final startSample = (x * samplesPerPixel).floor();
        final endSample = ((x + 1) * samplesPerPixel).ceil().clamp(0, waveformData.length);

        double maxAmplitude = 0.0;
        for (int i = startSample; i < endSample; i++) {
          final amplitude = waveformData[i].abs();
          if (amplitude > maxAmplitude) {
            maxAmplitude = amplitude;
          }
        }

        final normalizedAmp = maxAmplitude.clamp(0.0, 1.0);
        final yBottom = centerY + (normalizedAmp * centerY);
        path.lineTo(x.toDouble(), yBottom);
      }

      path.close();
      canvas.drawPath(path, paint);
    } else {
      // Draw top and bottom lines separately
      canvas.drawPath(path, paint);
      canvas.drawPath(pathBottom, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DawWaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData ||
        oldDelegate.color != color ||
        oldDelegate.filled != filled ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Painter for live recording waveform (scrolling)
class LiveWaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final int maxVisibleSamples;

  LiveWaveformPainter({
    required this.waveformData,
    this.color = Colors.green,
    this.maxVisibleSamples = 200,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final path = Path();

    // Show only the most recent samples
    final startIndex = (waveformData.length - maxVisibleSamples).clamp(0, waveformData.length);
    final visibleData = waveformData.sublist(startIndex);

    if (visibleData.isEmpty) return;

    final xStep = size.width / visibleData.length;

    path.moveTo(0, centerY);

    for (int i = 0; i < visibleData.length; i++) {
      final x = i * xStep;
      final amplitude = visibleData[i].clamp(-1.0, 1.0);
      final y = centerY - (amplitude * centerY);
      
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw center line
    final centerLinePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1.0;
    
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant LiveWaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData;
  }
}
