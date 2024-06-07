import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/services/game_services.dart';
import 'package:tictactoe/utils/Constants.dart';
import 'package:tictactoe/utils/Utils.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: commonProtectedAppbar(title: "Leaderboard", context: context),
      body: FutureBuilder(
        // Replace 'x' with the actual user ID
        future: context.read<GameServices>().getLeaderboard(user?.uid ?? ""),
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
            int? userPosition;
            for (int i = 0; i < gameHistoryList.length; i++) {
              if (gameHistoryList[i]['uid'] == user?.uid) {
                userPosition = i + 1;
                break;
              }
            }

            List<TableRow> tableRows = [];
            for (int i = 0; i < gameHistoryList.length; i++) {
              Map<String, dynamic> data = gameHistoryList[i];
              tableRows.add(
                TableRow(
                  decoration: gameHistoryList[i]["uid"] == user?.uid
                      ? BoxDecoration(color: AppConstants.primaryMainColor)
                      : null,
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          (i + 1).toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          data['name'],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          data['total_wins'].toString(),
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
                Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.all(5),
                  child: Text("Your position: ${userPosition ?? "N/A"}"),
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
                              child: Text('Rank', textAlign: TextAlign.center),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Name', textAlign: TextAlign.center),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Total Wins',
                                  textAlign: TextAlign.center),
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
    home: Leaderboard(),
  ));
}
