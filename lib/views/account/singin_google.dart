import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class SigninGoogle extends StatefulWidget {
  const SigninGoogle({
    super.key,
    required this.onSignIn,
    required this.isLoading,
  });
  // final Function(UserCredential credential) onSignIn;
  final VoidCallback onSignIn;
  final bool isLoading;

  @override
  State<SigninGoogle> createState() => _SigninGoogleState();
}

class _SigninGoogleState extends State<SigninGoogle> {
  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: () async {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        if (widget.isLoading) return;
        widget.onSignIn();
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
              child: widget.isLoading
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
}
