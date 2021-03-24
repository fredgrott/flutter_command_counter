// Copyright(c) 2021 Fredrick Allan Grott. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter_command_counter/domain/my_app_model.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

GetIt locator = GetIt.instance;

final Logger myServiceLocatorLogger = Logger("myServiceLocatorLogger");

Future<void> setUpLocator({bool test = false}) async {

  locator.registerLazySingleton<MyAppModel>(() => MyAppModel());


  myServiceLocatorLogger.info("service locators setup");


}
