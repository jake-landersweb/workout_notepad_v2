import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/views/account/template.dart';
import 'package:workout_notepad_v2/logger.dart';

class ReAuth extends StatefulWidget {
  const ReAuth({super.key});

  @override
  State<ReAuth> createState() => _ReAuthState();
}

class _ReAuthState extends State<ReAuth> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return AccountTemplate(
      title: "Sorry for the Inconvenience",
      description:
          "We are performing updates, so we ask you re-athenticate your account.",
      emailPassButtonTitle: "Submit",
      onEmailCallback: (email, pass) async {
        print("email callback with new");
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

          await _updateRemote(dmodel, record.record.id, email);
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

      await _updateRemote(dmodel, data.record.id, data.meta['email']);
      return "";
    } catch (e, stack) {
      print(e);
      print(stack);
      return "There was an unknown error";
    }
  }

  Future<bool> _updateRemote(DataModel dmodel, String id, String email) async {
    var response = await dmodel.purchaseClient.put(
      "/users/${dmodel.user!.userId}",
      {},
      jsonEncode({"newUserId": id, "email": email}),
    );
    if (response.statusCode != 200) {
      print(response.body);
      return false;
    }
    setState(() {
      dmodel.user!.newUserId = id;
    });
    return true;
  }
}
