import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

import '../../vars.dart';
import '../datasource.dart';
import '../services/core_functions.dart';

class CompassStar extends StatefulWidget {
  final List<String> directions;

  const CompassStar(this.directions, {super.key});

  @override
  State<CompassStar> createState() => _CompassStarState();
}

class _CompassStarState extends State<CompassStar> {
  PictureInfo? pictureInfo;

  @override
  void initState() {
    super.initState();
    //_loadSvg();
    //_loadImg();
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
    var a = getRotatedLists(directions);

    final List<String> directions2 = a.$1;
    final List<String> directionsLabel2 = a.$2;

    const double angleStep = pi / 4;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.translate(2, -6);

    if (pictureInfo != null) {
      canvas.translate(72.0, 35.0);
      canvas.drawPicture(pictureInfo!.picture);
      pictureInfo?.picture.dispose();
      canvas.restore();
    }

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width, size.height) / 2 - 15;

    final TextStyle valueStyle = TextStyle(
      color: palette.primary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < directionsLabel2.length; i++) {
      final angle = angleStep * (i + 4) - pi / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: directionsLabel2[i],
          style: TextStyle(
            color: blendColors(getDirectionColor(directionsLabel2[i]), Colors.grey, .35),
            fontSize: directionsLabel2[i].length > 1 ? 16 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      final valuePainter = TextPainter(
        text: TextSpan(text: directions2[i], style: valueStyle),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      valuePainter.layout();

      final dx = center.dx + (radius + 35) * cos(angle);
      final dy = center.dy + (radius + 35) * sin(angle);
      final offset = Offset(
        dx - textPainter.width / 2,
        6 + dy - textPainter.height / 2,
      );
      final dxV = center.dx + (radius + 3) * cos(angle) - 3;
      final dyV = center.dy + (radius + 3) * sin(angle) + 3;
      final offsetV = Offset(
        dxV - textPainter.width / 2,
        dyV - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
      valuePainter.paint(canvas, offsetV);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

(List<String>, List<String>) getRotatedLists(List<String> directions) {
  final List<String> temp = directions + directions;
  final List<String> temp2 = ['E', 'SE', 'S', 'SW', 'W', 'NW', 'N', 'NE'] + ['E', 'SE', 'S', 'SW', 'W', 'NW', 'N', 'NE'];

  final int targetIndex = directions.indexOf("+1");
  if (targetIndex == -1) return ([], []);

  final List<String> directions2 = temp.sublist(targetIndex, targetIndex + 8);
  final List<String> directionsLabel2 = temp2.sublist(targetIndex, targetIndex + 8);

  return (directions2, directionsLabel2);
}

//

class CompassTable extends StatefulWidget {
  final List<String> directions;

  const CompassTable(this.directions, {super.key});

  @override
  State<CompassTable> createState() => _CompassTableState();
}

class _CompassTableState extends State<CompassTable> {
  late List<String> directions;
  late List<String> directionsLabel;
  bool isDirection = false;

  @override
  void initState() {
    super.initState();
    var a = getRotatedLists(widget.directions);
    directions = a.$1;
    directionsLabel = a.$2;
  }

  TextStyle _getStyle(String dir) => TextStyle(
        color: isDirection ? blendColors(getDirectionColor(dir), Colors.grey, .35) : palette.secondary,
        fontSize: 20,
        fontWeight: isDirection ? FontWeight.normal : FontWeight.bold,
      );

  Widget _getTable(List<String> a) {
    const double h = 50;
    isDirection = !isDirection;
    
    return SizedBox(
      width: 310,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              TableCell(child: Center(child: Text(a[7], style: _getStyle(a[7])))),
              TableCell(child: Center(child: Text(a[0], style: _getStyle(a[0])))),
              TableCell(child: Center(child: Text(a[1], style: _getStyle(a[1])))),
            ],
          ),
          const TableRow(children: [
            SizedBox(height: h),
            SizedBox(height: h),
            SizedBox(height: h),
          ]),
          TableRow(
            children: [
              TableCell(child: Center(child: Text(a[6], style: _getStyle(a[6])))),
              const TableCell(child: Center(child: Text(''))), // Empty cell
              TableCell(child: Center(child: Text(a[2], style: _getStyle(a[2])))),
            ],
          ),
          const TableRow(children: [
            SizedBox(height: h),
            SizedBox(height: h),
            SizedBox(height: h),
          ]),
          TableRow(
            children: [
              TableCell(child: Center(child: Text(a[5], style: _getStyle(a[5])))),
              TableCell(child: Center(child: Text(a[4], style: _getStyle(a[4])))),
              TableCell(child: Center(child: Text(a[3], style: _getStyle(a[3])))),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(offset: const Offset(10, -15), child: _getTable(directionsLabel)),
        Transform.translate(offset: const Offset(10, 15), child: _getTable(directions)),
      ],
    );
  }
}
