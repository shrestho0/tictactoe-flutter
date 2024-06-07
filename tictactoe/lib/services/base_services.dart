import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class BaseServices {
  // Google Sign in
  Future<bool> signInWithGoogle() async {
    // begin signin process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // auth data
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // create cred
    final cred = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    try {
      UserCredential x = await FirebaseAuth.instance.signInWithCredential(cred);
      print("services/auth_services:signInWithGoogle: success $x");
      return true;
    } catch (e) {
      print("services/auth_services:signInWithGoogle: ${e.toString()}");

      return false;
    }
  }

  /// signInWithPassword
  /// returns [bool success. String message]
  signInWithPassword({required String email, required password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("services/auth_services:signInWithPassword: success");
      return [true, ""];
    } on FirebaseAuthException catch (e) {
      print("services/auth_services:signInWithPassword: ${e.toString()}");
      if (e.code == 'user-not-found') {
        return [false, "User not found."];
      } else if (e.code == 'wrong-password') {
        return [false, "Wrong password provided for that user."];
      } else if (e.code == "channel-error") {
        return [false, "Channel error"];
      } else {
        return [false, e.code];
      }
    } catch (e) {
      print("services/auth_services:signInWithPassword: ${e.toString()}");
      return [false, "Unknown Error. Could not catch"];

      // fuck it
    }
  }

  ///

  signUpWithPassword({
    required String email,
    required String password,
    required String password2,
    required String displayName,
  }) async {
    // Ber kore deya hocche
    if (password != password2) {
      return [false, "Both password must be same"];
    }

    print("account khola hobe");
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Updates Display Name after registratio
      User? user = FirebaseAuth.instance.currentUser;
      user?.updatePhotoURL(
          "https://www.google.com/images/branding/googlelogo/1x/googlelogo_light_color_272x92dp.png");
      user?.updateDisplayName(displayName);

      print("services/auth_services:signInWithPassword: success");
      return [true, ""];
    } on FirebaseAuthException catch (e) {
      print("services/auth_services:signInWithPassword: ${e.toString()}");

      return [false, e.code];
    } catch (e) {
      print("services/auth_services:signInWithPassword: ${e.toString()}");
      return [false, "Unknown Error. Could not catch"];

      // fuck it
    }
  }

  void signOut() {
    // print("user signing out ${FirebaseAuth.instance.currentUser.email}");
    FirebaseAuth.instance.signOut();
    //
  }
}
