import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:QRLock/utils/configuration.dart';
import 'package:QRLock/business_logic/view_models/history_screen_viewmodel.dart';
import 'package:QRLock/services/service_locator.dart';
import 'package:QRLock/ui/widgets/qr_message_list_item.dart';
import '../../utils/app_theme.dart';
import 'base/base_page.dart';

//Generated QR Codes
class GenerateScreen extends BasePage {
  GenerateScreen({Key key, String title, IconData icon}) : super(key: key, title: title, icon: icon);

  @override
  _GenerateScreenState createState() => _GenerateScreenState();

}

class _GenerateScreenState extends State<GenerateScreen> with TickerProviderStateMixin{

  HistoryScreenViewModel model = serviceLocator<HistoryScreenViewModel>();
  AnimationController _animationController;
  AnimationController overlayAnimationController;
  @override
  void initState() {
    _animationController=AnimationController(
      vsync: this,
      duration: Duration(milliseconds: Configuration.animationTime)
    );
    overlayAnimationController=AnimationController(
      vsync: this,
      duration: Duration(milliseconds: Configuration.animationTime)
    );

    if(model.generatedItems == null)
      model.refreshData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryScreenViewModel>(
        builder: (context, model, child) =>
            Scaffold(
                backgroundColor: AppTheme.notWhite,
                body: model.generatedItems.length == 0 ?
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
                        Text("Could not find any item", style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),),
                        Padding(
                          child: Text("Try to add new"),
                          padding: EdgeInsets.only(top: 5),)
                      ],
                    )
                )
                    : QRMessageListItem(animationController: _animationController,overlayAnimationController: overlayAnimationController,items: model.generatedItems,))
    );
  }
}