# Workout Notepad Mobile App

Source code for the Workout Notepad mobile application. You can download this app for [iOS](https://apps.apple.com/pk/app/workout-notepad/id6453561144) and [Android](https://play.google.com/store/apps/details?id=com.landersweb.workout_notepad_v2) at the links provided. You can also visit the [website](https://workoutnotepad.co).

<div
  style="display: flex; flex-wrap: wrap; gap: 10px; justify-content: center;"
>
  <img
    src="screenshots/store-large/0-homescreen.png"
    alt="Homescreen"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
  <img
    src="screenshots/store-large/1-post-workout.png"
    alt="Post Workout"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
  <img
    src="screenshots/store-large/2-workout-detail.png"
    alt="Workout Detail"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
  <img
    src="screenshots/store-large/3-workout-edit.png"
    alt="Workout Edit"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
  <img
    src="screenshots/store-large/4-workout-launch.png"
    alt="Workout Launch"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
  <img
    src="screenshots/store-large/5-exercise-home.png"
    alt="Exercise Home"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
  <img
    src="screenshots/store-large/6-exercise-detail-cardio.png"
    alt="Exercise Detail Cardio"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
  <img
    src="screenshots/store-large/7-discover-home.png"
    alt="Discover Home"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
  <img
    src="screenshots/store-large/8-insights-home.png"
    alt="Insights Home"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
  <img
    src="screenshots/store-large/9-insights-home-2.png"
    alt="Insights Home 2"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
  <img
    src="screenshots/store-large/10-logs-home.png"
    alt="Logs Home"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
  <img
    src="screenshots/store-large/11-raw-workout-logs.png"
    alt="Raw Workout Logs"
    style="flex: 1 1 250px; max-width: 250px; width: 100%;"
  />
</div>

## About

This application is a passion project of mine, built out of the desire for a truly sandbox-esc workout planning and tracking experience. I was unsatisfied with the current offerings that were on the app store, and set out to build my own.

## Tech Stack

The application is built in [Flutter](https://flutter.dev). The application is built to be offline/local first, using an internal SQLite database.

There are two APIs, an older one written in Python which manages all of the data syncing operations, and a newer one built in Go which handles the mobile purchases and subscriptions.

> Now, the go api handles most of the logic

User authentication is handled with Google and Apple auth.

The website is built with Go + HTMX + AlpineJS.

## License

MIT
