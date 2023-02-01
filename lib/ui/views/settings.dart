import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:QRLock/utils/app_theme.dart';
import 'package:QRLock/utils/ads.dart';
import 'package:QRLock/utils/configuration.dart';
import 'package:QRLock/ui/widgets/appBar.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}
// Settings Page
class _SettingsState extends State<Settings> with TickerProviderStateMixin {
  bool launchToScanner = false;
  bool soundEffects = false;
  bool notAskAfterScan = false;
  //Animation controller for animating items in
  AnimationController animationController;
  @override
  void initState() {
    Ads().showAd();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: Configuration.animationTime));
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        if (prefs.getBool("launchToScanner") != null)
          launchToScanner = prefs.getBool("launchToScanner");
        if (prefs.getBool("soundEffects") != null)
          soundEffects = prefs.getBool("soundEffects");
        if (prefs.getBool("notAskAfterScan") != null)
          notAskAfterScan = prefs.getBool("notAskAfterScan");
      });
    });
    super.initState();
  }
  //Set launch to scanner setting
  void setLaunchToScanner(bool newLaunchToScanner) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("launchToScanner", newLaunchToScanner);
    setState(() {
      launchToScanner = newLaunchToScanner;
    });
  }
  //Set sound effects setting
  void setSoundEffects(bool newSetSoundEffects) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("soundEffects", newSetSoundEffects);
    setState(() {
      soundEffects = newSetSoundEffects;
    });
  }
  //Set ask after scan
  void setAskAfterScan(bool newAskAfterScan) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("notAskAfterScan", newAskAfterScan);
    setState(() {
      notAskAfterScan = newAskAfterScan;
    });
  }

  //Get the idget with animation
  Widget getAnimatedSettingWidget({Widget child, int index}) {
    final Animation<double> animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval((1 / 2) * index, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );
    animationController.forward();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 75),
          child: Column(
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    appBar('Settings'),
                  ]),
              getAnimatedSettingWidget(
                  index: 0,
                  child:
                  Padding(
                    padding: EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 20),
                    child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "General",
                                style: AppTheme.title,
                              ),
                            ),
                            Container(
                              child: SettingsTile.switchTile(
                                  title: 'Launch to Scanner',
                                  switchValue: launchToScanner,
                                  onToggle: setLaunchToScanner),
                            ),
                            Container(
                              child: SettingsTile.switchTile(
                                  title: 'Sound Effects',
                                  switchValue: soundEffects,
                                  onToggle: setSoundEffects),
                            ),
                            Container(
                              child: SettingsTile.switchTile(
                                  title: 'Do not ask after QR code scan?',
                                  switchValue: notAskAfterScan,
                                  onToggle: setAskAfterScan),
                            ),
                          ],
                        )
                    ),
                  )
              ),
              getAnimatedSettingWidget(
                  index: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 20),
                    child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "About Us",
                                style: AppTheme.title,
                              ),
                            ),
                            Column(
                              children : <Widget>[
                                createSettingTile(FontAwesomeIcons.twitter, 'Follow us on Twitter', Configuration.twitterURL),
                                createSettingTile(FontAwesomeIcons.facebook, 'Like us on Facebook', Configuration.facebookURL),
                                createSettingTile(FontAwesomeIcons.share, 'Share app with your friends', "share"),
                                createSettingTile(null, 'Privacy Policy', Configuration.privacyPolicyURL),
                                createSettingTile(null, 'Terms of service', Configuration.termsOfServiceURL),
                              ],
                            ),
                          ],
                        )
                    ),
                  )
              ),
            ],
          ),
        ),
      ),

    );
  }

  createSettingTile(icon, title, webUrl) {
    return SettingsTile(
      leading: icon != null ? Icon(
        icon,
        color: AppTheme.nearlyBlue,
      ) : null,
      title: title,
      onTap: () {
        if(webUrl == "share"){
          Share.share('check out QR Privacy app from Playstore- https://play.google.com/store/apps/details?id=com.games.qrprivacy');
        }
        else {
          launch(webUrl,
              forceSafariVC: false);
        }
      },
      trailing: Icon(Icons.arrow_forward_ios),
    );
  }
}
