import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  void initState() {
    super.initState();
    _test();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Future<void> _test() async {
    try {
      final pb = PocketBase('https://pocketbase.sapphirenw.com');
      print("successfully loaded pocketbase");

      // can use a listener to observe changes in the auth provider
      pb.authStore.onChange.listen((e) {
        print("AUTH CHANGE");
        print(e);
        print(e.token);
        print(e.model);
      });

      // var authMethods = await pb.collection('users').listAuthMethods();
      // print(authMethods);

      // #### EMAIL AND PASSWORD

      await pb.collection('users').create(body: {
        "email": "test@jakelanders.com",
        "password": "Aloha1234!",
        "passwordConfirm": "Aloha1234!",
      });

      // await pb
      //     .collection('users')
      //     .authWithPassword('test@jakelanders.com', "Aloha1234!");

      // #### APPLE AUTH

      // final data = await pb.collection('users').authWithOAuth2(
      //   'apple',
      //   (url) async {
      //     await launchUrl(url);
      //   },
      // );

      // print(data.meta);
      // {id: 001417.439f123c67964ca5b2278de6f3591b4f.0404, name: , username: , email: chknjyy7p2@privaterelay.appleid.com, avatarUrl: , accessToken: a79c71d5cc1e14a4cac04e0d355f4c89c.0.rrurx.fi5BCJhE6BNL2Fw8o2Q6rw, refreshToken: rb130f33e7ff840339ca58683e151b146.0.rrurx.mVLEZA7vk9cHIlFsJI_ZJA, expiry: 2024-09-05 18:03:00.725Z, rawUser: {at_hash: EE_DNF30svsok5CCiJ6_Nw, aud: com.sapphirenw.pocketbase-serviceid, auth_time: 1725555779, email: chknjyy7p2@privaterelay.appleid.com, email_verified: true, exp: 1725642180, iat: 1725555780, is_private_email: true, iss: https://appleid.apple.com, nonce_supported: true, sub: 001417.439f123c67964ca5b2278de6f3591b4f.0404}, isNew: false}

      // #### GOOGLE AUTH
      final data = await pb.collection('users').authWithOAuth2(
        'google',
        (url) async {
          await launchUrl(url);
        },
      );

      print(data.meta);

      print(pb.authStore.isValid);
      print(pb.authStore.token);
      print(pb.authStore.model);
    } catch (e, stack) {
      print(e);
      print(stack);
    }
  }
}
