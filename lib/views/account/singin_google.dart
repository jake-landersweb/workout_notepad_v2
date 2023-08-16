import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class SigninGoogle extends StatefulWidget {
  const SigninGoogle({
    super.key,
    required this.onSignIn,
  });
  final Function(UserCredential credential) onSignIn;

  @override
  State<SigninGoogle> createState() => _SigninGoogleState();
}

class _SigninGoogleState extends State<SigninGoogle> {
  bool _isLoading = false;

  final _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    // The OAuth client id of your app. This is required.
    clientId:
        "993769836789-o52cpd11lc4kkccfhqtgftmut6s7ph34.apps.googleusercontent.com",
    // "993769836789-e614gf7untnrc9dljh3vo1djamch2m0c.apps.googleusercontent.com",
    // If you need to authenticate to a backend server, specify its OAuth client. This is optional.
    // serverClientId: ...,
  );

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Clickable(
      onTap: () async {
        if (_isLoading) {
          return;
        }
        setState(() {
          _isLoading = true;
        });
        await _signIn();
        setState(() {
          _isLoading = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 45,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/images/google.png"),
            ),
            Center(
              child: _isLoading || dmodel.loadStatus == LoadStatus.init
                  ? LoadingIndicator(color: AppColors.subtext(context))
                  : Text(
                      "Sign in with Google",
                      style: TextStyle(
                        color: AppColors.subtext(context),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    try {
      if (Platform.isAndroid) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('https://www.googleapis.com/auth/email');
        var credential =
            await FirebaseAuth.instance.signInWithProvider(googleProvider);
        if (credential.user == null) {
          print("There was an error signing in with google");
          return;
        }
        await NewrelicMobile.instance.recordCustomEvent(
          "WN_Metric",
          eventName: "login_google",
          eventAttributes: {"userId": credential.user?.uid},
        );
        widget.onSignIn(credential);
      } else {
        var googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          print("Unable to sign in");
          return;
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
        widget.onSignIn(credential);
      }
    } catch (error) {
      NewrelicMobile.instance.recordError(
        error,
        StackTrace.current,
        attributes: {"err_code": "login_google"},
      );
      log(error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[300],
          content: const Text("There was an unknown error."),
        ),
      );
    }
  }
}
