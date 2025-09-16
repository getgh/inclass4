import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

void main() {
  runApp(const EmojiDrawingApp());
}

class EmojiDrawingApp extends StatelessWidget {
  const EmojiDrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Drawing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const EmojiDrawingScreen(),
    );
  }
}
//wid
class EmojiDrawingScreen extends StatefulWidget {
  const EmojiDrawingScreen({super.key});

  @override
  State<EmojiDrawingScreen> createState() => _EmojiDrawingScreenState();
}

class _EmojiDrawingScreenState extends State<EmojiDrawingScreen> {
  String _currentEmoji = 'Smiley';
  final List<String> _emojiOptions = ['Smiley', 'Party Face', 'Heart'];
  List<Offset> _tapPositions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Emoji Drawing'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Select an Emoji:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: _currentEmoji,
                      isExpanded: false,
                      items: _emojiOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _currentEmoji = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tap on the canvas to draw your selected emoji!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade50, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              height: 350,
              width: double.infinity,
              child: GestureDetector(
                onTapDown: (TapDownDetails details) {
                  setState(() {
                    _tapPositions.add(details.localPosition);
                  });
                },
                onLongPress: () {
                  setState(() {
                    _tapPositions.clear();
                  });
                },
                child: CustomPaint(
                  painter: EmojiCanvasPainter(
                    tapPositions: _tapPositions,
                    currentEmoji: _currentEmoji,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('How to use:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('- Select an emoji from the dropdown'),
                    Text('- Tap on the canvas to draw that emoji'),
                    Text('- Long press to clear all emojis'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FacePainter {
  void drawFace(Canvas canvas, Offset center, double radius) {
    final facePaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(center, radius, facePaint);
  }

  void drawEyes(Canvas canvas, Offset center, double faceRadius) {
    final eyeRadius = faceRadius * 0.1;
    final leftEyeCenter = Offset(center.dx - faceRadius * 0.3, center.dy - faceRadius * 0.2);
    final rightEyeCenter = Offset(center.dx + faceRadius * 0.3, center.dy - faceRadius * 0.2);
    final eyePaint = Paint()..color = Colors.black;

    canvas.drawCircle(leftEyeCenter, eyeRadius, eyePaint);
    canvas.drawCircle(rightEyeCenter, eyeRadius, eyePaint);
  }

  void drawSmile(Canvas canvas, Offset center, double faceRadius) {
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = faceRadius * 0.1;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: faceRadius * 0.6),
      pi / 4,
      pi * 0.8,
      false,
      smilePaint,
    );
  }
}
 // custom paint
class EmojiCanvasPainter extends CustomPainter {
  final List<Offset> tapPositions;
  final String currentEmoji;

  EmojiCanvasPainter({required this.tapPositions, required this.currentEmoji});

  @override
  void paint(Canvas canvas, Size size) {
    for (final position in tapPositions) {
      _drawEmojiAtPosition(canvas, position, size);
    }
  }
 // positioned emoji
  void _drawEmojiAtPosition(Canvas canvas, Offset position, Size canvasSize) {
    final facePainter = FacePainter();
    final emojiSize = min(canvasSize.width, canvasSize.height) * 0.2;

    switch (currentEmoji) {
      case 'Party Face':
        _drawPartyFace(canvas, position, emojiSize);
        break;
      case 'Heart':
        _drawHeart(canvas, position, emojiSize);
        break;
      default:
        _drawSmiley(canvas, position, emojiSize, facePainter);
    }
  }

  void _drawSmiley(Canvas canvas, Offset center, double faceRadius, FacePainter facePainter) {
    facePainter.drawFace(canvas, center, faceRadius);
    facePainter.drawEyes(canvas, center, faceRadius);
    facePainter.drawSmile(canvas, center, faceRadius);
  }

  void _drawPartyFace(Canvas canvas, Offset center, double faceRadius) {
    final facePaint = Paint()
      ..shader = ui.Gradient.radial(center, faceRadius, [Colors.yellow, Colors.orange], [0.0, 1.0]);
    canvas.drawCircle(center, faceRadius, facePaint);

    final facePainter = FacePainter();
    facePainter.drawEyes(canvas, center, faceRadius);
    facePainter.drawSmile(canvas, center, faceRadius);

    _drawPartyHat(canvas, center, faceRadius);
    _drawConfetti(canvas, center, faceRadius);
  }
 // party hat
  void _drawPartyHat(Canvas canvas, Offset center, double faceRadius) {
    final hatPaint = Paint()..color = Colors.pink;
    final hatPath = Path()
      ..moveTo(center.dx - faceRadius * 0.2, center.dy - faceRadius * 0.8)
      ..lineTo(center.dx + faceRadius * 0.2, center.dy - faceRadius * 0.8)
      ..lineTo(center.dx, center.dy - faceRadius * 1.5)
      ..close();
    canvas.drawPath(hatPath, hatPaint); 

    canvas.drawCircle(
      Offset(center.dx, center.dy - faceRadius * 1.5),
      faceRadius * 0.08,
      Paint()..color = Colors.red,
    );

    canvas.drawLine(
      Offset(center.dx - faceRadius * 0.2, center.dy - faceRadius * 0.8),
      Offset(center.dx + faceRadius * 0.2, center.dy - faceRadius * 0.8),
      Paint()
        ..color = Colors.pink.shade200
        ..strokeWidth = faceRadius * 0.05,
    );
  }
 // confetti party face
  void _drawConfetti(Canvas canvas, Offset center, double faceRadius) {
    final confettiColors = [Colors.blue, Colors.green, Colors.pink, Colors.purple, Colors.red];
    final random = Random((center.dx + center.dy).toInt()); // Fixed Random constructor

    for (int i = 0; i < 15; i++) {
      final color = confettiColors[random.nextInt(confettiColors.length)];
      final confettiPaint = Paint()..color = color;

      canvas.drawCircle(
        Offset(
          center.dx + faceRadius * 0.8 * (random.nextDouble() * 2 - 1),
          center.dy + faceRadius * 0.8 * (random.nextDouble() * 2 - 1),
        ),
        faceRadius * (0.03 + random.nextDouble() * 0.05),
        confettiPaint,
      );
    }
  }
  // drew sparkles around the heart
void _drawSparkles(Canvas canvas, Offset center, double heartSize) {
    final sparklePaint = Paint()..color = Colors.white;
    final random = Random((center.dx + center.dy).toInt());

    for (int i = 0; i < 8; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = heartSize * 0.6 * random.nextDouble();
      final sparkleCenter = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      final path = Path();
      final outerRadius = heartSize * 0.03;
      final innerRadius = heartSize * 0.015;

      for (int j = 0; j < 5; j++) { // Changed i to j to avoid conflict with outer loop
        final outerAngle = 2 * pi * j / 5 - pi / 2;
        final innerAngle1 = 2 * pi * (j + 0.5) / 5 - pi / 2 + pi / 5;
        final innerAngle2 = 2 * pi * (j + 0.5) / 5 - pi / 2 - pi / 5;

        path.moveTo(
          sparkleCenter.dx + cos(outerAngle) * outerRadius,
          sparkleCenter.dy + sin(outerAngle) * outerRadius,
        );
        path.lineTo(
          sparkleCenter.dx + cos(innerAngle1) * innerRadius,
          sparkleCenter.dy + sin(innerAngle1) * innerRadius,
        );
        path.lineTo(
          sparkleCenter.dx + cos(innerAngle2) * innerRadius,
          sparkleCenter.dy + sin(innerAngle2) * innerRadius,
        );
        path.close();
      }

      canvas.drawPath(path, sparklePaint);
    }
  }
  // heart shape with gradient fill
void _drawHeart(Canvas canvas, Offset center, double heartSize) {
    final heartPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx - heartSize, center.dy - heartSize),
        Offset(center.dx + heartSize, center.dy + heartSize),
        [Colors.red, Colors.pink],
        [0.0, 1.0],
      )
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - heartSize * 0.7)
      ..cubicTo(
        center.dx + heartSize * 0.5, center.dy - heartSize,
        center.dx + heartSize, center.dy - heartSize * 0.3,
        center.dx, center.dy + heartSize * 0.3,
      )
      ..cubicTo(
        center.dx - heartSize, center.dy - heartSize * 0.3,
        center.dx - heartSize * 0.5, center.dy - heartSize,
        center.dx, center.dy - heartSize * 0.7,
      );

    canvas.drawPath(path, heartPaint);
    _drawSparkles(canvas, center, heartSize);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}