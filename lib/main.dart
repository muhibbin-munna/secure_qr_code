/*
 * Copyright (c) 2020 EmyDev
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:QRLock/services/service_locator.dart';
import 'package:QRLock/ui/views/main_all_tabs_screen.dart';
import 'package:QRLock/ui/views/my_animated_splash_screen.dart';
import 'package:QRLock/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'business_logic/view_models/history_screen_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.red[600],
  ));

  HistoryScreenViewModel model = serviceLocator<HistoryScreenViewModel>();
  SharedPreferences.getInstance().then((prefs) {
    runApp(ChangeNotifierProvider<HistoryScreenViewModel>(
        create: (context) => model,
        child: SplashScreen(
          prefs: prefs,
        )));
  });
}

class QRLockApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'QR Lock',
        theme: ThemeData(fontFamily: 'EBGaramond'),
        debugShowCheckedModeBanner: false,
        home: AppTabs(),
      );
}

class SplashScreen extends StatelessWidget {
  final SharedPreferences prefs;

  SplashScreen({this.prefs});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'QR Lock',
      theme: ThemeData(fontFamily: 'EBGaramond'),
      debugShowCheckedModeBanner: false,
      home: SplashScreenWidget(
        prefs: prefs,
      ),
    );
  }
}

class SplashScreenWidget extends StatelessWidget {
  final SharedPreferences prefs;

  SplashScreenWidget({this.prefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    bool scan = prefs.getBool("launchToScanner");
    if (scan == null || prefs == null) {
      scan = false;
    }
    return MyAnimatedSplashScreen(
      splash: 'assets/lock.png',
      nextScreen: (scan == null || scan == false)
          ? AppTabs()
          : AppTabs(
              launchToScanner: true,
            ),
      splashTransition: SplashTransition.rotationTransition,
    );
  }
}
