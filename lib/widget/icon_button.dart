import 'package:flutter/material.dart';

Widget iconButton({
  required Function onTap,
  required IconData iconData,
  double? size,
}) {
  return GestureDetector(
    onTap: () => onTap(),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        color: Colors.black.withOpacity(0.5),
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: size,
      ),
    ),
  );
}
