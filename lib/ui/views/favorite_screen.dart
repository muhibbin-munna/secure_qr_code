import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:QRLock/utils/ads.dart';
import 'package:QRLock/utils/configuration.dart';
import 'package:QRLock/business_logic/view_models/history_screen_viewmodel.dart';
import 'package:QRLock/services/service_locator.dart';
import 'package:QRLock/ui/widgets/appBar.dart';
import 'package:QRLock/ui/widgets/qr_message_list_item.dart';
import '../../utils/app_theme.dart';
//Show favorite QR Codes
class FavoriteScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FavoriteBaseState();
}

class FavoriteBaseState extends State<StatefulWidget>
    with TickerProviderStateMixin {
  //Initialise the model
  HistoryScreenViewModel model = serviceLocator<HistoryScreenViewModel>();
  // The icon for the delete all items button
  Widget _clearItemsIcon = Icon(Icons.delete);
  // Animation controller for animating the items in
  AnimationController animationController;
  // Animation controller for animating the overlay in
  AnimationController overlayAnimationController;
  @override
  void initState() {

    super.initState();

    animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: Configuration.animationTime)
    );
    overlayAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: Configuration.animationTime)
    );

    Ads().showAd();

    if(model.favoriteItems == null)
      model.refreshData();


  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget deleteButtonBar() {
    return FlatButton(
        child: _clearItemsIcon,
        onPressed: () {
          //display are you sure dialog
          //FavoriteModel.FavoriteItems.length
          if (10 > 0) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete all?'),
                    content: Text(
                        "This will un-check all favorite items, are you sure?"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("YES"),
                        onPressed: () {
                          setState(() {
                            _clearItemsIcon =
                                CircularProgressIndicator();
                          });
                          model
                              .clearAllFavorite().then((value) =>                           {
                          setState(() {
                          _clearItemsIcon = Icon(
                          Icons.delete);
                          })
                          });
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
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryScreenViewModel>(
        builder: (context, model, child) =>
            Scaffold(
                backgroundColor: AppTheme.notWhite,
                body: Padding(
                    padding: EdgeInsets.only(top: MediaQuery
                        .of(context)
                        .padding
                        .top),
                    child:
                    SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              appBar('Favorite'),
                              Spacer(),
                              deleteButtonBar(),
                            ],
                          ),
                          Container(
                            height: MediaQuery
                                .of(context)
                                .size
                                .height - 150,
                            child: model.favoriteItems==null||model.favoriteItems.length == 0 ?
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
                                    Text(
                                      "Could not find any item", style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),),
                                    Padding(child: Text("Try to mark a QR code as favorite"),
                                      padding: EdgeInsets.only(top: 5),)
                                  ],
                                )
                            )
                                : QRMessageListItem(animationController: animationController, overlayAnimationController: overlayAnimationController, items: model.favoriteItems),
                          )
                        ],
                      ),
                    )
                )
            )
    );
  }
}
