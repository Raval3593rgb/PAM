import 'package:flutter/material.dart';

class PetAvatar extends StatelessWidget {
  final double radius;

  const PetAvatar({
    super.key,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: Icon(
        Icons.pets,
        size: radius,
      ),
    );
  }
}