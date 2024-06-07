import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/configs/firebase_options.dart';
import 'package:tictactoe/pages/base_handler_page.dart';
import 'package:tictactoe/pages/auth_pages/forgot_password_page.dart';
import 'package:tictactoe/pages/auth_pages/login_with_password_page.dart';
import 'package:tictactoe/pages/auth_pages/register_page.dart';
import 'package:tictactoe/pages/protected_pages/game_pages/find_players_online.dart';
import 'package:tictactoe/pages/protected_pages/game_pages/invite_someone_to_play.dart';
import 'package:tictactoe/pages/protected_pages/game_pages/join_with_invitation_code_page.dart';
import 'package:tictactoe/pages/protected_pages/home_page.dart';
import 'package:tictactoe/pages/protected_pages/misc_pages/leaderboard.dart';
import 'package:tictactoe/pages/protected_pages/misc_pages/personal_game_record.dart';
import 'package:tictactoe/pages/protected_pages/misc_pages/personal_game_record_all.dart';
import 'package:tictactoe/pages/protected_pages/misc_pages/profile.dart';
import 'package:tictactoe/services/game_services.dart';
import 'package:tictactoe/utils/Constants.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // runApp(const MyApp());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameServices()),
      ],
      child: MaterialApp(
        title: 'tictactoe',
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // colorScheme: ColorScheme.fromSeed(
          //   seedColor: Colors.black12,
          //   background: Colors.black87,
          // ),
          textTheme: const TextTheme(
              // bodyText1: TextStyle(
              //   color: AppConstants.primaryTextColor,
              //   fontSize: 12,
              // ),
              // bodyText2: TextStyle(
              //   color: AppConstants.primaryTextColor,
              //   fontSize: 16,
              // ),
              ),
          colorScheme: ColorScheme.fromSwatch(
            // primarySwatch: Colors.blue,
            // backgroundColor: AppConstants.primaryBGColor,

            backgroundColor: AppConstants.primaryBGColor,
            accentColor: AppConstants.primaryMainColor,

            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          // fontFamily: "Kongtext",
          fontFamily: "RetroGaming",
        ),
        home: const BaseHandler(),

        /// routes will be here
        routes: {
          // Auth Pages
          "/forgot-password": (context) => const ForgotPasswordPage(),
          "/register": (context) => const RegisterPage(),
          "/login": (context) => const LoginWithPassword(),

          /// Protected Pages
          "/home": (context) => const HomePage(),

          // Game Pages
          "/find-players-online": (context) => const FindPlayersOnline(),
          "/join-with-invitation-code": (context) =>
              const JoinWithInvitationCodePage(),
          "/invite-someone-to-play": (context) => const InviteSomeonePage(),
          // "/confirm-match": (context) => const ConfirmMatchPage(), // Handled from other pages
          // "/the-game-page": (context) => TheGamePage(),

          // Misc Pages
          "/profile": (context) => const ProfilePage(),
          "/leaderboard": (context) => const Leaderboard(),
          "/personal-game-record": (context) => const PersonalGameRecord(),
          "/personal-game-record-all": (context) =>
              const PersonalGameRecordAll(),

          // Record Pages

          //
        },
      ),
    );
  }
}
