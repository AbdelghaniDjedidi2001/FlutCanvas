import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextMeasurementService {
  const TextMeasurementService();

  Size measureText({
    required String text,
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    double maxWidth = double.infinity,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text.isEmpty ? 'Type text...' : text,
        style: GoogleFonts.caveat(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return Size(painter.width, painter.height);
  }
}
