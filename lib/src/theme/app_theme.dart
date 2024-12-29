import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    textTheme: GoogleFonts.poppinsTextTheme(
        Typography.material2018().black), // Fix context issue
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey[850],
    textTheme: GoogleFonts.poppinsTextTheme(
        Typography.material2018().white), // Fix context issue
  );

  static Color completedCardColor = const Color(0xffc2f6ca);
  static Color pendingCardColor = const Color(0xffd2d1ff);

  static Color priorityCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xfff6dec2)
        : const Color(0xfff6dec2);
  }

  static Color scaffoldColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
  }

  static Color titleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.black;
  }

  static Color descriptionColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff454445)
        : const Color(0xff454445);
  }

  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.grey[300]!;
  }

  static Color iconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.black54;
  }
}
