import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/services/game_services.dart';
import 'package:tictactoe/utils/Constants.dart';
import 'package:tictactoe/utils/Utils.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    /// Jay ashuk, text input hidden ee thakbe
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    User? user = FirebaseAuth.instance.currentUser;

    context.read<GameServices>().setPlayerName(user!.displayName ?? "you");
    context.read<GameServices>().setPlayerUID(user.uid);

    print("${user}");

    return Scaffold(
      bottomNavigationBar: commonNavigationBar(
        context: context,
        selectedIndex: 1,
        currentRoute: "/",
      ),

      /// TODO: NO APPBAR,
      /// THE Body
      body: Container(
        // color: Colors.red,
        // padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
        padding: const EdgeInsets.only(
          top: 100,
          bottom: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Image(
                  image: AssetImage('assets/ic_launcher.png'),
                  height: 50,
                  width: 50,
                ),
                const Text(
                  "tictactoe",
                  style: TextStyle(
                    color: AppConstants.primaryTextColor,
                    fontSize: 20.0,
                    fontFamily: "Kongtext",
                  ),
                ),
                ClipOval(
                  child: user.photoURL != null
                      ? Image.network(
                          user.photoURL.toString(),
                          height: 50,
                          width: 50,
                        )
                      : const CircleAvatar(
                          backgroundColor: Colors.black87,
                          child: Icon(
                            Icons.person,
                            color: Colors.white70,
                          ),
                        ),
                ),
              ],
            ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                "welcome, ${context.read<GameServices>().playerName}",
                style: const TextStyle(
                  color: AppConstants.primaryTextColor,
                  // fontSize: 20.0,
                ),
              ),
            ),

            ///
            ///
            ///
            ///
            ///
            appHomeButton(
              title: "Find players online",
              icon: const Icon(
                Icons.search,
                color: AppConstants.primaryTextColor,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/find-players-online");
              },
            ),
            appHomeButton(
              title: "Join with invitation code",
              icon: const Icon(
                Icons.join_full_outlined,
                color: AppConstants.primaryTextColor,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/join-with-invitation-code");
              },
            ),
            appHomeButton(
              title: "Invite someone to play",
              icon: const Icon(
                Icons.send,
                color: AppConstants.primaryTextColor,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/invite-someone-to-play");
              },
            ),
            // someFreeSpace(height: 50, flexible: false),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                appHomeNicherButton(
                  title: "Leaderboard",
                  icon: const Icon(Icons.trending_up),
                  onPressed: () {
                    Navigator.pushNamed(context, "/leaderboard");
                  },
                ),
                appHomeNicherButton(
                  title: "    Records    ",
                  icon: const Icon(Icons.description),
                  onPressed: () {
                    Navigator.pushNamed(context, "/personal-game-record");
                  },
                ),
              ],
            ),
            ////
            // Text(context.watch<GameServices>().loading.toString()),
            // ElevatedButton(
            //   onPressed: () {
            //     context
            //         .read<GameServices>()
            //         .setLoading(!context.read<GameServices>().loading);
            //   },
            //   child: const Text("Set Loading"),
            // ),
            // ElevatedButton(
            //   child: Text("rematch-or-end-session"),
            //   onPressed: () {
            //     // push back to the last page
            //     Navigator.popUntil(context, (route) => false);
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: (context) => const HomePage()));
            //   },
            // )
          ],
        ),
      ),
    );
    // return Scaffold(
    //   body: Container(
    //     alignment: Alignment.center,
    //     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
    //     child: Column(
    //       // mainAxisAlignment: MainAxisAlignment.center,

    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         authHeaderRow(context, user),

    //         commonOutlineButton(
    //           text: "Find Players Online",
    //           onPressed: () {
    //             Navigator.pushNamed(context, "/find-players-online");
    //           },
    //         ),

    //         commonOutlineButton(
    //           text: "Join with invitation code",
    //           onPressed: () {
    //             Navigator.pushNamed(context, "/join-with-invitation-code");
    //           },
    //         ),

    //         commonOutlineButton(
    //             text: "Invite someone to play",
    //             onPressed: () {
    //               Navigator.pushNamed(context, "/invite-someone-to-play");
    //             }),

    //         GridView.count(
    //           crossAxisCount: 2,
    //           shrinkWrap: true,
    //           children: [
    //             commonOutlineButton(
    //                 text: "Leaderboard",
    //                 onPressed: () {
    //                   Navigator.pushNamed(context, "/leaderboard");
    //                 }),
    //             commonOutlineButton(
    //                 text: "Game Record",
    //                 onPressed: () {
    //                   Navigator.pushNamed(context, "/personal-game-record");
    //                 }),
    //           ],
    //         )

    // Container(
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
    //     children: [
    //       OutlinedButton(
    //         child: Text("Leaderboard"),
    //         onPressed: () {
    //           Navigator.pushNamed(context, "/leaderboard");
    //         },
    //         style: OutlinedButton.styleFrom(
    //           backgroundColor: Colors.black87,
    //           foregroundColor: Colors.white,
    //           shape: const RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(
    //               Radius.circular(5),
    //             ),
    //           ),
    //         ),
    //       ),
    //       OutlinedButton(
    //         child: Text(
    //           "Game Record",
    //         ),
    //         onPressed: () {
    //           Navigator.pushNamed(context, "/personal-game-record");
    //         },
    //         style: OutlinedButton.styleFrom(
    //           backgroundColor: Colors.black87,
    //           foregroundColor: Colors.white,
    //           shape: const RoundedRectangleBorder(
    //             borderRadius: BorderRadius.all(
    //               Radius.circular(5),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // ),

    /// TODO: Old Stuff
    //     ],
    //   ),
    // ),
    // );
  }
}
