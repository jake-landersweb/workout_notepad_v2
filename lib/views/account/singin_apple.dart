import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class SigninApple extends StatefulWidget {
  const SigninApple({
    super.key,
    required this.onSignIn,
    required this.isLoading,
  });
  final AsyncCallback onSignIn;
  final bool isLoading;

  @override
  State<SigninApple> createState() => _SigninAppleState();
}

class _SigninAppleState extends State<SigninApple> {
  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: () async {
        if (widget.isLoading) return;
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        await widget.onSignIn();
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
              widget.isLoading
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

  // Future<void> _signIn() async {}
}
