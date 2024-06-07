import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tictactoe/pages/auth_pages/login_page.dart';
import 'package:tictactoe/pages/protected_pages/home_page.dart';
import 'package:tictactoe/utils/Constants.dart';

///
/// This will check internet, auth, and return the appropriate page
///
class BaseHandler extends StatefulWidget {
  const BaseHandler({super.key});

  @override
  State<BaseHandler> createState() => _BaseHandlerState();
}

class _BaseHandlerState extends State<BaseHandler> {
  // MultiProvider(
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // auth will be handled by firebase
  // Platform messages are asynchronous, so we initialize in an async method.

  // @override
  // initState() {
  //   super.initState();
  //   subscription = Connectivity()
  //       .onConnectivityChanged
  //       .listen((ConnectivityResult result) {
  //     if (result == ConnectivityResult.none) {
  //       // not connected to any network,
  //       // setInternetStatus(false);
  //       _connectivitySubscription =
  //           _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  //     } else {
  //       // connected to some network
  //       // assuming that it is connected to internet
  //       // TODO: check if it is connected to internet
  //       setInternetStatus(true);
  //     }
  //     print("[[[ new connectivity result ]]]: $result");
  //     // // Got a new connectivity status!
  //   });
  // }
  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(_connectionStatus == ConnectivityResult.none)) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        FirebaseFirestore.instance.collection("UserData").doc(user.uid).set({
          "uid": user.uid,
          "name": user.displayName ?? "",
          "isOnline": true,
          // TODO :  update that in playing part too.
          // Coming to homepage from anywhere will set isPlaying to false
          "isPlaying": false,
          "last_online_time": FieldValue.serverTimestamp(),
        });
        return const HomePage();
      } else {
        return const LoginPage();
      }

      // return Scaffold(
      //   body: StreamBuilder<User?>(
      //     stream: FirebaseAuth.instance.authStateChanges(),
      //     builder: (context, snapshot) {
      //       if (snapshot.hasData) {
      //         try {
      //           // maybe shudhu home page ee gele update hobe,
      //           // shob page ghure back korle, home page ee pathate hobe instead of "/"
      //           User? user = FirebaseAuth.instance.currentUser;
      //           if (user != null) {
      //             FirebaseFirestore.instance
      //                 .collection("UserStatus")
      //                 .doc(user.uid)
      //                 .set({
      //               "isOnline": true,
      //               "isPlaying": false,
      //               "last_online_time": FieldValue.serverTimestamp(),
      //             });
      //           }
      //           return const HomePage();
      //         } catch (e) {
      //           print("error: $e");
      //           return const ErrorPage();
      //         }
      //       } else {
      //         return const LoginPage();
      //       }
      //     },
      //   ),
      // );
    } else {
      print("ConnectivityResult on false");

      return _offlineHandler();
    }
  }

  Widget _offlineHandler() {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: const Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image(
                image: AssetImage('assets/ic_launcher.png'),
                height: 100,
                width: 100,
                // ),
              ),
            ),
            SizedBox(height: 50),
            Flexible(
              child: Text("No Internet",
                  style: TextStyle(
                      fontSize: 30, color: AppConstants.primaryMainColor)),
            ),
            Text("Can't use app without internet"),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

// Utilities

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status $e');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }
}
