// import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/pages/protected_pages/game_pages/the_game_page.dart';
import 'package:tictactoe/services/game_services.dart';
import 'package:tictactoe/utils/Constants.dart';
import 'package:tictactoe/utils/Types.dart';
// import 'package:tictactoe/utils/Types.dart';
import 'package:tictactoe/utils/Utils.dart';

class ConfirmMatchPage extends StatefulWidget {
  // final GameType gameType;
  final String gameId;
  // final int who_joined;
  // final String name_who;
  // final String uid_who;
  final GameMatchType gameMatchType;

  const ConfirmMatchPage({
    super.key,
    // required this.gameType = GameType.ONLINE,
    required this.gameId,
    // required this.who_joined,
    // required this.name_who,
    // required this.uid_who,
    required this.gameMatchType,
  });

  @override
  State<ConfirmMatchPage> createState() => _ConfirmMatchPageState();
}

class _ConfirmMatchPageState extends State<ConfirmMatchPage> {
  User? user = FirebaseAuth.instance.currentUser;

  // void createRTGame(String gameId) {
  //   var _random = new Random();
  //   // game data about game

  //   DatabaseReference databaseReference =
  //       FirebaseDatabase.instance.ref("games").child(gameId);

  //   Map<String, Object> gameData = {
  //     "turn": _random.nextInt(2) + 1,
  //     "moves": [0, 0, 0, 0, 0, 0, 0, 0, 0],
  //     "playing": false,
  //   };
  //   if (widget.who_joined == 1) {
  //     gameData["player1_joined"] = true;
  //     gameData["player1_name"] = widget.name_who;
  //     gameData["player1_id"] = widget.uid_who;
  //   } else if (widget.who_joined == 2) {
  //     gameData["player2_joined"] = true;
  //     gameData["player2_name"] = widget.name_who;
  //     gameData["player2_id"] = widget.uid_who;
  //   }

  //   // "player1_joined": widget.who_joined == 1 ? true : false,

  //   databaseReference.once().then((event) {
  //     print(gameId);
  //     print(event.snapshot.value);
  //     if (event.snapshot.value == null) {
  //       // create game
  //       databaseReference.set(gameData);
  //     } else {
  //       gameData["playing"] = true;
  //       databaseReference.update(gameData);
  //     }
  //   });
  // }

  void manageRealtimeSubscriptionForFirstTime() {
    if (widget.gameMatchType == GameMatchType.FIRST_TIME) {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref("games")
          .child(widget.gameId.toString())
          .child("playing");
      ref.onValue.listen((dynamic event) {
        // print(
        //     "Realtime event: ${event.snapshot.value} ${event.snapshot.value.runtimeType} ");
        if (event.snapshot.exists) {
          print(
              "[[manageRealtimeSubscriptionForFirstTime]] ${event.snapshot.value} :: ${event.snapshot.value.runtimeType} :: :: ${event.snapshot}");
          // check if value has the key
          if (event.snapshot.value == true) {
            // game started
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                // TheGamePage takes game id, user1 displayname, user2 di

                return TheGamePage(
                  // what we can do is,
                  // on each round end, we can take the game data from here and save in firestore as GameData
                  // on re-match, we can create new game from current game data and save this one to firestore as GameData
                  // we can store the session number in the firestore sessions collection too. But, that can be done later
                  // need to finish this one first.
                  // for now, we will send the sessionGameNumber to next next pages until the new game.
                  // finally destory the sessionGameNumber, for now of course
                  prevGameId: "",
                  gameId: widget.gameId.toString(),
                  sessionGameNumber: 1,
                  player1Won: 0,
                  player2Won: 0,
                );
              },
            ));
          } else {
            // wait
          }
          // do nothjing
        }
      });
    } else if (widget.gameMatchType == GameMatchType.REMATCH) {
      ///
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // No need to set, already set in the home page
    // context.read<GameServices>().setPlayerName(widget.name_who);

    if (widget.gameMatchType == GameMatchType.FIRST_TIME) {
      manageRealtimeSubscriptionForFirstTime();
      context.read<GameServices>().createRTGame(gameId: widget.gameId);

      print(
          "[[DEBUG: First time match]] creating new game on realtime with game id: ${widget.gameId} ");
    } else if (widget.gameMatchType == GameMatchType.REMATCH) {
      // Handle re-match stuff here
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // ref.clea;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gameMatchType == GameMatchType.FIRST_TIME) {
      return Scaffold(
          appBar: commonProtectedAppbar(
              title: "Ready to play!",
              context: context,
              user: user,
              leading: false),
          body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.gameId.toString()),
                SizedBox(height: 20),
                const Text("waiting for match"),
                const Text("Will Be Redirected!"),
              ],
            ),
          ));
    } else if (widget.gameMatchType == GameMatchType.REMATCH) {
      return Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Rematch"),
                Text(widget.gameId),
                Text(
                    "Joining as ${context.read<GameServices>().playerJoiningAs.toString()}"),
                Text(context.read<GameServices>().playerName),
                Text(context.read<GameServices>().playerUID),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Some error occured. Please try again."),
              appHomeButton(
                  title: "Back to home",
                  icon: const Icon(Icons.home),
                  onPressed: () => AppConstants.backToHome(context)),
            ],
          ),
        ),
      );
    }
  }
}
