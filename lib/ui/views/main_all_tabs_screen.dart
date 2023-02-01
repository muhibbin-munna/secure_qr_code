import 'dart:async';

import 'package:QRLock/ui/views/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:QRLock/utils/app_theme.dart';
import 'package:QRLock/business_logic/models/tabIcon_data.dart';
import 'package:QRLock/ui/views/history_base.dart';
import 'package:QRLock/ui/views/qr_types_list_screen.dart';
import 'package:QRLock/ui/views/settings.dart';
import 'bottom_bar_view.dart';
import 'favorite_screen.dart';

//Main screen which includes the tabs and the children of the tabs
class AppTabs extends StatefulWidget {
  final bool launchToScanner;

  const AppTabs({Key key, this.launchToScanner = false}) : super(key: key);
  @override
  _AppTabsState createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> with TickerProviderStateMixin {
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(
    color: AppTheme.notWhite,
  );

  @override
  void initState() {
    super.initState();

    Timer.run(() {
      if (widget.launchToScanner) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    RScanCameraDialog()));
      }
    });
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    tabBody = QRTypesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: FutureBuilder<bool>(
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return Stack(
            children: <Widget>[
              tabBody,
              bottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          changeIndex: (int index) {
            setState(() {
              if (index == 0) {
                tabBody = QRTypesList();
              } else if (index == 1) {
                tabBody = HistoryBase();
              } else if (index == 2) {
                tabBody = FavoriteScreen();
              } else if (index == 3) {
                tabBody = Settings();
              }
            });
          },
        ),
      ],
    );
  }
}
