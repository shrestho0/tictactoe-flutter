import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/pages/protected_pages/game_pages/confirm_match_page.dart';
import 'package:tictactoe/services/game_services.dart';
import 'package:tictactoe/utils/Types.dart';
import 'package:tictactoe/utils/Utils.dart';

class JoinWithInvitationCodePage extends StatefulWidget {
  const JoinWithInvitationCodePage({super.key});

  @override
  State<JoinWithInvitationCodePage> createState() =>
      _JoinWithInvitationCodePageState();
}

class _JoinWithInvitationCodePageState
    extends State<JoinWithInvitationCodePage> {
  User? user = FirebaseAuth.instance.currentUser;

  String? errorMessage = "";

  final inviteEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: commonProtectedAppbar(
            title: "Join with Codes", context: context, user: user),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: commonTextInputs(
                    theController: inviteEditingController,
                    onChanged: (_) => clearError(),
                    labelText: "invitation code"),
              ),
              Text(errorMessage ?? ""),
              appHomeButton(
                  title: "Accept invitation",
                  icon: Icon(Icons.task_alt),
                  onPressed: handleInvitationAccept),
            ],
          ),
        ));
  }

  void clearError() {
    setState(() {
      errorMessage = "";
    });
  }

  void setError(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  void handleInvitationAccept() async {
    unfocusTextInputFields();

    String invitationCode = inviteEditingController.text;
    if (invitationCode.length != 6) {
      setError("Invitation code must be 6 characters long");
      return;
    }

    // Check if invitation code exists
    await FirebaseFirestore.instance
        .collection("Invitation")
        .where("invitation_code", isEqualTo: invitationCode)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        setError("Invitation code does not exist");
        return;
      } else {
        print("invitation code exists");
        // Check if invitation code is not expired
        var inviteData = value.docs[0];
        if (inviteData["status"] == "received") {
          setError("Invitation code already used");
          return;
        }

        if (inviteData["expires_at"].toDate().isBefore(DateTime.now())) {
          setError("Invitation code expired");
          return;
        }
        if (inviteData["sender_uid"] == user!.uid) {
          setError("You cannot accept your own invitation");
          return;
        }

        if (inviteData["receiver_uid"] == "" &&
            inviteData["status"] == "waiting") {
          // setError("Player found!");

          // Create game
          // game page will create realtime with the data it has

          FirebaseFirestore.instance.collection("TempGame").add({
            "player1": inviteData["sender_uid"],
            "player2": user!.uid,
            // 1 for player1, 2 for player2, 0 for draw, -1 for incomplete
            // "startTime": DateTime.now(), // game loading page theke update hobe, now confirm match page
            // "endTime":  DateTime.now(), // the game page theke loading hobe
          }).then((value) {
            print("THE HOLY GAME HAS BEEN CREATED");
            // Updating invitation data
            FirebaseFirestore.instance
                .collection("Invitation")
                .doc(inviteData.id)
                .update({
              "receiver_uid": user!.uid,
              "status": "received",
              "game_id": value.id,
            });

            context.read<GameServices>().setPlayerJoiningAs(2);
            context.read<GameServices>().createRTGame(gameId: value.id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmMatchPage(
                  // gameType: GameType.INVITATION,
                  gameId: value.id,
                  // who_joined: 2,
                  // name_who: user!.displayName ?? "you",
                  // uid_who: user!.uid,
                  gameMatchType: GameMatchType.FIRST_TIME,
                ),
              ),
            );
          });

          return;
          // Check if invitation code is not used
        }
      }
    });
  }
}
