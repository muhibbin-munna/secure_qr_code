import 'package:admob_flutter/admob_flutter.dart';
import 'configuration.dart';
//Class for ads
class Ads{
  AdmobInterstitial interstitialAd; //The ad to be show
  setAd(){
    //Initialize the ad
    interstitialAd = AdmobInterstitial(
        adUnitId: Configuration.adUnitId,
        listener: _adListener
    );
  }
  _adListener(AdmobAdEvent event, Map map){
    //Check if ad is loaded then show it
    if(event==AdmobAdEvent.loaded)
      interstitialAd.show();
  }
  showAd() {
    //If we want to show the ads
    if(Configuration.showAds) {
      setAd(); //Initialize the ad
      interstitialAd.load(); //Show the ad
    }
  }
}