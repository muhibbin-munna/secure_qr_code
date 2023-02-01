import 'package:flutter/material.dart';
import 'package:QRLock/utils/ads.dart';
import 'package:QRLock/utils/configuration.dart';
import 'package:QRLock/business_logic/view_models/history_screen_viewmodel.dart';
import 'package:QRLock/services/service_locator.dart';
import 'package:QRLock/ui/views/base/base_page.dart';
import 'package:QRLock/ui/views/generate_screen.dart';
import 'package:QRLock/ui/views/history_screen.dart';
import 'package:QRLock/ui/widgets/appBar.dart';

import '../../utils/app_theme.dart';
//The tabs which show the Scanned and generated QR Codes
class HistoryBase extends BasePage {
  @override
  State<StatefulWidget> createState() => HistoryBaseState();
}

class HistoryBaseState extends State<HistoryBase>
    with TickerProviderStateMixin {
  TabController _controller;
  HistoryScreenViewModel historyModel =
      serviceLocator<HistoryScreenViewModel>();
  Widget _clearItemsIcon = Icon(Icons.delete);
  AnimationController animationController;
  Animation<double> topBarAnimation;
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: Configuration.animationTime));

    Ads().showAd();

    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }
  //The delete button bar
  Widget deleteButtonBar() {
    return FlatButton(
        child: _clearItemsIcon,
        onPressed: () {
          //display are you sure dialog
          if ((_controller.index == 0 &&
              historyModel.historyItems.length > 0) ||
              (_controller.index == 1 &&
                  historyModel.generatedItems.length > 0)) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  String actionText;
                  if (_controller.index == 0)
                    actionText =
                    "This will delete all scanned items, are you sure?";
                  else
                    actionText =
                    "This will delete all generated items, are you sure?";
                  return AlertDialog(
                    title: Text('Delete all?'),
                    content: Text(actionText),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("YES"),
                        onPressed: () {
                          setState(() {
                            _clearItemsIcon = CircularProgressIndicator();
                          });
                          if (_controller.index == 0)
                            historyModel
                                .clearAllGeneratedHistory(0)
                                .then((value) =>
                            {setState(() {
                              _clearItemsIcon = Icon(Icons.delete);
                            })
                            });
                          else
                            historyModel
                                .clearAllGeneratedHistory(1)
                                .then((value) => {{setState(() {
                              _clearItemsIcon = Icon(Icons.delete);
                            })
                            }});
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text("NO"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          }
        });
  }
  //Gets the widget with animation
  Widget getAnimatedWidget({@required Widget child}) {
    final Animation<double> animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );
    if (!animationController.isAnimating) animationController.forward();
    return AnimatedBuilder(
      animation: animationController,
      child: child,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation.value), 0.0),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.notWhite,
      body: FutureBuilder<bool>(
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          appBar('History'),
                          Spacer(),
                          deleteButtonBar(),
                        ],
                      ),
                      getAnimatedWidget(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1.0),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                child: TabBar(
                                  controller: _controller,
                                  tabs: <Widget>[
                                    Tab(
                                      child: Text(
                                        'Scanned',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    Tab(
                                      child: Text(
                                        'Generated',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  getAnimatedWidget(
                    child: Container(
                      height: MediaQuery.of(context).size.height - 200,
                      child: TabBarView(
                        children: <Widget>[
                          HistoryScreen(
                            title: 'History',
                          ),
                          GenerateScreen(
                            title: 'Generated',
                          ),
                        ],
                        controller: _controller,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
