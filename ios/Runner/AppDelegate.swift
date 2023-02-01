import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let actionChannel = FlutterMethodChannel(name: "actionChannel",
                                              binaryMessenger: controller.binaryMessenger)
    
    actionChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.
        guard call.method == "sendSMS" || call.method == "openCrypto" else {
        result(FlutterMethodNotImplemented)
        return
      }
        
        if(call.method == "sendSMS")
        {
            let arguments = call.arguments as! Array<String>
            self?.sendSMS(phone_number: arguments[0], message: arguments[1])
        }
        else if (call.method == "openCrypto")
        {
            let arguments = call.arguments as! String
            self?.openCrypto(link: arguments)
        }
    })
    
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func sendSMS(phone_number: String, message: String) {
        print(phone_number + "," + message)
        let sms: String = "sms:" + phone_number+"&body=" + message
        let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    private func openCrypto(link: String) {
        print(link)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL.init(string: link)!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
}
