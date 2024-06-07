import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/services/game_services.dart';
import 'package:tictactoe/utils/Constants.dart';
import 'package:tictactoe/utils/Utils.dart';

// class PersonalGameRecordAll extends StatefulWidget {
//   const PersonalGameRecordAll({super.key});

//   @override
//   State<PersonalGameRecordAll> createState() => _PersonalGameRecordAllState();
// }

// class _PersonalGameRecordAllState extends State<PersonalGameRecordAll> {
//   final List dummyData = [
//     {"playerName": "player43", "result": false},
//     {"playerName": "player34", "result": false},
//     {"playerName": "player45", "result": true},
//     {"playerName": "player75", "result": true},
//     {"playerName": "player23", "result": true},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     User? user = FirebaseAuth.instance.currentUser;
//     return Scaffold(
//       appBar: commonProtectedAppbar(
//           title: "Game Records", context: context, user: user),
//       body: Container(
//         alignment: Alignment.center,
//         padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // text with border
//             Container(
//               alignment: Alignment.center,
//               margin: const EdgeInsets.all(10.0),
//               padding: const EdgeInsets.all(5.0),
//               decoration:
//                   textInsideBox(), //             <--- BoxDecoration here
//               child: Text(
//                 "your position: 96",
//                 style: TextStyle(fontSize: 15.0),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             Container(
//               alignment: Alignment.center,
//               child: Text(""),
//             ),
//             Table(
//               border: TableBorder.all(),
//               children: [
//                 TableRow(
//                   children: [
//                     Text("Opponent"),
//                     Text("Result"),
//                   ],
//                 ),
//                 ...dummyData.map((e) {
//                   return TableRow(children: [
//                     Text(e["playerName"]),
//                     Text(e["result"] ? "Won" : "Lost"),
//                   ]);
//                 }),
//               ],
//             ),

//             GestureDetector(
//               onTap: () {
//                 Navigator.pushNamed(context, "/personal-game-record-all");
//               },
//               child: Container(
//                 margin: const EdgeInsets.all(10.0),
//                 padding: const EdgeInsets.all(5.0),
//                 clipBehavior: Clip.antiAlias,
//                 decoration: textInsideBox(
//                     radius: 10), //             <--- BoxDecoration here
//                 child: Text(
//                   "view all records",
//                   style: TextStyle(fontSize: 15.0),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class PersonalGameRecordAll extends StatefulWidget {
  const PersonalGameRecordAll({super.key});

  @override
  State<PersonalGameRecordAll> createState() => _PersonalGameRecordAllState();
}

class _PersonalGameRecordAllState extends State<PersonalGameRecordAll> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar:
          commonProtectedAppbar(title: "Personal Records", context: context),
      body: FutureBuilder(
        // Replace 'x' with the actual user ID
        future:
            context.read<GameServices>().getUserGameHistory(user?.uid ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text("Loading..."),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> gameHistoryList =
                snapshot.data as List<Map<String, dynamic>>;
            if (gameHistoryList.isEmpty) {
              return Text("No personal record found");
            }
            List<TableRow> tableRows = [];
            for (int i = 0; i < gameHistoryList.length; i++) {
              Map<String, dynamic> gameData = gameHistoryList[i]['gameData'];

              bool winOrLose = user?.uid == gameData["player1_id"] &&
                      gameData["winner"] == 1 ||
                  user?.uid == gameData["player2_id"] &&
                      gameData["winner"] == 2;

              Map<String, dynamic> data = gameHistoryList[i];
              tableRows.add(
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          data['otherPlayer']['name'] ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: gameHistoryList[i]["uid"] == user?.uid
                                  ? Colors.white
                                  : null),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          winOrLose ? "Won" : "Lost",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Text("Total games played: ${gameHistoryList.length}"),
                Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.all(5),
                  decoration: AppConstants.gamePlayingActiveDecoraton,
                  child: Text("you vs other player"),
                ),
                Expanded(
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      // Table header
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Name', textAlign: TextAlign.center),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Score', textAlign: TextAlign.center),
                            ),
                          ),
                        ],
                      ),
                      ...tableRows,
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PersonalGameRecordAll(),
  ));
}
