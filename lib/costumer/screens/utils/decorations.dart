
import 'package:flutter/material.dart';

BoxDecoration containerDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(13),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );
}