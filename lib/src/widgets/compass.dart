import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

import '../../vars.dart';
import '../datasource.dart';
import '../services/core_functions.dart';

class CompassWidget extends StatefulWidget {
  final List<String> directions;

  const CompassWidget(this.directions, {super.key});

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  PictureInfo? pictureInfo;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    final svgString = await rootBundle.loadString('assets/icons/compass.svg');
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);

    setState(() {
      this.pictureInfo = pictureInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      isComplex: true,
      size: const Size(310, 310),
      painter: CompassPainter(pictureInfo, widget.directions),
    );
  }
}

class CompassPainter extends CustomPainter {
  final PictureInfo? pictureInfo;
  final List<String> directions;

  CompassPainter(this.pictureInfo, this.directions);

  @override
  void paint(Canvas canvas, Size size) {
    if (pictureInfo != null) {
      canvas.save();
      canvas.translate(72.0, 35.0);
      canvas.drawPicture(pictureInfo!.picture);
      pictureInfo?.picture.dispose();
      canvas.restore();
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    // Define the 8 main directions
    const directions_label = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    const angleStep = pi / 4;

    final valueStyle = TextStyle(
      color: palette.primary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    // Draw each direction
    for (int i = 0; i < directions_label.length; i++) {
      final angle = angleStep * i - pi / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: directions_label[i],
          style: TextStyle(
            color: blendColors(getDirectionColor(directions_label[i]), Colors.grey, .35),
            fontSize: directions_label[i].length > 1 ? 16 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      final valuePainter = TextPainter(
        text: TextSpan(text: directions[i], style: valueStyle),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      valuePainter.layout();

      // Calculate the position for each direction
      final dx = center.dx + (radius + 35) * cos(angle);
      final dy = center.dy + (radius + 35) * sin(angle);
      final offset = Offset(
        dx - textPainter.width / 2,
        dy - textPainter.height / 2,
      );
      final dxV = center.dx + (radius + 3) * cos(angle) - 3;
      final dyV = center.dy + (radius + 3) * sin(angle);
      final offsetV = Offset(
        dxV - textPainter.width / 2,
        dyV - textPainter.height / 2,
      );

      // Draw the text
      textPainter.paint(canvas, offset);
      valuePainter.paint(canvas, offsetV);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
