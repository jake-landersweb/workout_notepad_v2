import 'package:flutter/material.dart';

Image getImageIcon(String name, {double? size}) {
  switch (name) {
    case "bench-press":
      return Image.asset("assets/icons/bench-press-96.png",
          height: size ?? 50, width: size ?? 50);
    case "bouldering":
      return Image.asset("assets/icons/bouldering-96.png",
          height: size ?? 50, width: size ?? 50);
    case "calves":
      return Image.asset("assets/icons/calves-96.png",
          height: size ?? 50, width: size ?? 50);
    case "curls-with-dumbbells":
      return Image.asset("assets/icons/curls-with-dumbbells-96.png",
          height: size ?? 50, width: size ?? 50);
    case "deadlift-skin-type-2":
      return Image.asset("assets/icons/deadlift-skin-type-2-96.png",
          height: size ?? 50, width: size ?? 50);
    case "exercise":
      return Image.asset("assets/icons/exercise-96.png",
          height: size ?? 50, width: size ?? 50);
    case "floating-guru-skin-type-2":
      return Image.asset("assets/icons/floating-guru-skin-type-2-96.png",
          height: size ?? 50, width: size ?? 50);
    case "gymnastics":
      return Image.asset("assets/icons/gymnastics-96.png",
          height: size ?? 50, width: size ?? 50);
    case "judo-skin-type-2":
      return Image.asset("assets/icons/judo-skin-type-2-96.png",
          height: size ?? 50, width: size ?? 50);
    case "leg":
      return Image.asset("assets/icons/leg-96.png",
          height: size ?? 50, width: size ?? 50);
    case "middle-back":
      return Image.asset("assets/icons/middle-back-96.png",
          height: size ?? 50, width: size ?? 50);
    case "muscle":
      return Image.asset("assets/icons/muscle-96.png",
          height: size ?? 50, width: size ?? 50);
    case "prelum":
      return Image.asset("assets/icons/prelum-96.png",
          height: size ?? 50, width: size ?? 50);
    case "pushups":
      return Image.asset("assets/icons/pushups-96.png",
          height: size ?? 50, width: size ?? 50);
    case "roller-skating":
      return Image.asset("assets/icons/roller-skating-96.png",
          height: size ?? 50, width: size ?? 50);
    case "rowing-machine":
      return Image.asset("assets/icons/rowing-machine-96.png",
          height: size ?? 50, width: size ?? 50);
    case "sit-ups":
      return Image.asset("assets/icons/sit-ups-96.png",
          height: size ?? 50, width: size ?? 50);
    case "skipping-rope":
      return Image.asset("assets/icons/skipping-rope-96.png",
          height: size ?? 50, width: size ?? 50);
    case "squats":
      return Image.asset("assets/icons/squats-96.png",
          height: size ?? 50, width: size ?? 50);
    case "staircase":
      return Image.asset("assets/icons/staircase-96.png",
          height: size ?? 50, width: size ?? 50);
    case "stepper":
      return Image.asset("assets/icons/stepper-96.png",
          height: size ?? 50, width: size ?? 50);
    case "swimming":
      return Image.asset("assets/icons/swimming-96.png",
          height: size ?? 50, width: size ?? 50);
    case "taekwondo":
      return Image.asset("assets/icons/taekwondo-96.png",
          height: size ?? 50, width: size ?? 50);
    case "treadmill":
      return Image.asset("assets/icons/treadmill-96.png",
          height: size ?? 50, width: size ?? 50);
    case "trekking":
      return Image.asset("assets/icons/trekking-96.png",
          height: size ?? 50, width: size ?? 50);
    case "weightlifting":
      return Image.asset("assets/icons/weightlifting-96.png",
          height: size ?? 50, width: size ?? 50);
    case "workout":
      return Image.asset("assets/icons/workout-96.png",
          height: size ?? 50, width: size ?? 50);
    default:
      return Image.asset("assets/icons/bench-press-96.png",
          height: size ?? 50, width: size ?? 50);
  }
}
