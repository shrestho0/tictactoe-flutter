import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tictactoe/services/base_services.dart';
import 'package:tictactoe/utils/Utils.dart';

class LoginWithPassword extends StatefulWidget {
  const LoginWithPassword({super.key});

  @override
  State<LoginWithPassword> createState() => _LoginWithPasswordState();
}

class _LoginWithPasswordState extends State<LoginWithPassword> {
  //   // Input controllers
  final emailInputController = TextEditingController();

  final passwordInputController = TextEditingController();

  bool hasError = false;
  String errorMessage = "";

  @override
  void dispose() {
    emailInputController.dispose();
    passwordInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // padding: const EdgeInsets.only(top: 200),
        // height: MediaQuery.of(context).size.height,
        // width: MediaQuery.of(context).size.width,
        child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Flexible(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Image(
                    image: AssetImage('assets/ic_launcher.png'),
                    height: 100,
                    width: 100,
                  ),
                ),
              ),
// page title
              authPageTitle("Login"),
              someFreeSpace(height: 10.0, flexible: false),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    commonTextInputs(
                      theController: emailInputController,
                      labelText: "Email",
                      hintText: "Enter Email",
                    ),
                    commonTextInputs(
                        theController: passwordInputController,
                        labelText: "Password",
                        hintText: "Enter Password",
                        obscureText: true),
                    GestureDetector(
                      onTap: () => {
                        Navigator.pushNamed(context, "/forgot-password"),
                      },
                      child: Container(
                        alignment: Alignment.topRight,
                        child: const Text("Forgot password?"),
                      ),
                    ),

                    /// Error message
                    Text(errorMessage),

                    /// Buttons
                    someFreeSpace(height: 10, flexible: false),
                    commonOutlineButton(
                      text: "Sign in",
                      onPressed: () async {
                        print("logging in");
                        SystemChannels.textInput.invokeMethod('TextInput.hide');

                        setState(() {
                          errorMessage = "logging in...";
                        });
                        dynamic something = await BaseServices()
                            .signInWithPassword(
                                email: emailInputController.text,
                                password: passwordInputController.text);
                        if (something[0] == true) {
                          print("Logged in, going back");
                          Navigator.popAndPushNamed(context, "/home");
                          // Navigator.pop(context);
                        } else {
                          setState(() {
                            hasError = true;
                            errorMessage = something[1];
                          });
                          print(
                              "Error here!! something went wrong: ${something[1]}");
                        }
                      },
                    ),
                    someFreeSpace(height: 10, flexible: false),
                    commonOutlineButton(
                      text: "Back to other options",
                      onPressed: () => {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false)
                      },
                      icon: Icon(Icons.chevron_left),
                    ),
                  ],
                ),
              )
            ]),
      ),
    );
  }
}
