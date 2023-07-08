import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/views/account/root.dart';
import 'package:workout_notepad_v2/views/account/singin_apple.dart';

class AccountAuthButtons extends StatelessWidget {
  const AccountAuthButtons({
    super.key,
    required this.onSignIn,
  });
  final Function(UserCredential credential) onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        SigninGoogle(onSignIn: onSignIn),
        if (Platform.isIOS)
          Column(
            children: [
              const SizedBox(height: 8),
              SigninApple(onSignIn: onSignIn),
            ],
          ),
      ],
    );
  }
}
