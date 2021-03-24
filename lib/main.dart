// Copyright(c) 2021 Fredrick Allan Grott. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'dart:developer';

import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command_counter/application/build_modes.dart';
import 'package:flutter_command_counter/application/my_log_setup.dart';
// I use full imports as some of the plugins I am using balk on the partial imports syntax
import 'package:flutter_command_counter/application/platform_targets.dart';
import 'package:flutter_command_counter/application/service_locator.dart';
import 'package:flutter_command_counter/presentation/my_app.dart';
import 'package:logging/logging.dart';

// A good developer always debug sets-up a logger per dart file
// as one can get more useful debug feedback that way.
final Logger myMainLogger = Logger("myMain");

// To correctly set-up zones we need to have the parent function set to
// properly do futures where it stores that its not completed yet and upon
// executing either stores an error or stores has completed.
Future<void> main() async {
  // This is required as we are setting up things before it's
  // called in the internals of the runApp function so we need to
  // call it first before our set up lines of code. Google Flutter and
  // Dart SDK teams leave it off in the docs.
  WidgetsFlutterBinding.ensureInitialized();

  // To initialize the functions querying which platform we are on.
  initPlatformState();

  // Since we never ever test logging naked it's okay to have this a singleton-like.
  myLogSetUp();

  // Using GetIt to set up a service locator pattern to batch setup all my dependency injection initializations.
  setUpLocator();

  // Since we called the WidgetsFlutterBinding.ensureInitialized first this will not 
  // print out in logViewer until the Flutter SkyEngine fully loads up which is a few 
  // micro-seconds.
  myMainLogger.info("init of main function completed");

  // As of 3-2021 the Catcher-Sentry plugin pair depends on device_info and has not 
  // switched to device_info_plus and some other dependencies so using a plain 
  // error widget and zones to catch app exceptions asn using firebase-crashanalytics to 
  // report the crashes.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      return ErrorWidget(details.exception);
    }

    return Container(
      alignment: Alignment.center,
      child: const Text(
        'Error!',
        style: TextStyle(color: Colors.yellow),
        textDirection: TextDirection.ltr,
      ),
    );
  };

  //  This catches the dart and flutter errors and collates it and dumps to 
  // console in debug mode and in release mode will direct it to an
  // uncaught handler exception block in zone specification within the runZoneGuarded
  // section.
  // Or in newbie words, it reports the soft errors of the flutter framework 
  // such as if we attempt to use Positioned Widget inside a Column
  // Widget, for example.
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // app exceptions provider. We do not need this in Profile mode.
      if (isInReleaseMode) {
        Zone.current.handleUncaughtError(details.exception, details.stack);
      }
    }
  };



  runZonedGuarded<Future<void>>(
    () async {
      runApp(MyApp());
    },
    (error, stackTrace) async {
      await _reportError(error, stackTrace);
    },
    zoneSpecification: ZoneSpecification(
      // Intercept all print calls
      print: (self, parent, zone, line) async {
        // Paint all logs with Cyan color
        final pen = AnsiPen()..cyan(bold: true);
        // Include a timestamp and the name of the App
        final messageToLog = "[${DateTime.now()}] CommandApp $line";

        // Also print the message in the "Debug Console"
        parent.print(zone, pen(messageToLog));
      },
    ),
  );

}

// Our flutter reportError reporter
Future<void> _reportError(dynamic error, dynamic stackTrace) async {
  log('Caught error: $error');
  // Errors thrown in development mode are unlikely to be interesting. You
  // check if you are running in dev mode using an assertion and omit send
  // the report.
  if (isInDebugMode) {
    log('$stackTrace');
    log('In dev mode. Not sending report to an app exceptions provider.');

    return;
  } else {
    // reporting error and stacktrace to app exceptions provider code goes here
    if (isInReleaseMode) {
      // code goes here to report to firebase via crashanalytics
    }
  }
}
