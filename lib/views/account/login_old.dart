// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/account/template.dart';

class LoginOld extends StatefulWidget {
  const LoginOld({super.key});

  @override
  State<LoginOld> createState() => _LoginOldState();
}

class _LoginOldState extends State<LoginOld> {
  final _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    // The OAuth client id of your app. This is required.
    clientId:
        "993769836789-o52cpd11lc4kkccfhqtgftmut6s7ph34.apps.googleusercontent.com",
    // "993769836789-e614gf7untnrc9dljh3vo1djamch2m0c.apps.googleusercontent.com",
    // If you need to authenticate to a backend server, specify its OAuth client. This is optional.
    serverClientId:
        "993769836789-e614gf7untnrc9dljh3vo1djamch2m0c.apps.googleusercontent.com",
  );

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return AccountTemplate(
      title: "DEV - Old Login Flow",
      description:
          "Only login with this method if you have an old account AND are experiencing data loss.",
      onEmailCallback: (email, pass) async {
        print("email/pass login flow old");
        try {
          final credential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: pass,
          );
          if (credential.user == null) {
            return "There was an issue getting your credentials";
          }

          await NewrelicMobile.instance.recordCustomEvent(
            "WN_Metric",
            eventName: "login_email",
            eventAttributes: {"userId": credential.user?.uid},
          );

          await dmodel.loginUser(context, credential);
          return "";
        } on FirebaseAuthException catch (e) {
          NewrelicMobile.instance.recordError(
            e,
            StackTrace.current,
            attributes: {"err_code": "email_login"},
          );
          if (e.code == 'user-not-found' || e.code == 'wrong-password') {
            return "Your username or password was incorrect.";
          } else {
            return "There was an unknown error: ${e.code}";
          }
        } catch (e, stack) {
          print(stack);
          snackbarErr(context, "There was an unknown error.");
          return "There was an unknown error.";
        }
      },
      onAppleCallback: () async {
        print("apple login old flow");
        try {
          final appleProvider = AppleAuthProvider();
          appleProvider.addScope("email");
          var credential =
              await FirebaseAuth.instance.signInWithProvider(appleProvider);
          if (credential.user == null) {
            return "There was an error signing in with apple.";
          }
          await NewrelicMobile.instance.recordCustomEvent(
            "WN_Metric",
            eventName: "login_apple",
            eventAttributes: {"userId": credential.user?.uid},
          );

          // login with the credential provider
          await dmodel.loginUser(context, credential);
          return "";
        } catch (error, stack) {
          NewrelicMobile.instance.recordError(
            error,
            stack,
            attributes: {"err_code": "login_apple"},
          );
          return "There was an unknown error.";
        }
      },
      onGoogleCallback: () async {
        print("google login old flow");
        try {
          var googleUser = await _googleSignIn.signIn();
          if (googleUser == null) {
            return "Unable to sign in.";
          }

          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final oauthCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          var credential =
              await FirebaseAuth.instance.signInWithCredential(oauthCredential);
          await NewrelicMobile.instance.recordCustomEvent(
            "WN_Metric",
            eventName: "login_google",
            eventAttributes: {"userId": credential.user?.uid},
          );

          // continue login flow
          await dmodel.loginUser(context, credential);
          return "";
        } catch (error, stack) {
          NewrelicMobile.instance.recordError(
            error,
            stack,
            attributes: {"err_code": "login_google"},
          );
          return "There was an unknown error.";
        }
      },
      onForgotPass: (email) async {
        print("forgot pass on old flow");
        var response = "";

        await showAlert(
          context: context,
          title: "Send Reset Link?",
          body: const Text(
              "Do you want to send a reset link to the email specified?"),
          cancelText: "Cancel",
          onCancel: () {},
          submitText: "Send Email",
          onSubmit: () async {
            if (email.isEmpty) {
              response = "Your email is invalid.";
              return;
            }
            try {
              print("Sending reset email");
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: email.toLowerCase(),
              );
              snackbarStatus(context,
                  "Success. Check your inbox for instructions on how to reset your password.");
            } on FirebaseAuthException catch (e) {
              print(e.message);
              if (e.code == "auth/invalid-email") {
                response = "The email was invalid. Do you have an account?";
              } else {
                response = "There was an unknown error.";
              }
            } catch (e, stack) {
              print(e);
              print(stack);
              response = "There was an unknown error.";
            }
          },
        );

        return response;
      },
    );
  }
}
