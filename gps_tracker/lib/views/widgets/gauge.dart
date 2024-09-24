import 'package:flutter/material.dart';
import 'dart:math';

class CustomGauge extends StatelessWidget {
  final double value; // La valeur actuelle de la jauge
  final double maxValue; // La valeur maximale
  final String label; // Le label de la jauge
  final Color color; // La couleur de remplissage

  const CustomGauge({
    Key? key,
    required this.value,
    required this.maxValue,
    required this.label,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      child: CustomPaint(
        painter: GaugePainter(
          value: value,
          maxValue: maxValue,
          label: label,
          color: color,
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final String label;
  final Color color;

  GaugePainter({
    required this.value,
    required this.maxValue,
    required this.label,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = min(centerX, centerY) - 10;

    // Dessiner le cercle de fond (vide)
    Paint baseCircle = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(centerX, centerY), radius, baseCircle);

    // Dessiner l'arc de la jauge remplie
    Paint gaugeArc = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double sweepAngle = (value / maxValue) * 2 * pi; // Calcul de l'angle

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      -pi / 2, // L'arc commence à 12 heures (vers le haut)
      sweepAngle,
      false,
      gaugeArc,
    );

    // Dessiner le texte au centre
    TextSpan span = TextSpan(
      style: TextStyle(color: Colors.black, fontSize: 16),
      text: '${(value / maxValue * 100).toInt()}%', // Afficher la valeur en pourcentage
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(centerX - tp.width / 2, centerY - tp.height / 2),
    );

    // Dessiner le label en bas
    TextSpan labelSpan = TextSpan(
      style: TextStyle(color: Colors.black, fontSize: 12),
      text: label,
    );
    TextPainter labelPainter = TextPainter(
      text: labelSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset(centerX - labelPainter.width / 2, centerY + radius + 10),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint si les valeurs changent
  }
}
