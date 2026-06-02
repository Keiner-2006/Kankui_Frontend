import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const s = 1024;
  final image = img.Image(width: s, height: s);

  // Fill with transparent
  img.fillRect(image, x1: 0, y1: 0, x2: s, y2: s, color: img.ColorRgba8(0, 0, 0, 0));

  final dark = img.ColorRgba8(92, 46, 0, 255);
  final accent = img.ColorRgba8(212, 115, 10, 255);
  final light = img.ColorRgba8(244, 165, 53, 255);
  final lineColor = img.ColorRgba8(255, 255, 255, 160);

  // Bag body - large circle
  img.fillCircle(image, x: s ~/ 2, y: s ~/ 2 + 80, radius: 320, color: accent);
  img.drawCircle(image, x: s ~/ 2, y: s ~/ 2 + 80, radius: 320, color: dark);

  // Top opening - smaller circle overlapping
  img.fillCircle(image, x: s ~/ 2, y: s ~/ 2 - 180, radius: 170, color: light);
  img.drawCircle(image, x: s ~/ 2, y: s ~/ 2 - 180, radius: 170, color: dark);

  // Opening inner
  img.fillCircle(image, x: s ~/ 2, y: s ~/ 2 - 200, radius: 100, color: accent);
  img.drawCircle(image, x: s ~/ 2, y: s ~/ 2 - 200, radius: 100, color: dark);

  // Strap going up from top
  img.drawLine(image, x1: s ~/ 2, y1: s ~/ 2 - 330, x2: s ~/ 2, y2: 40, color: dark, thickness: 22);
  img.drawLine(image, x1: s ~/ 2, y1: s ~/ 2 - 330, x2: s ~/ 2, y2: 40, color: light, thickness: 8);

  // Weave pattern - crossing lines inside body
  img.drawLine(image, x1: s ~/ 2 - 240, y1: s ~/ 2 - 60, x2: s ~/ 2 + 240, y2: s ~/ 2 + 280, color: lineColor, thickness: 6);
  img.drawLine(image, x1: s ~/ 2 + 240, y1: s ~/ 2 - 60, x2: s ~/ 2 - 240, y2: s ~/ 2 + 280, color: lineColor, thickness: 6);
  img.drawLine(image, x1: s ~/ 2 - 240, y1: s ~/ 2 + 100, x2: s ~/ 2 + 240, y2: s ~/ 2 + 100, color: lineColor, thickness: 6);
  img.drawLine(image, x1: s ~/ 2 - 80, y1: s ~/ 2 - 140, x2: s ~/ 2 - 80, y2: s ~/ 2 + 360, color: lineColor, thickness: 6);
  img.drawLine(image, x1: s ~/ 2 + 80, y1: s ~/ 2 - 140, x2: s ~/ 2 + 80, y2: s ~/ 2 + 360, color: lineColor, thickness: 6);

  // Bottom decoration
  img.drawLine(image, x1: s ~/ 2 - 180, y1: s ~/ 2 + 320, x2: s ~/ 2 + 180, y2: s ~/ 2 + 320, color: lineColor, thickness: 4);

  final png = img.encodePng(image);
  File('assets/icon.png').writeAsBytesSync(png);
  print('Icon generated at assets/icon.png');
}
