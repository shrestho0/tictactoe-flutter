import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tictactoe/utils/Constants.dart';

// class Utils {
// }

Widget someFreeSpace(
    {double height = 100, double width = 100, flexible = true}) {
  //

  if (flexible) {
    return Flexible(
      child: SizedBox(height: height, width: height),
    );
  }

  //

  return SizedBox(height: height, width: height);
}

Widget someFreeFlexibleSpace({double height = 100, double width = 100}) {
  return Flexible(
    child: SizedBox(height: height, width: height),
  );
}

AppBar customAppBar(String title) {
  return AppBar(
    backgroundColor: Colors.black87,
    centerTitle: true,
    title: Text(
      title,
      style:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
    ),
  );
}

Container commonOutlineButton({
  required text,
  required void Function()? onPressed,
  Icon? icon,
  Image? image,
  EdgeInsets assetPadding = const EdgeInsets.symmetric(horizontal: 10.0),
  EdgeInsets? padding =
      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
  EdgeInsets? margin = const EdgeInsets.symmetric(horizontal: 0.0),
  double? minHeight = 50.0,
}) {
  return Container(
    margin: margin,
    padding: padding,
    alignment: Alignment.center,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: minHeight != null ? Size.fromHeight(minHeight) : null,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
      ),
      child: (image != null || icon != null)
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: assetPadding,
                  child: image ?? (icon),
                ),
                Text(text),
              ],
            )
          : Text(text),
    ),
  );
}

Text authPageTitle(String title) {
  return Text(
    "` $title `",
    style: const TextStyle(
      backgroundColor: Colors.black87,
      color: Colors.white70,
      fontSize: 30.0,
      fontFamily: "Arcade",
    ),
  );
}

Widget commonTextInputs({
  required TextEditingController theController,
  void Function(String)? onChanged,
  bool obscureText = false,
  String? labelText,
  String? hintText,
  EdgeInsets? padding = const EdgeInsets.symmetric(vertical: 5),
  bool? flex_hobe = false,
  bool? enabled = true,
}) {
  if (flex_hobe == true) {
    return Flexible(
      child: Container(
        padding: padding,
        child: TextField(
          onChanged: onChanged,
          controller: theController,
          obscureText: obscureText,
          enabled: enabled,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: labelText ?? "",
            hintText: hintText ?? "",
          ),
        ),
      ),
    );
  }
  return Container(
    padding: padding,
    child: TextField(
      onChanged: onChanged,
      controller: theController,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText ?? "",
        hintText: hintText ?? "",
      ),
    ),
  );
}

authHeaderRow(
  BuildContext context,
  User? user,
) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      authPageTitle("tictactoe"),
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: ClipOval(
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
          ),
          Text(
            user?.displayName == "" || user?.displayName == null
                ? "display name"
                : user!.displayName.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Text(
          //   user?.displayName != null
          //       ? user!.displayName.toString()
          //       : "display name",
          //   // textAlign: TextAlign.right,
          //   // style: const TextStyle(
          //   //   fontSize: 12,
          //   //   fontWeight: FontWeight.w500,
          //   // ),
          // ),
        ],
      ),
    ],
  );
}

// Decorations
BoxDecoration textInsideBox({double radius = 5.0}) {
  return BoxDecoration(
    border: Border.all(),
    borderRadius: BorderRadius.circular(radius),
  );
}

AppBar commonUnProtectedAppbar({
  required String title,
  required BuildContext context,
  double? fontSize = 25.0,
  double? imageSize = 30.0,
  bool? leading = false,
}) {
  return AppBar(
    backgroundColor: Colors.white,
    automaticallyImplyLeading: leading!,
    title: Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            child: Image(
              image: const AssetImage("assets/ic_launcher.png"),
              height: imageSize?.toDouble(),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontFamily: "RetroGaming",
              fontSize: fontSize?.toDouble(),
            ),
          ),
        ],
      ),
    ),
  );
}

AppBar commonProtectedAppbar({
  required String title,
  required BuildContext context,
  User? user,
  bool leading = true,
}) {
  return AppBar(
    backgroundColor: Colors.white,
    automaticallyImplyLeading: false,
    title: title != ""
        ? authPageTitle(
            title,
          )
        : Text(""),
    centerTitle: true,
    // leading: GestureDetector(
    //   child: Container(
    //     alignment: Alignment.center,
    //     child: Image(
    //       image: AssetImage("assets/ic_launcher.png"),
    //       height: 30.0,
    //     ),
    //   ),
    // ),
    leading: leading
        ? IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 40,
              color: Colors.black87,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        : null,
  );
}

/// Alerts

Future<void> showCustomDialog(
    {required BuildContext context,
    required String title,
    required String popText,
    String description = ""}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(description),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(popText),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget appHomeButton({
  required String title,
  required Widget icon,
  double? fontSize = 12.0,
  void Function()? onPressed,
  EdgeInsets? padding =
      const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
  EdgeInsets? margin =
      const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
  double? borderRadius = 0.0,
  String? fontFamily = "RetroGaming",
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: AppConstants.primaryMainColor,
        borderRadius: BorderRadius.circular(borderRadius!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: icon,
          ),
          Text(
            style: TextStyle(
              color: AppConstants.primaryTextColor,
              fontFamily: fontFamily,
              fontSize: fontSize,
            ),
            title,
          ),
        ],
      ),
    ),
  );
}

Widget appHomeNicherButton({
  required String title,
  required Widget icon,
  double? fontSize = 12.0,
  void Function()? onPressed,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
      // margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
      decoration: BoxDecoration(
        color: AppConstants.primaryMainColor,
        // border: Border.all(
        //   color: AppConstants.primaryTextColor,
        // ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
          //   child: icon,
          // ),
          icon,
          Text(
            style: const TextStyle(
              color: AppConstants.primaryTextColor,
              fontFamily: "RetroGaming",
              fontSize: 12.0,
            ),
            title,
          ),
        ],
      ),
    ),
  );
}

/// Bottom Navigation Bar

BottomNavigationBar commonNavigationBar({
  required BuildContext context,
  required String currentRoute,
  int? selectedIndex = 1,
}) {
  List<Map<String, dynamic>> bottomNavigationStuff = [
    {
      "icon": Icons.person,
      "label": "Profile",
      "route": "/profile",
    },
    {
      "icon": Icons.home,
      "label": "Home",
      "route": "/",
    },
    {
      "icon": Icons.logout,
      "label": "Logout",
      "route": "/logout",
    },
  ];

  return BottomNavigationBar(
    selectedFontSize: 12,
    unselectedFontSize: 10,
    currentIndex: selectedIndex!,
    onTap: (value) {
      if (value == 0 && currentRoute != "/profile") {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/profile",
          (route) => false,
        );
      } else if (value == 1 && currentRoute != "/") {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/",
          (_) => false,
        );
      } else if (value == 2) {
        FirebaseAuth.instance.signOut();
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    },
    items: bottomNavigationStuff
        .map(
          (e) => BottomNavigationBarItem(
            icon: Icon(e["icon"]),
            label: e["label"],
          ),
        )
        .toList(),
  );
}

/// Random stuff

String randomString(int len) {
  const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
  final _rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      len, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

/// Utils utils
void unfocusTextInputFields() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

//
