import 'package:flutter/material.dart';

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double radius = 30.0;
    double notchWidth = 110.0;
    double notchHeight = 24.0;

    // Top Left Corner
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Top Right Corner
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Bottom Right Corner
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );

    // Bottom Curve
    // Notch Right Curve
    double startRight = (size.width / 2) + (notchWidth / 2);
    path.lineTo(startRight, size.height);
    path.quadraticBezierTo(
      startRight,
      size.height - notchHeight,
      startRight - radius,
      size.height - notchHeight,
    );

    // Notch Flat Roof
    double startLeft = (size.width / 2) - (notchWidth / 2);
    path.lineTo(startLeft + radius, size.height - notchHeight);

    // Notch Left Curve
    path.quadraticBezierTo(
      startLeft,
      size.height - notchHeight,
      startLeft,
      size.height,
    );

    // Bottom Left Corner
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
