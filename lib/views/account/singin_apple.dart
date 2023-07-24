import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class SigninApple extends StatefulWidget {
  const SigninApple({
    super.key,
    required this.onSignIn,
  });
  final Function(UserCredential credential) onSignIn;

  @override
  State<SigninApple> createState() => _SigninAppleState();
}

class _SigninAppleState extends State<SigninApple> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 45,
        width: double.infinity,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/images/apple.png"),
              ),
              _isLoading
                  ? LoadingIndicator(color: AppColors.subtext(context))
                  : const Text(
                      "Sign in with Apple",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    try {
      final appleProvider = AppleAuthProvider();
      var credential =
          await FirebaseAuth.instance.signInWithProvider(appleProvider);
      if (credential.user == null) {
        print("There was an error signing in with apple");

        return;
      }
      widget.onSignIn(credential);
    } catch (error) {
      NewrelicMobile.instance.recordError(
        error,
        StackTrace.current,
        attributes: {"err_code": "signin_apple"},
      );
      print(error);
    }
  }
}
