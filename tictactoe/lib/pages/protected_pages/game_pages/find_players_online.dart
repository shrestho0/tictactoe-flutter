import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/pages/protected_pages/game_pages/confirm_match_page.dart';
import 'package:tictactoe/services/game_services.dart';
import 'package:tictactoe/utils/Constants.dart';
import 'package:tictactoe/utils/Types.dart';
import 'package:tictactoe/utils/Utils.dart';

class FindPlayersOnline extends StatefulWidget {
  const FindPlayersOnline({super.key});

  @override
  State<FindPlayersOnline> createState() => _FindPlayersOnlineState();
}

class _FindPlayersOnlineState extends State<FindPlayersOnline> {
  User? user = FirebaseAuth.instance.currentUser;
  // var counterStream =
  //     Stream<int>.periodic(const Duration(seconds: 1), (x) => x).take(3);

  listenToInvitationChange() {
    // await Future.delayed(const Duration(seconds: 3));
    // Navigator.pushNamed(context, "/confirm-match");
    final validEmptyInvitations = FirebaseFirestore.instance
        .collection("Invitation")
        .where("status", isEqualTo: "waiting")
        .where("invitation_code", isEqualTo: "ONLINE")
        .where("sender_uid", isNotEqualTo: user!.uid)
        .where("receiver_uid", isEqualTo: "")
        .get();

    validEmptyInvitations.then((value) {
      if (value.docs.isNotEmpty) {
        // update the invitation
        // start the game
        FirebaseFirestore.instance
            .collection("Invitation")
            .doc(value.docs[0].id)
            .update({
          "receiver_uid": user!.uid,
          "status": "received",
        });
        // Start game here
        // as this is the receiver
        // Before Starting Game check if user is already playing, whatever

        context.read<GameServices>().setPlayerJoiningAs(2);
        context
            .read<GameServices>()
            .createRTGame(gameId: value.docs[0]["game_id"]);

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmMatchPage(
                gameId: value.docs[0]["game_id"],
                gameMatchType: GameMatchType.FIRST_TIME,
              ),
            ));
      } else {
        // create a new invitation
        // then wait for other to join
        String newGameId = randomString(15);
        FirebaseFirestore.instance.collection("Invitation").add({
          "sender_uid": user!.uid,
          "receiver_uid": "",
          "status": "waiting",
          "invitation_code": "ONLINE",
          "game_id": newGameId,
        });

        // wait for others to join
        context.read<GameServices>().setPlayerJoiningAs(1);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmMatchPage(
                // gameType: GameType.INVITATION,
                gameId: newGameId,
                // who_joined: 1,
                // name_who: user!.displayName ?? "you",
                // uid_who: user!.uid,
                gameMatchType: GameMatchType.FIRST_TIME,
              ),
            ));
      }
    });
    // if no collection
    // create a new collection

    // FirebaseFirestore.instance.collection("Invitation").l

    // FirebaseFirestore.instance.collection("Invitation").add({
    //   "sender_uid": user!.uid,
    //   "receiver_uid": "",
    //   "status": "waiting",
    //   "invitation_code": "ONLINE",
    //   "game_id": "",
    // });
    // final listener = collection.snapshots().listen((change) {
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenToInvitationChange();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: user?.photoURL != null
                      ? Image.network(
                          user!.photoURL.toString(),
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
                "welcome, ${user?.displayName}",
                style: const TextStyle(
                  color: AppConstants.primaryTextColor,
                  // fontSize: 20.0,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.search),
                const Text("finding online players..."),
                const Text("this page will be re-directed "),
                const Text("...."),
                // StreamBuilder(
                //   stream: counterStream,
                //   builder: (context, snapshot) {
                //     if (snapshot.data != 2) {
                //       return CircularProgressIndicator(
                //         color: Colors.black87,
                //       );
                //     } else {
                // return
                Column(
                  children: [
                    // const Text("Player found"),
                    // commonOutlineButton(
                    //     text: "play with: `player007`",
                    //     onPressed: () {
                    //       Navigator.pushNamed(context, "/confirm-match");

                    //       // the game page
                    //     }),
                    commonOutlineButton(
                        text: "cancel",
                        onPressed: () {
                          Navigator.pop(context);
                          // the game page
                        }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
