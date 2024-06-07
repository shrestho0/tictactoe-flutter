import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tictactoe/utils/Utils.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ///
  ///
  ///
  ///
  ///
  ///

  // User? user = FirebaseAuth.instance.currentUser;
  late String imageUrl;
  File? _image;
  String uploadMessage = "";
  // final _firebaseStorage = FirebaseStorage.instance;
  // final _imagePicker = ImagePicker();

  final displayNameController = TextEditingController();
  final emailEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    displayNameController.text = user?.displayName ?? "";
    emailEditingController.text = user?.email ?? "";

    return Scaffold(
        bottomNavigationBar: commonNavigationBar(
          context: context,
          selectedIndex: 0,
          currentRoute: "/profile",
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            margin: const EdgeInsets.only(top: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // SystemChannels.textInput.invokeMethod('TextInput.hide');
                  },
                  child: ClipOval(
                    child: _image != null
                        ? Image.file(
                            _image!,
                            height: 100,
                            width: 100,
                          )
                        : user?.photoURL != null
                            ? Image.network(
                                user!.photoURL.toString(),
                                height: 100,
                                width: 100,
                              )
                            : const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.black87,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white70,
                                ),
                              ),
                  ),
                ),
                // Center(
                //   child: _image == null
                //       ? Text('No image selected.')
                //       : Image.file(_image!),
                // ),
                appHomeButton(
                    title: "change image",
                    icon: someFreeSpace(height: 1, flexible: false),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    onPressed: () async {
                      // setState(() {
                      // _image = null;
                      // });
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        var imageName = user?.uid.toString();
                        var imageData = image.path.split(".");
                        var imageExt = imageData.last;

                        print(
                            "=========== Image ext ==========\n${imageName} ${imageExt} ${imageData}");

                        var storageRef = FirebaseStorage.instance
                            .ref()
                            .child('/profile_images/$imageName.$imageExt');

                        // if (_image != null) {
                        var uploadTask = storageRef.putFile(File(image.path));

                        setState(() {
                          uploadMessage = "uploading image...";
                        });

                        var downloadUrl =
                            await (await uploadTask).ref.getDownloadURL();

                        // if (downloadUrl) {
                        // print(downloadUrl);

                        try {
                          user?.updatePhotoURL(downloadUrl);
                          setState(() {
                            uploadMessage = "Image uploaded successfully";
                            _image = File(image.path);
                          });
                        } catch (e) {
                          print(
                              "=========== Image Upload/Load/Pick Error ==========");
                          print(e);
                          print(
                              "=========== Image Upload/Load/Pick Error ==========");
                        }
                        // }
                        // }
                      } else {
                        // do nothing
                      }
                      // change image
                    },
                    borderRadius: 10),
                Text(uploadMessage),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      commonTextInputs(
                        theController: displayNameController,
                        labelText: "Display Name",
                      ),
                      commonTextInputs(
                        theController: emailEditingController,
                        enabled: false,
                        labelText: "Email",
                      ),
                    ],
                  ),
                ),
                commonOutlineButton(
                    text: "Save Profile",
                    onPressed: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      try {
                        // dynamic something =
                        user?.updateDisplayName(displayNameController.text);
                        showCustomDialog(
                            context: context,
                            title: "Profile updated!",
                            description: "Profile updated successfully",
                            popText: "close");
                        // print(
                        //     "something: $something ; ${something.runtimeType}");
                      } catch (e) {
                        print(e);
                      }
                      // save the profile
                    })
              ],
            ),
          ),
        ));
  }
}
