// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/views/account/template.dart';
import 'package:workout_notepad_v2/logger.dart';

class LoginNew extends StatefulWidget {
  const LoginNew({super.key});

  @override
  State<LoginNew> createState() => _LoginNewState();
}

class _LoginNewState extends State<LoginNew> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return AccountTemplate(
      title: "Welcome Back!",
      description: "Login to resume where you left off last time.",
      emailPassButtonTitle: "Login",
      onEmailCallback: (email, pass) async {
        print("login email callback with new");
        try {
          if (dmodel.pb == null) {
            throw "Initialization failure";
          }

          // create the user
          await dmodel.pb!.collection('users').create(body: {
            "email": email,
            "password": pass,
            "passwordConfirm": pass,
          });

          // login as the user
          final record = await dmodel.pb!
              .collection('users')
              .authWithPassword(email, pass);

          print(record);

          await dmodel.loginUserPocketbase(
            context,
            userId: record.record.id,
            email: email,
            provider: "email/pass",
          );

          return "";
        } on ClientException catch (e, stack) {
          logger.exception(e, stack);
          print(e);
          if (e.response['data'] != null) {
            if (e.response['data']['email'] != null) {
              if (e.response['data']['email']['code'] != null) {
                switch (e.response['data']['email']['code']) {
                  case "validation_invalid_email":
                    return "Error, do you already have an account?";
                  case "validation_is_email":
                    return "Your email is malformed.";
                }
              }
              return "Unknown error with your email.";
            }
            if (e.response['data']['password'] != null) {
              if (e.response['data']['password']['code'] != null) {
                switch (e.response['data']['password']['code']) {
                  case "validation_length_out_of_range":
                    return e.response['data']['password']['message'] ??
                        "Invalid password.";
                }
              }
              return "Unkown error with your password";
            }
            if (e.response['data']['passwordConfirm'] != null) {
              if (e.response['data']['passwordConfirm']['code'] != null) {
                switch (e.response['data']['password']['code']) {
                  case "validation_values_mismatch":
                    return "Your password does not match";
                }
              }
              return "Unkown error with your password";
            }
          }
          return "There was an unknown error";
        }
      },
      onAppleCallback: () async {
        print("apple callback with new");
        return _handleProvider(dmodel, "apple");
      },
      onGoogleCallback: () async {
        print("google callback with new");
        return _handleProvider(dmodel, "google");
      },
    );
  }

  Future<String> _handleProvider(
    DataModel dmodel,
    String provider,
  ) async {
    try {
      final data = await dmodel.pb!.collection('users').authWithOAuth2(
        provider,
        (url) async {
          await launchUrl(url);
        },
      );

      await dmodel.loginUserPocketbase(
        context,
        userId: data.record.id,
        email: data.meta['email'],
        avatar: data.meta['avatarUrl'],
        displayName: data.meta['username'],
        provider: provider,
      );

      return "";
    } catch (e, stack) {
      logger.exception(e, stack);
      return "There was an unknown error";
    }
  }
}
