import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe/pages/protected_pages/game_pages/the_game_page.dart';
import 'package:tictactoe/utils/Constants.dart';
import 'package:tictactoe/utils/Utils.dart';

class GameServices extends ChangeNotifier {
  bool _loading = false;
  get loading => _loading;
  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  late String _playerName;
  get playerName => _playerName;
  void setPlayerName(String value) {
    _playerName = value;
  }

  late String _playerUID;
  get playerUID => _playerUID;
  void setPlayerUID(String value) {
    _playerUID = value;
  }

  late int _playerJoiningAs;
  get playerJoiningAs => _playerJoiningAs;

  void setPlayerJoiningAs(int value) {
    _playerJoiningAs = value;
  }

  void resetPlayerJoiningAs() {
    _playerJoiningAs = 0;
  }

  void createRTGame({required String gameId, String? oldGameId}) {
    // game data about game
    print("[[ DEBUG:  createRTGame ]] Creating real time game with $gameId");

    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref("games").child(gameId);

    Map<String, Object> newGameData = {
      "turn": Random().nextInt(2) + 1, // find a random starter
      "moves": [0, 0, 0, 0, 0, 0, 0, 0, 0],
      "playing": false, // the playing state for the confirm match page
      // if both player rematch == -1, wait
      // if both player rematch == 1, then start new game
      // if any players rematch == 0, then go to home page
      "player1_rematch": 0, // 0 for not sure/ no
      "player2_rematch": 0, // 0 for not sure/no, 1 for yes
      "re_match_id": randomString(16),
      "old_game_id": oldGameId ?? "", // new game id for rematch
    };

    if (_playerJoiningAs == 1) {
      newGameData["player1_joined"] = true;
      newGameData["player1_name"] = _playerName;
      newGameData["player1_id"] = _playerUID;
    } else if (_playerJoiningAs == 2) {
      newGameData["player2_joined"] = true;
      newGameData["player2_name"] = _playerName;
      newGameData["player2_id"] = _playerUID;
    }

    databaseReference.once().then((event) {
      print("[[ DEBUG:  createRTGame ]] Creating real time game with $gameId");

      print(
          "[[ DEBUG:  createRTGame ]] Creating real time game with ${event.snapshot.value}");

      if (event.snapshot.value == null) {
        // create game
        databaseReference.set(newGameData);
      } else {
        // update game
        // both side joined
        newGameData["playing"] = true;
        databaseReference.update(newGameData);
      }
    });
  }

  deleteRTGameAndAddToGameHistory(
    String gameId,
  ) {
    /// Check if this really needs to be async or not
    ///
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("games").child(gameId);

    ref.once().then((event) {
      if (event.snapshot.value != null) {
        dynamic gameData = event.snapshot.value;

        _moveRTGameToGameHistory(gameId, gameData);

        // TODO: remove game data from TempGame too with id gameId

        ref.remove();
      } else {
        print("DEBUG: Game data is null. Seems already deleted");
      }
    });
  }

  void _moveRTGameToGameHistory(gameId, gameData) async {
    // GameHistory
    gameData["server_end_time"] = FieldValue.serverTimestamp();
    print("DEBUG: Uploading to GameHistory Game data: $gameData");
    var db = FirebaseFirestore.instance;
    db.collection("GameHistory").doc(gameId).set({
      "player1_id": gameData["player1_id"],
      "player2_id": gameData["player2_id"],
      "winner": gameData["winner"],
      "server_end_time": gameData["server_end_time"],
    });
  }

  /// These methods don't use any state of this class, just using to keep game services organized
  /// Make these static
  void quitGame(context, String gameId, String? oldGameId) async {
    // DatabaseReference ref =
    //     FirebaseDatabase.instance.ref("games").child(gameId);

    print("DEBUG: Quitting Game");
    //  context.read<GameServices>().deleteRTGameAndAddToGameHistory(widget.gameId, ref);
    if (oldGameId != null) {
      await deleteRTGameAndAddToGameHistory(oldGameId);
    }
    await deleteRTGameAndAddToGameHistory(gameId);

    // Navigator.popUntil(context, (route) => false);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const HomePage()),
    // );
    AppConstants.backToHome(context);
  }

  void rematchGame(context, gameData, oldGameId) {
    // If both players rematch,
    // then create new game data in realtime db
    // navigate to the game page from the game page

    // User game data should be retrieved from this service
    print("DEBUG: Re-matching Game");
    DatabaseReference refGames = FirebaseDatabase.instance.ref("games");
    DatabaseReference ref = refGames.child(oldGameId);

    // Ref ee rematch_id thakle game thakle
    dynamic oldGameUpdatedData = {};

    if (_playerJoiningAs == 1) {
      print("DEBUG: Re-matching Game as player 1");
      // ref.update({

      oldGameUpdatedData["player1_rematch"] = 1;
      oldGameUpdatedData["player2_rematch"] = gameData["player2_rematch"];
      // });
    } else if (_playerJoiningAs == 2) {
      print("DEBUG: Re-matching Game as player 2");

      oldGameUpdatedData["player2_rematch"] = 1;
      oldGameUpdatedData["player1_rematch"] = gameData["player1_rematch"];
    }

    // String newGameId = refGames.push().key!;
    // if ((gameData["player1_rematch"] == 1 && _playerJoiningAs == 2) ||
    //     (gameData["player2_rematch"] == 1 && _playerJoiningAs == 1)) {
    //   // Here both player joined for re-match
    //   // create game with new game id and prev game data;
    //   oldGameUpdatedData["re_match_id"] = randomString(20);
    // }
    // if (gameData["re_match_id"] != null || gameData["re_match_id"] != "") {
    //   oldGameUpdatedData["re_match_id"] = gameData["re_match_id"];
    // } else {
    //   oldGameUpdatedData["re_match_id"] = randomString(20);
    // }

    if (oldGameUpdatedData["player1_rematch"] == 1 &&
        oldGameUpdatedData["player2_rematch"] == 1) {
      // Here both player joined for re-match
      // create game with new game id and prev game data;
      print(
          "DEBUG: Players joined for new game ${oldGameUpdatedData["player1_rematch"]} ${oldGameUpdatedData["player2_rematch"]} with New Game ID: ${oldGameUpdatedData['re_match_id']}");
    }

    ref.update({
      "player1_rematch": oldGameUpdatedData["player1_rematch"],
      "player2_rematch": oldGameUpdatedData["player2_rematch"],
      // "re_match_id": oldGameUpdatedData["re_match_id"] ?? "",
    });

    print("DEBUG: Creating createRT Game from rematchGame");
    // print("DEBUG: REMATCH ID: ${gameData["re_match_id"]}");
    createRTGame(
      gameId: gameData["re_match_id"],
      oldGameId: oldGameId,
    );
    print(
        "DEBUG: Created createRT Game from rematchGame ${gameData} ${oldGameUpdatedData}");
    // here both players want a

    // Create new game with prev data

    /// Update re-match status for both players,
    /// if both players rematch, then create new game
    /// can be handled from game page
    ///
    // create new game in realtime with prev data, which all are in this class
    // create new instance in realtime db
    // String newGameId = FirebaseDatabase.instance.ref("games").set() ;
    // createRTGame(gameId: newGameId);

    // print("DEBUG: Re-matching Game with new game id: $");
    // then push to confirm match page
    // Navigator.push(
    // context,
    // MaterialPageRoute(
    //   builder: (context) => ConfirmMatchPage(
    //     // gameType: GameType.INVITATION,
    //     gameId: change.data()!["game_id"],
    //     // who_joined: 1,
    //     // name_who: user!.displayName ?? "you",
    //     // uid_who: user!.uid,
    //     gameMatchType: GameMatchType.FIRST_TIME,
    //   ),
    // ));
  }

  void updateDataWithRT(gameId, gameData) {
    FirebaseDatabase.instance.ref("games").child(gameId).set(gameData);
  }

  (GameResult, List<int>) checkGame(gameData) {
    /// 0 Player None -> All 0 case OR incomplete game
    // min 5 moves needed to win, >4 zeros -> 0
    int emptyFields = 0;
    for (int i = 0; i < gameData["moves"].length; i++) {
      if (gameData["moves"][i] == 0) {
        emptyFields++;
      }
    }
    if (emptyFields > 4) {
      // Er age check korar dorkar nei
      return (GameResult.INCOMPLETE, [-1, -1, -1]);
    }

    var (player1Wins, player1WinningMoves) =
        _checkBoardForPlayer(gameData["moves"], 1);
    var (player2Wins, player2WinningMoves) =
        _checkBoardForPlayer(gameData["moves"], 2);

    if (player1Wins) {
      return (GameResult.PLAYER_1_WINS, player1WinningMoves);
    } else if (player2Wins) {
      return (GameResult.PLAYER_2_WINS, player2WinningMoves);
    }

    if (emptyFields == 0) {
      // No empty fields and no player won yet
      return (GameResult.DRAW, [-1, -1, -1]);
    }

    return (GameResult.INCOMPLETE, [-1, -1, -1]);
  }

  (bool, List<int>) _checkBoardForPlayer(dynamic moves, int moveVal) {
    // dynamic moves = gameData["moves"];
    // 0 1 2
    // 3 4 5
    // 6 7 8

    // 0 1 2
    if (moves[0] == moveVal && moves[1] == moveVal && moves[2] == moveVal) {
      return (true, [0, 1, 2]);
    }
    // 3 4 5
    if (moves[3] == moveVal && moves[4] == moveVal && moves[5] == moveVal) {
      return (true, [3, 4, 5]);
    }
    // 6 7 8
    if (moves[6] == moveVal && moves[7] == moveVal && moves[8] == moveVal) {
      return (true, [6, 7, 8]);
    }

    // 0 3 6
    if (moves[0] == moveVal && moves[3] == moveVal && moves[6] == moveVal) {
      return (true, [0, 3, 6]);
    }
    // 1 4 7
    if (moves[1] == moveVal && moves[4] == moveVal && moves[7] == moveVal) {
      return (true, [1, 4, 7]);
    }
    // 2 5 8
    if (moves[2] == moveVal && moves[5] == moveVal && moves[8] == moveVal) {
      return (true, [2, 5, 8]);
    }

    // 0 4 8
    if (moves[0] == moveVal && moves[4] == moveVal && moves[8] == moveVal) {
      return (true, [0, 4, 8]);
    }
    // 2 4 6
    if (moves[2] == moveVal && moves[4] == moveVal && moves[6] == moveVal) {
      return (true, [2, 4, 6]);
    }

    return (false, [-1, -1, -1]);
  }

  void showGameErrorMsg({context, text, popText, String desc = "", callback}) {
    // COnvert this to flushbar or whatever needed later
    final snackBar = SnackBar(
      content: Text(text),
      // action: SnackBarAction(
      //   label: popText,
      //   onPressed: () {
      //     if (callback != null) {
      //       callback();
      //     }
      //     Navigator.pop(context);
      //   },
      // ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Aggregation
  /// Leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard(
    String userId,
  ) async {
    // Add limit here
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // find all users from UserData

    QuerySnapshot userDataSnapshot =
        await _firestore.collection('UserData').get();
    QuerySnapshot gameHistorySnapshot =
        await _firestore.collection('GameHistory').get();

    List<Map<String, dynamic>> userDataList = [
      // {
      //   "uid": "oockTD2S9SNEpJ9G66fjpdmiiIs1",
      //   'name': 'Player 1',
      //   'total_wins': 100,
      // },
      // {
      //   "uid": "Y0or8Oq0TdXJQtcg4bbbwbg6QNl2",
      //   'name': 'Player 2',
      //   'total_wins': 90,
      // }
    ];

    // Iterate through each user document
    for (var document in userDataSnapshot.docs) {
      Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
      Map<String, dynamic> dataToAdd = {};
      // Add user data to the user data list

      dataToAdd["uid"] = userData["uid"] ?? "";
      dataToAdd["name"] = userData["name"] ?? "";

      dataToAdd["total_wins"] = 0;
      // if (dataToAdd["uid"] != "") {
      // find game history for this user
      for (var gameHistoryDoc in gameHistorySnapshot.docs) {
        Map<String, dynamic> gameHistoryData =
            gameHistoryDoc.data() as Map<String, dynamic>;

        if ((gameHistoryData["winner"] == 1 &&
                gameHistoryData["player1_id"] == dataToAdd["uid"]) ||
            (gameHistoryData["winner"] == 2 &&
                gameHistoryData["player2_id"] == dataToAdd["uid"])) {
          dataToAdd["total_wins"] += 1;
        }
        print("DEBUG: Game History Data: $gameHistoryData");
      }
      // }

      userDataList.add(dataToAdd);
    }

    // sort the list
    userDataList.sort((a, b) {
      return (b['total_wins'] as int).compareTo((a['total_wins'] as int));
    });
    // rank will be index + 1
    print("Data to be sent to Leaderboard: $userDataList");
    return userDataList;
  }

  /// Personal Game Record
  Future<List<Map<String, dynamic>>> getUserGameHistory(
    String userId,
  ) async {
    // Add limit here
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // Query GameHistory collection to get player1_id and player2_id
      QuerySnapshot gameHistorySnapshot = await _firestore
          .collection('GameHistory')
          .where('player1_id', isEqualTo: userId)
          .get();
      QuerySnapshot gameHistorySnapshot2 = await _firestore
          .collection('GameHistory')
          .where('player2_id', isEqualTo: userId)
          .get();

      var gameHistorySnapshotMerged = [
        gameHistorySnapshot2.docs,
        gameHistorySnapshot.docs
      ].expand((x) => x).toList();
      print(gameHistorySnapshotMerged.length);

      List<Map<String, dynamic>> gameHistoryList = [];

      // Iterate through each game document
      for (QueryDocumentSnapshot gameDoc in gameHistorySnapshotMerged) {
        Map<String, dynamic> gameData = gameDoc.data() as Map<String, dynamic>;

        // Get player1_id and player2_id from the game data
        String otherPlayer = gameData['player1_id'];

        // find other player name
        if (gameData["player1_id"] == userId) {
          otherPlayer = gameData['player2_id'];
        } else if (gameData["player2_id"] == userId) {
          otherPlayer = gameData['player1_id'];
        }
        // Query UserData collection to get names
        QuerySnapshot userDataSnapshot = await _firestore
            .collection('UserData')
            .where(FieldPath.documentId, whereIn: [otherPlayer]).get();

        userDataSnapshot.docs.forEach((userDataDoc) {
          Map<String, dynamic> userData =
              userDataDoc.data() as Map<String, dynamic>;
          // Add user data to the game history list
          gameHistoryList.add({
            'gameData': gameData,
            'otherPlayer': userData,
          });
        });
      }

      // sort gameHistoryList by gameData["server_end_time"]
      gameHistoryList.sort((a, b) {
        return (b['gameData']['server_end_time'] as Timestamp)
            .compareTo((a['gameData']['server_end_time'] as Timestamp));
      });

      return gameHistoryList;
    } catch (e) {
      // Handle any errors
      print('Error: $e');
      return [];
    }
  }
}
