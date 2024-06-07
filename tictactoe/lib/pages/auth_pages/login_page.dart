import 'package:flutter/material.dart';
import 'package:tictactoe/services/base_services.dart';
import 'package:tictactoe/utils/Constants.dart';
import 'package:tictactoe/utils/Utils.dart';

enum PreLoginStates { Nothing, AwaitLogin, Loading, Error }

enum PreLoginTypes { Nothing, EmailLogin, GoogleLogin }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  PreLoginStates preLoginState = PreLoginStates.Nothing;
  PreLoginTypes preLoginTypes = PreLoginTypes.Nothing;

  @override
  Widget build(BuildContext context) {
    preLoginState = PreLoginStates.Nothing;
    preLoginTypes = PreLoginTypes.Nothing;

    // return Scaffold(
    //   body: Center(
    //       child: commonOutlineButton(
    //           text: "Back to other options",
    //           onPressed: backToOtherOptionsCallback,
    //           icon: Icon(Icons.home))),
    // );

    return Scaffold(
      // appBar: AppBar(backgroundColor: Colors.white),
      body: Container(
        padding: const EdgeInsets.only(bottom: 180),
        child: Flex(
          mainAxisSize: MainAxisSize.max,
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            someFreeSpace(height: 30),
            const Flexible(
              // flex: 1,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Image(
                  image: AssetImage('assets/ic_launcher.png'),
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            const Text(
              "tictactoe",
              style: TextStyle(
                backgroundColor: Colors.black87,
                color: Colors.white54,
                fontSize: 30,
              ),
            ),
            someFreeSpace(height: 10),
            const Text(
              "Online `tictactoe` game for cse489 project",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontFamily: "IBMPlexMono",
              ),
            ),
            someFreeSpace(height: 60, flexible: true),
            // The Buttons
            // make them a bit better, like the previous plan

            // show if awaitLogin and type of Email Login

            // Buttons

            // Buttons
            // commonOutlineButton(
            //   text: "Already an user?",

            //   icon: const Icon(Icons.login_rounded),
            // ),
            appHomeButton(
              title: "Already an user?",
              icon: const Icon(Icons.login_rounded),
              onPressed: () {
                Navigator.pushNamed(context, "/login");
              },
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              borderRadius: 25,
              // fontFamily: "IBMPlexMono",
            ),

            appHomeButton(
              title: "Create an account.",
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, "/register");
              },
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              borderRadius: 25,
              // fontFamily: "IBMPlexMono",
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                " or ",
                style: TextStyle(fontFamily: "Kongtext"),
              ),
            ),
            appHomeButton(
              title: "Login/Register with Google",
              icon: const Image(
                image: AssetImage('assets/google_icon.png'),
                height: 20,
                width: 20,
              ),
              onPressed: () async {
                Future<bool> status = BaseServices().signInWithGoogle();

                if (await status) {
                  print("user logged in successfully");
                  AppConstants.backToHome(context);
                  // Navigator.pushNamed(context, "/home");
                } else {
                  print("error");
                }
              },
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              borderRadius: 25,
              // fontFamily: "RetroGaming",
              fontSize: 10,
            ),
          ],
        ),
      ),
    );
  }

  // // callbacks and methods
  // void backToOtherOptionsCallback() {
  //   // do nothing
  //   print("Back to tother options");
  // }

  // @override
  // void activate() {
  //   // TODO: implement activate
  //   print("activate");
  //   super.activate();
  // }

  // @override
  // void deactivate() {
  //   // TODO: implement deactivate
  //   print("deactivate");
  //   super.deactivate();
  // }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   print("didChangeDependencies");

  //   super.didChangeDependencies();
  // }
}







// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }



// class _LoginPageState extends State<LoginPage> {
//   // Input controllers
//   final emailInputController = TextEditingController();

//   final passwordInputController = TextEditingController();

//   bool showEmailPasswordInput = false;

//   PreLoginStates preLoginState = PreLoginStates.Nothing;
//   PreLoginTypes preLoginTypes = PreLoginTypes.Nothing;

//   String errorMessage = "";
//   @override
//   void dispose() {
//     // TODO: implement dispose

//     preLoginState = PreLoginStates.Nothing;
//     preLoginTypes = PreLoginTypes.Nothing;

//     super.dispose();
//   }

//   void setLoginError(String msg) {
//     preLoginState = PreLoginStates.Error;
//     setState(() {
//       errorMessage = msg;
//     });
//   }

//   void handleSignIn({bool google = false}) async {
//     setState(() {
//       preLoginState = PreLoginStates.Loading;
//       preLoginTypes =
//           google ? PreLoginTypes.GoogleLogin : PreLoginTypes.EmailLogin;
//       errorMessage = "";
//     });

//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailInputController.text,
//         password: passwordInputController.text,
//       );
//       setState(() {
//         preLoginState = PreLoginStates.Nothing;
//         errorMessage = "";
//       });
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         setLoginError("User not found.");
//       } else if (e.code == 'wrong-password') {
//         setLoginError("Wrong password");
//       } else if (e.code == "channel-error") {
//         setLoginError("channel-error");
//       } else {
//         setLoginError(e.code);
//       }
//     } catch (e) {
//       print("error catch korte parini");
//       // fuck it
//     }
//     // Navigator.pop(context);

//     // no dialogue
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(backgroundColor: Colors.white),
//       body: Flex(
//         direction: Axis.vertical,
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // TODO: COMMENT after debugging
//           Text("${preLoginState} ${preLoginTypes}"),
//           // TODO: UNCOMMENT after debugging
//           const Text(
//             "`tictactoe`",
//             style: TextStyle(
//               fontSize: 30,
//               fontFamily: "Arcade",
//             ),
//           ),
//           const Text(
//             "Online `tictactoe` game for cse470 project",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 12),
//           ),
//           const Flexible(
//             flex: 1,
//             child: Padding(
//               padding: EdgeInsets.all(5.0),
//               child: Image(
//                 image: AssetImage('assets/ic_launcher.png'),
//                 height: 100,
//                 width: 100,
//               ),
//             ),
//           ),
//           someFreeSpace(height: 20),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             child: !(preLoginState == PreLoginStates.AwaitLogin &&
//                     preLoginTypes == PreLoginTypes.EmailLogin)
//                 ? null
//                 : Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 5),
//                         child: TextField(
//                           controller: emailInputController,
//                           decoration: const InputDecoration(
//                             border: OutlineInputBorder(),
//                             labelText: 'Email',
//                             hintText: 'Enter Email',
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 5),
//                         child: TextField(
//                           controller: passwordInputController,
//                           decoration: const InputDecoration(
//                             border: OutlineInputBorder(),
//                             labelText: 'Password',
//                             hintText: 'Enter Password',
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () =>
//                             {Navigator.pushNamed(context, "/forgot-password")},
//                         child: Container(
//                           alignment: Alignment.topRight,
//                           child: const Text("Forgot password?"),
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//             child: Column(
//               children: [
//                 // Container(
//                 //   padding: const EdgeInsets.symmetric(vertical: 10),
//                 //   child: OutlinedButton(
//                 //     onPressed: handleSignIn,
//                 //     style: OutlinedButton.styleFrom(
//                 //       minimumSize: const Size.fromHeight(50),
//                 //       backgroundColor: Colors.black87,
//                 //       foregroundColor: Colors.white,
//                 //       shape: const RoundedRectangleBorder(
//                 //           borderRadius: BorderRadius.all(
//                 //         Radius.circular(5),
//                 //       )),
//                 //     ),
//                 //     child: const Text("Login in with email"),
//                 //   ),
//                 // ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(vertical: 5),
//                   child: OutlinedButton(
//                     onPressed: () {
//                       setState(() {
//                         if (preLoginState == PreLoginStates.Nothing &&
//                             preLoginTypes == PreLoginTypes.Nothing) {
//                           setState(() {
//                             preLoginTypes = PreLoginTypes.EmailLogin;
//                             preLoginState = PreLoginStates.AwaitLogin;
//                           });
//                         } else if (preLoginState == PreLoginStates.AwaitLogin &&
//                             preLoginTypes == PreLoginTypes.EmailLogin) {
//                           handleSignIn();
//                         }
//                       });
//                       // if (showEmailPasswordInput == true) {
//                       //   handleSignIn();
//                       // } else {
//                       //   setState(() {
//                       //     showEmailPasswordInput = true;
//                       //   });
//                       // }
//                     },
//                     style: OutlinedButton.styleFrom(
//                       minimumSize: const Size.fromHeight(50),
//                       backgroundColor: Colors.black87,
//                       foregroundColor: Colors.white,
//                       shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(5),
//                         ),
//                       ),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Image(
//                         //   image: AssetImage('assets/google_icon.png'),
//                         //   height: 20,
//                         //   width: 20,
//                         // ),
//                         Icon(Icons.login),
//                         (preLoginState == PreLoginStates.Loading)
//                             ? Text(" Signing in... ")
//                             : Text("  Login with email  "),
//                       ],
//                     ),
//                   ),
//                 ),
//                 !(preLoginState == PreLoginStates.AwaitLogin)
//                     ? someFreeSpace(height: 2)
//                     : Container(
//                         padding: const EdgeInsets.symmetric(vertical: 5),
//                         child: OutlinedButton(
//                           onPressed: () {
//                             setState(() {
//                               preLoginState = PreLoginStates.Nothing;
//                               preLoginTypes = PreLoginTypes.Nothing;
//                             });
//                           },
//                           style: OutlinedButton.styleFrom(
//                             minimumSize: const Size.fromHeight(50),
//                             backgroundColor: Colors.black87,
//                             foregroundColor: Colors.white,
//                             shape: const RoundedRectangleBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(5),
//                               ),
//                             ),
//                           ),
//                           child: const Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               // Image(
//                               //   image: AssetImage('assets/google_icon.png'),
//                               //   height: 20,
//                               //   width: 20,
//                               // ),
//                               Icon(Icons.arrow_back),
//                               Text(" Back to other options "),
//                             ],
//                           ),
//                         ),
//                       ),
//                 !(preLoginTypes == PreLoginTypes.Nothing)
//                     ? someFreeSpace(height: 2)
//                     : Container(
//                         padding: const EdgeInsets.symmetric(vertical: 5),
//                         child: OutlinedButton(
//                           onPressed: () =>
//                               Navigator.pushNamed(context, "/register"),
//                           style: OutlinedButton.styleFrom(
//                             minimumSize: const Size.fromHeight(50),
//                             backgroundColor: Colors.black87,
//                             foregroundColor: Colors.white,
//                             shape: const RoundedRectangleBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(5),
//                               ),
//                             ),
//                           ),
//                           child: const Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               // Image(
//                               //   image: AssetImage('assets/google_icon.png'),
//                               //   height: 20,
//                               //   width: 20,
//                               // ),
//                               Icon(Icons.person_add),
//                               Text(" Register with email "),
//                             ],
//                           ),
//                         ),
//                       ),
//                 // Container(
//                 //   padding: const EdgeInsets.symmetric(vertical: 5),
//                 //   child: OutlinedButton(
//                 //     onPressed: () => Navigator.pushNamed(context, "/register"),
//                 //     style: OutlinedButton.styleFrom(
//                 //       minimumSize: const Size.fromHeight(50),
//                 //       backgroundColor: Colors.black87,
//                 //       foregroundColor: Colors.white,
//                 //       shape: const RoundedRectangleBorder(
//                 //           borderRadius: BorderRadius.all(
//                 //         Radius.circular(5),
//                 //       )),
//                 //     ),
//                 //     child: const Text("Sign Up with email"),
//                 //   ),
//                 // ),
//                 ////
//                 (preLoginState == PreLoginStates.Nothing ||
//                         preLoginTypes == PreLoginTypes.GoogleLogin)
//                     ? const Text("==== or ====")
//                     : someFreeSpace(height: 2),
//                 (preLoginState == PreLoginStates.Nothing ||
//                         preLoginTypes == PreLoginTypes.GoogleLogin)
//                     ? Container(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: OutlinedButton(
//                           onPressed: () => handleSignIn(google: true),
//                           style: OutlinedButton.styleFrom(
//                             minimumSize: const Size.fromHeight(50),
//                             backgroundColor: Colors.black87,
//                             foregroundColor: Colors.white,
//                             shape: const RoundedRectangleBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(5),
//                               ),
//                             ),
//                           ),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Image(
//                                 image: AssetImage('assets/google_icon.png'),
//                                 height: 20,
//                                 width: 20,
//                               ),
//                               (preLoginState == PreLoginStates.Loading)
//                                   ? const Text(" Signing in... ")
//                                   : const Text(" Authenticate With Google"),
//                             ],
//                           ),
//                         ),
//                       )
//                     : someFreeSpace(height: 2)
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
