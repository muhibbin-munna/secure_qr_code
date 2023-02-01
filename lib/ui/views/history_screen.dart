import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:QRLock/utils/configuration.dart';
import 'package:QRLock/business_logic/view_models/history_screen_viewmodel.dart';
import 'package:QRLock/services/service_locator.dart';
import 'package:QRLock/ui/widgets/qr_message_list_item.dart';
import '../../utils/app_theme.dart';
import 'base/base_page.dart';


//Scanned QR Codes
class HistoryScreen extends BasePage {
  HistoryScreen({Key key, String title, IconData icon})
      : super(key: key, title: title, icon: icon);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin{
  //Initialize the model
  HistoryScreenViewModel model = serviceLocator<HistoryScreenViewModel>();
  //Animation controller for animating items in
  AnimationController animationController;
  //Animation controller for showing the overlay
  AnimationController overlayAnimationController;

  @override
  void initState() {
    super.initState();

    animationController=AnimationController(
        vsync: this,
        duration: Duration(milliseconds: Configuration.animationTime)
    );
    overlayAnimationController=AnimationController(
        vsync: this,
        duration: Duration(milliseconds: Configuration.animationTime)
    );

    if(model.historyItems == null)
      model.refreshData();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryScreenViewModel>(
        builder: (context, model, child) => Scaffold(
          backgroundColor: AppTheme.notWhite,
            body: model.historyItems.length ==0?
            Center(
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/search.png',
                      height: 200,
                      width: 200,
                      color: AppTheme.nearlyBlue,
                    ),
                    Text("Could not find any item", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    Padding(child: Text("Try to scan QR code"), padding: EdgeInsets.only(top: 5),)
                  ],
                )
            )
                :QRMessageListItem(animationController: animationController, overlayAnimationController: overlayAnimationController, items: model.historyItems))
    );
  }
}

