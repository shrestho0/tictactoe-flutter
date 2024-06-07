import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/pages/protected_pages/game_pages/confirm_match_page.dart';
import 'package:tictactoe/services/game_services.dart';
import 'package:tictactoe/utils/Constants.dart';
import 'package:tictactoe/utils/Types.dart';
import 'package:tictactoe/utils/Utils.dart';

class InviteSomeonePage extends StatefulWidget {
  const InviteSomeonePage({super.key});

  @override
  State<InviteSomeonePage> createState() => _InviteSomeonePageState();
}

class _InviteSomeonePageState extends State<InviteSomeonePage> {
  User? user = FirebaseAuth.instance.currentUser;

  final inviteEditingController = TextEditingController();
  String? invitationCode;

  void listenToInvitationChange(String invitaionDocName) {
    final collection = FirebaseFirestore.instance
        .collection("Invitation")
        .doc(invitaionDocName);

    final listener = collection.snapshots().listen((change) {
      if (change.exists) {
        // do whatever you want to do
        print("Invitation Data Changed ${change.data()}");
        if (change.data()!["status"] == "received" &&
            change.data()!["receiver_uid"] != "" &&
            change.data()!["game_id"] != "") {
          // set player name for game

          // context.read()
          context.read<GameServices>().setPlayerJoiningAs(1);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmMatchPage(
                  // gameType: GameType.INVITATION,
                  gameId: change.data()!["game_id"],
                  // who_joined: 1,
                  // name_who: user!.displayName ?? "you",
                  // uid_who: user!.uid,
                  gameMatchType: GameMatchType.FIRST_TIME,
                ),
              ));
        } else {
          // do nothing
        }
        // return yourOwnFunction();
      } else {
        // do nothing
      }
    });
    listener.onDone(() {
      listener.cancel();
    });
  }

  @override
  void initState() {
    super.initState();

    // check if user already has an active invitation code
    invitationCode = randomString(6);

    FirebaseFirestore.instance.collection("Invitation").add({
      "sender_uid": user!.uid,
      "receiver_uid": "",
      "expires_at": DateTime.now().add(const Duration(days: 1)),
      "invitation_code": invitationCode,
      "status": "waiting",
    }).then((value) {
      listenToInvitationChange(value.id);
    });
    // context.read<GameServices>().setPlayerJoiningAs(1);

    // TODO: Delete all old invitations
    // This also can be done manually using a cronjob
    // See this later

    // final oldData = FirebaseFirestore.instance
    //     .collection("Invitation")
    //     .where("sender_uid", isEqualTo: user!.uid)
    //     .orderBy("expires_at");
    // // .where("expires_at", isGreaterThan: DateTime.now())

    // /// This can be 'waiting' or 'received' or "expired"

    // print("OLD USELESS DATA REDUCTION STARTED");
    // oldData.get().then((querySnapshot) {
    //   if (querySnapshot.docs.isNotEmpty) {
    //     // DELETE ALL DOCS
    //     // New Invitation will be created!
    //     for (var doc in querySnapshot.docs) {
    //       // doc.reference.update({"status": "expired"});
    //       if (doc.data()["status"] == "waiting" &&
    //           doc.data()["invitation_code"] != invitationCode) {
    //         print("ToDelete ${doc.data()}");
    //         doc.reference.delete();
    //       }
    //     }
    //   }
    //   // TODO: DELETE The RESTs
    // });

    print("OLD USELESS DATA REDUCTION STARTED");
    print("creating a new invitation code");
  }

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
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppConstants.primaryTextColor)),
                child: Text(
                  invitationCode.toString(),
                  style: TextStyle(color: AppConstants.primaryTextColor),
                ),
              ),
              const Text("Waiting for opponent..."),
            ],
          ),
        ));
  }
}
