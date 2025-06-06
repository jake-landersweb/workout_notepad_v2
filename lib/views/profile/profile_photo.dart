import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/loading_indicator.dart';
import 'package:workout_notepad_v2/data/query_model.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/model/internet_provider.dart';

class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({
    super.key,
    required this.user,
    this.size = 120,
  });
  final User user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Align(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    var internetModel = Provider.of<InternetProvider>(context);

    // check for internet access
    if (!internetModel.hasInternet()) {
      return _offline(context);
    }

    try {
      // attempt to stream the data from the internet
      return StreamBuilder(
        stream: context
            .watch<QueryModel>()
            .getProfilePhoto(user.userId, user.imgUrl),
        builder: (context, snapshot) {
          // check for the error state
          if (snapshot.hasError) {
            return _offline(context);
          }

          // check for loading
          if (snapshot.connectionState == ConnectionState.waiting ||
              (snapshot.hasData &&
                  snapshot.data?.data == null &&
                  snapshot.data?.error == null)) {
            return _loading(context);
          }

          // fetch error
          if (snapshot.hasData && snapshot.data?.error != null) {
            return _offline(context);
          }

          // success case
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.data != null) {
            var data = snapshot.data!.data!;

            // check if this is svg data or raw image data
            if (user.imgUrl == null ||
                user.imgUrl == "" ||
                (user.imgUrl?.contains("default") ?? false)) {
              logger.raw("SvgPicture.memory");
              return SvgPicture.memory(
                data,
                fit: BoxFit.cover,
                height: size,
                width: size,
                errorBuilder: (context, error, stackTrace) {
                  logger.exception(error, stackTrace);
                  return _offline(context);
                },
              );
            }

            return Image.memory(
              data,
              fit: BoxFit.cover,
              height: size,
              width: size,
              errorBuilder: (context, error, stackTrace) {
                logger.exception(error, stackTrace);
                return _offline(context);
              },
            );
          }

          // unknown case, just send loading
          return _loading(context);
        },
      );
    } catch (error, stack) {
      logger.exception(error, stack);
      return _offline(context);
    }
  }

  Widget _offline(BuildContext context) {
    return SvgPicture.asset(
      "assets/svg/default_profile.svg",
      height: size,
      width: size,
      fit: BoxFit.fitHeight,
      placeholderBuilder: _loading,
    );
  }

  Widget _loading(BuildContext context) {
    return LoadingIndicator(
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
