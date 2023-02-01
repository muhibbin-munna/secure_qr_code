/*
 * Copyright (c) 2020 EmyDev
 */

import 'package:get_it/get_it.dart';
import 'package:QRLock/business_logic/view_models/history_screen_viewmodel.dart';
import 'package:QRLock/business_logic/view_models/view_qr_screen_viewmodel.dart';
import 'package:QRLock/services/storage/SqlitePersistence.dart';

// Using GetIt is a convenient way to provide services and view models
// anywhere we need them in the app.
GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // data base
  serviceLocator.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
   // view models
   serviceLocator.registerLazySingleton<HistoryScreenViewModel>(() => HistoryScreenViewModel());
   serviceLocator.registerFactory<ViewQRScreenViewModel>(() => ViewQRScreenViewModel());
}
