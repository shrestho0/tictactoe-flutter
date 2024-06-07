import 'package:flutter/material.dart';
import 'package:tictactoe/pages/protected_pages/home_page.dart';

class AppConstants {
  static const primaryBGColor = Color(0xFF02050D);
  static const primaryMainColor = Color(0xFF1E40ED);
  // static const primaryMainColor = Color(0xFF1733C1);
  static const primaryTextColor = Color(0xFFE0DDD5);

  static const internetCheckerURL = "1.1.1.1";

  static const gameEndWinnerTextStyle = TextStyle(
    color: Colors.greenAccent,
    fontWeight: FontWeight.bold,
  );
  static const gameEndLoserTextStyle = TextStyle(
    color: AppConstants.primaryTextColor,
    fontWeight: FontWeight.bold,
  );
  static final gamePlayingActiveDecoraton = BoxDecoration(
    border: Border.all(color: AppConstants.primaryTextColor),
    borderRadius: BorderRadius.circular(10),
  );

  static const gamePlayingInactiveDecoraton = null;
  static const gameEndDrawTextStyle = TextStyle(
    color: Colors.yellowAccent,
    fontWeight: FontWeight.bold,
  );

  static const gamePlayingTextStyle = TextStyle(
    color: AppConstants.primaryTextColor,
    fontWeight: FontWeight.bold,
  );

  /// Methods
  /// Back to home from anywhere and remove all previous routes
  static backToHome(context) {
    Navigator.popUntil(context, (route) => false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
}
