import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/account/singin_apple.dart';
import 'package:workout_notepad_v2/views/account/singin_google.dart';

enum _Provider {
  none,
  google,
  apple;

  String get name {
    switch (this) {
      case _Provider.none:
        return "";
      case _Provider.google:
        return "google";
      case _Provider.apple:
        return "apple";
    }
  }
}

class SingInWith extends StatefulWidget {
  const SingInWith({super.key});

  @override
  State<SingInWith> createState() => _SingInWithState();
}

class _SingInWithState extends State<SingInWith> {
  _Provider _currentProvider = _Provider.none;

  @override
  Widget build(BuildContext context) {
    var dmodel = context.watch<DataModel>();

    return Column(
      children: [
        SigninGoogle(
          onSignIn: () async =>
              _handleProvider(context, dmodel, _Provider.google),
          isLoading: _currentProvider == _Provider.google,
        ),
        if (Platform.isIOS)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: SigninApple(
              onSignIn: () async =>
                  _handleProvider(context, dmodel, _Provider.apple),
              isLoading: _currentProvider == _Provider.apple,
            ),
          ),
      ],
    );
  }

  Future<void> _handleProvider(
    BuildContext context,
    DataModel dmodel,
    _Provider provider,
  ) async {
    try {
      if (_currentProvider != _Provider.none) {
        snackbarStatus(context, "Your account is already loading ...");
        return;
      }

      setState(() {
        _currentProvider = provider;
      });

      logger.debug("authing with oath provider");
      var data = await dmodel.pb!
          .collection('users')
          .authWithOAuth2(provider.name, (url) async {
        final theme = Theme.of(context);
        final mediaQuery = MediaQuery.of(context);
        logger.debug("launching url");
        await launchUrl(
          url,
          customTabsOptions: CustomTabsOptions.partial(
            configuration: PartialCustomTabsConfiguration(
              initialHeight: mediaQuery.size.height * 0.7,
            ),
            colorSchemes: CustomTabsColorSchemes.defaults(
              toolbarColor: theme.colorScheme.surface,
            ),
          ),
          safariVCOptions: SafariViewControllerOptions.pageSheet(
            configuration: const SheetPresentationControllerConfiguration(
              detents: {
                SheetPresentationControllerDetent.large,
                SheetPresentationControllerDetent.medium,
              },
              prefersScrollingExpandsWhenScrolledToEdge: true,
              prefersGrabberVisible: true,
              prefersEdgeAttachedInCompactHeight: true,
            ),
            preferredBarTintColor: theme.colorScheme.surface,
            preferredControlTintColor: theme.colorScheme.onSurface,
            dismissButtonStyle: SafariViewControllerDismissButtonStyle.done,
          ),
        );
      });

      logger.debug(provider.name);
      await dmodel.loginUserPocketbase(
        context,
        userId: data.record.id,
        email: data.meta['email'],
        avatar: data.meta['avatarUrl'],
        displayName: data.meta['username'],
        provider: provider.name,
      );

      return;
    } catch (e, stack) {
      logger.exception(
        e,
        stack,
        message: "Failed to login",
        data: {"provider": provider.name},
      );
      snackbarErr(context,
          "There was an unknown issue. Maybe you know? ${e.toString()}");
    } finally {
      logger.debug("closing tab");
      await closeCustomTabs();
      setState(() {
        _currentProvider = _Provider.none;
      });
    }
  }
}
