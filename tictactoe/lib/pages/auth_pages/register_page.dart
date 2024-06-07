import 'package:flutter/material.dart';
import 'package:tictactoe/services/base_services.dart';
import 'package:tictactoe/utils/Utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //   // Input controllers

  final theControllers = {
    "email": TextEditingController(),
    "displayName": TextEditingController(),
    "password": TextEditingController(),
    "password2": TextEditingController(),
  };

  // final emailInputController = TextEditingController();
  // final passwordInputController = TextEditingController();
  // final password2InputController = TextEditingController();

  bool hasError = false;
  String errorMessage = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    for (var element in theControllers.entries) {
      element.value.dispose();
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    errorMessage = "";
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
              authPageTitle("Signup"),
              someFreeSpace(height: 10.0, flexible: false),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    commonTextInputs(
                      theController: theControllers["email"]!,
                      labelText: "Email",
                      hintText: "Enter Email",
                      onChanged: clearError,
                    ),
                    commonTextInputs(
                      theController: theControllers["displayName"]!,
                      labelText: "Display Name",
                      hintText: "Enter display name",
                      onChanged: clearError,
                    ),
                    commonTextInputs(
                      theController: theControllers["password"]!,
                      labelText: "Password",
                      hintText: "Enter Password",
                      obscureText: true,
                      onChanged: clearError,
                    ),
                    commonTextInputs(
                      theController: theControllers["password2"]!,
                      labelText: "Password",
                      hintText: "Enter Password",
                      obscureText: true,
                      onChanged: clearError,
                    ),
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
                        print("signing up...");
                        // SystemChannels.textInput.invokeMethod('TextInput.hide');
                        unfocusTextInputFields();

                        setState(() {
                          errorMessage = "signing in...";
                        });
                        dynamic something =
                            await BaseServices().signUpWithPassword(
                          email: theControllers["email"]!.text,
                          displayName: theControllers["displayName"]!.text,
                          password: theControllers["password"]!.text,
                          password2: theControllers["password2"]!.text,
                        );
                        if (something[0] == true) {
                          print("Logged in, going back");
                          // Navigator.pop(context);
                          // ignore: use_build_context_synchronously
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false);
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

  void clearError(dynamic _) {
    setState(() {
      hasError = false;
      errorMessage = "";
    });
  }
}
