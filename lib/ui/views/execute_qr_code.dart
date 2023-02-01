import 'package:barcode/barcode.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:QRLock/utils/app_theme.dart';
import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:QRLock/utils/utils.dart';
import 'package:QRLock/business_logic/view_models/history_screen_viewmodel.dart';
import 'package:QRLock/services/service_locator.dart';

//Show the QR Code action
class ExecuteQRCode extends StatefulWidget {
  final String password;
  final String plainText;
  final String scannedText;
  final QREncryptionType qrEncryptionType;
  final bool save;

  ExecuteQRCode(
      {Key key,
      String title,
      IconData icon,
      this.password,
      this.plainText,
      this.scannedText,
      this.qrEncryptionType,
      this.save = true})
      : super(key: key);

  @override
  _ExecuteQRCodeState createState() => _ExecuteQRCodeState();
}

class _ExecuteQRCodeState extends State<ExecuteQRCode> {
  //Initialise model
  HistoryScreenViewModel model = serviceLocator<HistoryScreenViewModel>();

  //Incoming QR Code Data
  QRCodeData qrCodeData;

  //The file where the image is stored
  Widget image;

  @override
  void initState() {
    //Generate the Qr Code

    //Check if the incoming text is not null
    if (widget.plainText != null) {
      //Get QR Code data from plain text
      qrCodeData = Utils.extractQRCodeData(
          widget.plainText, widget.qrEncryptionType, widget.password);
      //Add the QR code as history
      if (widget.save) model.addHistoryData(qrCodeData);
    }
    super.initState();
  }

  //Get action data for UI (Like icon, text color, etc)
  ActionScreen _generateActionScreen(QRCodeData qrCodeData) {
    ActionScreen actionScreen = new ActionScreen();
    if (qrCodeData == null) {
      actionScreen.message = "Data is not valid";
      actionScreen.icon = null;
      actionScreen.textColor = Colors.red;
    } else {
      actionScreen.icon = Utils.getIconType(qrCodeData.qrCodeType);
      actionScreen.textColor = AppTheme.dark_grey;
      switch (qrCodeData.qrCodeType) {
        case QRCodeType.TEXT:
          actionScreen.message =
              "The content of the QR code is: \n\n" + qrCodeData.textData;
          break;
        case QRCodeType.WEB:
          actionScreen.message =
              "Are you want to go to this web URL? \n\n" + qrCodeData.textData;
          actionScreen.actionButtonText = "Open URL";
          break;
        case QRCodeType.PHONE_NUMBER:
          actionScreen.message =
              "Are you want to call this number? \n\n" + qrCodeData.textData;
          actionScreen.actionButtonText = "Call";
          break;
        case QRCodeType.GEO_LOCATION:
          actionScreen.message = "Are you want to open this location? \n\n" +
              qrCodeData.geoLat +
              "," +
              qrCodeData.geoLng;
          actionScreen.actionButtonText = "Open geo location";
          break;
          break;
        case QRCodeType.EMAIL:
          int idx = qrCodeData.textData.indexOf("?");
          if (idx == -1) idx = qrCodeData.textData.length;
          actionScreen.message = "Are you want to send to this email? \n\n" +
              qrCodeData.textData.substring(0, idx);
          actionScreen.actionButtonText = "Send email";
          break;
        case QRCodeType.SMS:
          actionScreen.message =
              "Are you want to send SMS to this number? \n\n" +
                  qrCodeData.smsTelNumber;
          actionScreen.actionButtonText = "Send SMS";
          break;
        case QRCodeType.WHATSAPP:
          actionScreen.message = "Do you want to Whatsapp this number? \n\n" +
              qrCodeData.whatsAppTelNumber;
          actionScreen.actionButtonText = "Open WhatsApp";
          break;
        case QRCodeType.YOUTUBE:
          actionScreen.message =
              "Do you want to go to this Youtube video? \n\n" +
                  qrCodeData.textData;
          actionScreen.actionButtonText = "Open video";
          break;
        case QRCodeType.BITCOIN:
          actionScreen.message =
              "Do you want to send " + qrCodeData.cryptoAmount +
                  " to this Bitcoin address? \n\n" +
                  qrCodeData.cryptoAddress;
          actionScreen.actionButtonText = "Open wallet";
          break;
        case QRCodeType.ETHEREUM:
          actionScreen.message =
              "Do you want to send " + qrCodeData.cryptoAmount +
                  " to this Ethereum address? \n\n" +
                  qrCodeData.cryptoAddress;
          actionScreen.actionButtonText = "Open wallet";
          break;
      }
    }
    return actionScreen;
  }

  @override
  Widget build(BuildContext context) {
    ActionScreen actionScreen = _generateActionScreen(qrCodeData);
    image = BarcodeWidget(
      barcode: Barcode.qrCode(),
      data: widget.scannedText,
      width: (MediaQuery
          .of(context)
          .size
          .width) / 2,
      height: (MediaQuery
          .of(context)
          .size
          .width) / 2,
    );
    return Scaffold(
      backgroundColor: AppTheme.notWhite,
      body: Container(
        child: Stack(
          children: [
            Positioned(
              top: 50,
              left: 30,
              right: 30,
              child: Container(
                child: Center(
                  child: image,
                ),
              ),
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              color: Colors.black.withOpacity(0.1),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                            height: MediaQuery
                                .of(context)
                                .size
                                .height / 8,
                            child: actionScreen.icon != null
                                ? Image(image: actionScreen.icon)
                                : Icon(
                              Icons.not_interested,
                              size: 100,
                              color: Colors.red,
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30, left: 10, right: 10),
                        child: Text(actionScreen.message,
                            style: TextStyle(
                                color: actionScreen.textColor, fontSize: 18)),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 5),
                          child: actionScreen.actionButtonText != null
                              ? RaisedButton(
                            child: Text(
                              actionScreen.actionButtonText,
                              style: TextStyle(fontSize: 20),
                            ),
                            textColor: Colors.white,
                            color: AppTheme.nearlyBlue,
                            onPressed: () {
                              // perform the required action
                              Utils.performAction(qrCodeData).catchError(
                                      (e) =>
                                  {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Error'),
                                            content: Text(
                                                e.message),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text("OK"),
                                                onPressed: () {
                                                  Navigator.of(
                                                      context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        })
                                  }
                              );
                            },
                          )
                              : Padding(
                            padding: EdgeInsets.all(0),
                          ))
                    ],
                  ),
                ),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.6),
                        spreadRadius: 7,
                        blurRadius: 9,
                        offset: Offset(0, 4), // changes position of shadow
                      ),
                    ]),
              ),
            ),
            Positioned(
              top: 25,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

//Data for the UI of the screen
class ActionScreen {
  AssetImage icon;
  String message;
  String actionButtonText;
  Color textColor;

  ActionScreen(
      {this.icon, this.message, this.actionButtonText, this.textColor});
}
