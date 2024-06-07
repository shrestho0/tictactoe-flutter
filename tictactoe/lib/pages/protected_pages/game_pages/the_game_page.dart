import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:tictactoe/pages/protected_pages/home_page.dart';
import 'package:tictactoe/services/game_services.dart';
import 'package:tictactoe/utils/Constants.dart';
import 'package:tictactoe/utils/Utils.dart';

/// Post Game page er maybe dorkar ee nei, ekhanei logic diye show kora jabe, accordingly kaj kora jabe.
/// feels a bit comfortable now

enum GameState { NOT_STARTED, STARTED, ENDED }

enum GameResult {
  // 0 Player None -> All 0 case OR incomplete game
  // 1 Player 1 wins
  // 2 Player 2 wins
  // 3 Draw
  INCOMPLETE,
  PLAYER_1_WINS,
  PLAYER_2_WINS,
  DRAW,
}

enum WhoWantsARematch { NONE, OTHER_PLAYER, BOTH_PLAYERS }

class TheGamePage extends StatefulWidget {
  final String gameId;
  final int sessionGameNumber;
  final String prevGameId;
  final int player1Won;
  final int player2Won;

  const TheGamePage({
    super.key,
    required this.gameId,
    required this.sessionGameNumber,
    required this.player1Won,
    required this.player2Won,
    required this.prevGameId,
  });

  @override
  State<TheGamePage> createState() => _TheGamePageState();
}

class _TheGamePageState extends State<TheGamePage> {
  User? user = FirebaseAuth.instance.currentUser;
  GameState gameState = GameState.NOT_STARTED;
  GameResult gameResult = GameResult.INCOMPLETE;
  dynamic gameData;
  dynamic winningMoves;
  dynamic winningPlayer;
  dynamic otherPlayerWantsRematch;
  dynamic bothPlayersWantRematch;
  WhoWantsARematch whoWantsARematch = WhoWantsARematch.NONE;

  dynamic currentGameId;

  int player1WonXX = 0;
  int player2WonXX = 0;

  DatabaseReference? ref;

  // State Mods
  @override
  void initState() {
    // gameData["awaitClosing"] = false;
    super.initState();

    setState(() {
      player1WonXX = widget.player1Won;
      player2WonXX = widget.player2Won;
      currentGameId = widget.gameId;
    });

    initRTConn();
  }

  void initRTConn() {
    /// Jhamela hocche, set state shesh ee kora lagbe.
    /// set state ee jawar age condition check korte hobe if default ee true thakbe, user onno function ee jawar age false kore diye jabe
    /// kaj korbe ki na bujhte parchi ne.
    ref =
        FirebaseDatabase.instance.ref("games").child(widget.gameId.toString());

    gameState = GameState.STARTED;

    ref?.onValue.listen((DatabaseEvent event) {
      // check moves in the values
      //

      dynamic _gd = event.snapshot.value;
      // TODO: check all values are present
      // if not then return to home page

      if (_gd != null) {
        // handle re-match here

        // game data age shob set korbe
        setState(() {
          gameData = _gd;
        });

        WhoWantsARematch? whoWants;

        if (gameState == GameState.ENDED) {
          bool player1WantsRematch = false;
          bool player2WantsRematch = false;

          if (_gd["player1_rematch"] != null) {
            player1WantsRematch = _gd["player1_rematch"] == 1;
          }

          if (_gd["player2_rematch"] != null) {
            player2WantsRematch = _gd["player2_rematch"] == 1;
          }

          print(
              "[[[ rematch check ]]] $player1WantsRematch $player2WantsRematch");

          if (player1WantsRematch && player2WantsRematch) {
            // Both players want a rematch

            // print(
            //     "[[[ both player wants a re-match ${player1WantsRematch} ${player2WantsRematch} ]]]");

            //////////// Make this work here  //////////////
            /// Try to delete the current game data
            // Navigator.popUntil(context, (route) => nul);

            var prevGameId = widget.prevGameId;
            var rematchId = gameData["re_match_id"];
            var gameSessionNumber = widget.sessionGameNumber;
            var didPlayer1Won = gameData["winner"] == 1
                ? widget.player1Won + 1
                : widget.player1Won;

            var didPlayer2Won = gameData["winner"] == 2
                ? widget.player2Won + 1
                : widget.player2Won;

            if (_gd["old_game_id"] != "") {
              context
                  .read<GameServices>()
                  .deleteRTGameAndAddToGameHistory(_gd["old_game_id"]);
              print("Game deleted from realtime database");
              ref?.update({
                "old_game_id": "",
              });
              print("old_game_id updated to empty");
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  print("\nBefore creating game\n");

                  return TheGamePage(
                    // what we can do is,
                    // on each round end, we can take the game data from here and save in firestore as GameData
                    // on re-match, we can create new game from current game data and save this one to firestore as GameData
                    // we can store the session number in the firestore sessions collection too. But, that can be done later
                    // need to finish this one first.
                    // for now, we will send the sessionGameNumber to next next pages until the new game.
                    // finally destory the sessionGameNumber, for now of course
                    prevGameId: prevGameId,
                    gameId: rematchId,
                    sessionGameNumber: gameSessionNumber + 1,
                    player1Won: didPlayer1Won,
                    player2Won: didPlayer2Won,
                  );
                },
              ),
            );
            //////////// Ei porjonto kaj kore  //////////////

            whoWants = WhoWantsARematch.BOTH_PLAYERS;

            // Create
          } else if (player1WantsRematch || player2WantsRematch) {
            // re-match er jonno ask korbe

            // TheGamePage(
            //   gameId: widget.gameId,
            //   sessionGameNumber: widget.sessionGameNumber + 1,
            // );

            if (context.read<GameServices>().playerJoiningAs == 1 &&
                player2WantsRematch) {
              whoWants = WhoWantsARematch.OTHER_PLAYER;
            } else if (context.read<GameServices>().playerJoiningAs == 2 &&
                player1WantsRematch) {
              whoWants = WhoWantsARematch.OTHER_PLAYER;
            }
          } else {
            // we don't care about this now
            // quit korte pare
            // player ovabei thakbe
          }
        }

        // handle player win here
        if (_gd["winner"] == 1 || _gd["winner"] == 2 || _gd["winner"] == 3) {
          setState(() {
            winningMoves = _gd["winningMoves"];
            winningPlayer = _gd["winner"];

            if (winningPlayer == 1) {
              player1WonXX = widget.player1Won + 1;
            } else if (winningPlayer == 2) {
              player2WonXX = widget.player2Won + 1;
            }

            whoWantsARematch = whoWants ?? WhoWantsARematch.NONE;
            gameState = GameState.ENDED;
          });
        }
      } else {
        // TODO: this works, don't it now.
        // Check if parent exists
        // If yes, delete that too
        // context.read<GameServices>().quitGame(context, widget.gameId);
        // if (mounted) {
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => const HomePage()));

        print("Game data is null || Mounted $mounted");
        // Back to home
        // eta age thekei thik moto kaj korchilo
        // don't get confused again.
        AppConstants.backToHome(context);
        // }
      }

      // print("LIVE GAME [[PRE-PROCCESSED]] :: ${event.snapshot.value}");
    });

    // check and return later if game does not exists
  }

  // We

  @override
  void dispose() {
    // Better code if whatever
    // Future.delayed(Duration.zero, () async {
    //   await doingSomething().then((value) => print(value));
    // });
    // TODO: Save the game data before deleting
    // Deletes the current game data
    print("[[ DEBUG ]]: Game Disposed");
    // context
    //     .read<GameServices>()
    //     .deleteRTGameAndAddToGameHistory(widget.gameId, ref);
    print("[[ DEBUG ]]: Game Deleted");

    //// ALL OF THESE WILL BE HANDLED IN GAME SERVICES
    // Update the game from Game Collection with game id
    /// This deletes the game data from realtime
    // context.read<GameServices>().deleteRTGame(widget.gameId, ref);
    // context.read<GameServices>().quitGame(context, widget.gameId, ref);

    // TODO: do this later
    // ei hishab pore korte hobe
    /// jodi user back kore then, send them to home
    /// jodi user app off kore dey, pera nei.
    /// amader cloud function orphaned data gulo check kore delete kore debe.

    // context.read<GameServices>().quitGame(context, widget.gameId, ref);
    super.dispose();
  }

  _checkAndUpdateGameData() {
    gameData = gameData as Map<dynamic, dynamic>;

    // Check game
    // int gameStatus = _checkGame(gameData["moves"].toList());
    // print("LIVE GAME [[GAME_STATUS]] :: $gameStatus");
    // "player1"
    // print("MOVES CHECK HOBE");
    // List<int> moves = gameData["moves"];
    // var (gameResult, winningMovesX) = _checkGame(gameData);

    var (gameResult, winningMovesX) =
        context.read<GameServices>().checkGame(gameData);

    if (gameResult == GameResult.INCOMPLETE) {
      context
          .read<GameServices>()
          .updateDataWithRT(widget.gameId.toString(), gameData);
      return;
    }
    {
      if (gameResult == GameResult.PLAYER_1_WINS) {
        gameData["playing"] = false;
        gameData["winner"] = 1;
      } else if (gameResult == GameResult.PLAYER_2_WINS) {
        gameData["playing"] = false;
        gameData["winner"] = 2;
      } else if (gameResult == GameResult.DRAW) {
        gameData["playing"] = false;
        gameData["winner"] = 3;
      }
      gameData["winningMoves"] = winningMovesX;
      // _updateDataWithRT();

      // Sync the latest data with Realtime Database
      context
          .read<GameServices>()
          .updateDataWithRT(widget.gameId.toString(), gameData);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("LIVE GAME [[DATA]] :: $gameData ${gameData.runtimeType}");

    // Shows if game data is null
    // But, this is subscribed to rt db
    if (gameData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    gameData = gameData as Map<dynamic, dynamic>;

    int whoAmI = (gameData["player1_id"] == user!.uid)
        ? 1
        : (gameData["player2_id"] == user!.uid)
            ? 2
            : 0;

    int whoseTurn = gameData["turn"];

    // thisIsMyTurn = gameData["turn"] == 1 ? true : false;

    print(
        "LIVE GAME [[MOVES]] ${gameData['moves']} ${gameData['moves'].runtimeType}");

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Text("The Game"),
            Text("Game Session: ${widget.sessionGameNumber}"),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  // Game state ENDED na hole border dekhabe, else na.
                  decoration:
                      (whoAmI == whoseTurn && gameState != GameState.ENDED)
                          ? AppConstants.gamePlayingActiveDecoraton
                          : AppConstants.gamePlayingInactiveDecoraton,
                  child: Column(
                    children: [
                      Text(
                        user?.uid == gameData["player2_id"]
                            ? (gameData["player2_name"] ?? "you")
                            : (gameData["player1_name"] ?? ""),
                        style: ((gameData["winner"] == 1 ||
                                    gameData["winner"] == 2) &&
                                gameData["winner"] == whoAmI)
                            ? AppConstants.gameEndWinnerTextStyle
                            : (gameData["winner"] == 3)
                                ? AppConstants.gameEndDrawTextStyle
                                : AppConstants.gameEndLoserTextStyle,
                      ),
                      Text(user?.uid == (gameData["player2_id"] ?? "")
                          ? "$player2WonXX"
                          : "$player1WonXX")
                    ],
                  ),
                ),
                const Text("vs"),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration:
                      (whoAmI != whoseTurn && gameState != GameState.ENDED)
                          ? AppConstants.gamePlayingActiveDecoraton
                          : AppConstants.gamePlayingInactiveDecoraton,
                  child: Column(children: [
                    Text(
                      user?.uid != (gameData["player2_id"] ?? "")
                          ? (gameData["player2_name"] ?? "you")
                          : (gameData["player1_name"] ?? ""),
                      style: ((gameData["winner"] == 1 ||
                                  gameData["winner"] == 2) &&
                              gameData["winner"] != whoAmI)
                          ? AppConstants.gameEndWinnerTextStyle
                          : (gameData["winner"] == 3)
                              ? AppConstants.gameEndDrawTextStyle
                              : AppConstants.gameEndLoserTextStyle,
                    ),
                    Text(
                      user?.uid != (gameData["player2_id"] ?? "")
                          ? "$player2WonXX"
                          : "$player1WonXX",
                    )
                  ]),
                ),
              ],
            ),
            // Grid

            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemBuilder: (context, index) {
                int moveVal = gameData['moves'][index];
                return GestureDetector(
                  onTap: () {
                    // Game shesh
                    // Input nebe and snackbar dekhabe
                    if (gameState == GameState.ENDED) {
                      context.read<GameServices>().showGameErrorMsg(
                            text: "Game ended",
                            popText: "Close",
                            context: context,
                            // TODO: Not implemented
                            // callback: () {
                            //   print("Game Ended mf");
                            // },
                          );

                      return;
                    }

                    if (whoseTurn == whoAmI) {
                      if (moveVal == 0) {
                        gameData['moves'][index] = whoAmI;
                        gameData['turn'] = (whoAmI == 1) ? 2 : 1;

                        _checkAndUpdateGameData();
                        // parbe
                      } else {
                        // parbe na
                        context.read<GameServices>().showGameErrorMsg(
                              text: "Not allowed",
                              popText: "Close",
                              context: context,
                            );
                      }
                    }
                    // Onno Player er turn
                    else {}
                  },
                  child: Container(
                    // padding: const EdgeInsets.all(10.0),
                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppConstants.primaryMainColor,
                        width: 2,
                      ),
                    ),
                    child: moveVal == 0
                        ? null
                        : Icon(
                            moveVal == 1 ? Icons.circle_outlined : Icons.close,
                            size: 35,
                            color: winningMoves != null
                                ? winningMoves.contains(index)
                                    ? Colors.greenAccent
                                    : AppConstants.primaryTextColor
                                : AppConstants.primaryTextColor,
                          ),
                  ),
                );
              },
              itemCount: 9,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                (gameState == GameState.ENDED && winningPlayer != null)
                    ? (winningPlayer == 1)
                        ? gameData["player1_name"] + " won"
                        : (winningPlayer == 2)
                            ? gameData["player2_name"] + " won"
                            : (winningPlayer == 3)
                                ? "Draw"
                                : ""
                    : " ",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Text(bothPlayersWantRematch == true
            //     ? "Both player wants a rematch"
            //     : otherPlayerWantsRematch == true
            //         ? "Other player wants a rematch"
            //         : ""),
            Text(whoWantsARematch == WhoWantsARematch.BOTH_PLAYERS
                ? "Both players agreed. Continuing..."
                : whoWantsARematch == WhoWantsARematch.OTHER_PLAYER
                    ? "Other player wants a rematch"
                    : ""),
            gameState == GameState.ENDED
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      appHomeButton(
                        title: "re-match",
                        icon: const Icon(Icons.repeat),
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.all(5),
                        onPressed: () => context
                            .read<GameServices>()
                            .rematchGame(context, gameData, widget.gameId),
                      ),
                      appHomeButton(
                        title: "quit game",
                        icon: const Icon(Icons.cancel),
                        onPressed: () =>
                            // ref pathano better,
                            // extra connection pool er dorkar nei
                            //
                            context.read<GameServices>().quitGame(
                                  context,
                                  widget.gameId,
                                  gameData["old_game_id"],
                                ),
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.all(5),
                      )
                    ],
                  )
                : Container(),
            // appHomeButton(title: "re-match", icon: Icon(Icons.read_more)),
            // commonOutlineButton(
            //     text: "end game",
            //     onPressed: () {
            //       Navigator.popAndPushNamed(context, "/rematch-or-end-session");
            //     }),
          ],
        ),
      ),
    );
  }
}
