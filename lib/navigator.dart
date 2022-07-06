import 'package:flutter/material.dart';

class NavigationHandle {
  static PageRoute standard({
    required BuildContext context,
    required Widget screen,
  }) {
    return MaterialPageRoute(
      builder: (context) => screen,
    );
  }
}
