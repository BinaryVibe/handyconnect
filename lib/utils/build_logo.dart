import 'package:flutter/material.dart';

const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);


Widget buildLogo() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: kPrimaryColor,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: kPrimaryColor.withValues(alpha: 0.3),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
    ),
    child: const Icon(Icons.handyman, size: 60, color: Colors.white),
  );
}
