import 'dart:convert';
import 'dart:ui';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:QRLock/utils/app_theme.dart';
import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:QRLock/utils/utils.dart';
import 'package:QRLock/business_logic/view_models/view_qr_screen_viewmodel.dart';
import 'package:QRLock/services/service_locator.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:image/image.dart' as ImageLib;
//View QR Code after generate in history and generate history

class ViewQRCodeOverlay extends StatefulWidget {
  final QRCodeData content;
  final Function onFavTap;
  final Function onCancelTap;
  final bool save;
  ViewQRCodeOverlay(
      {Key key,
        @required this.content,
        this.onFavTap,
        this.onCancelTap,
        this.save})
      : super(key: key);
  @override
  _ViewQRCodeOverlayState createState() => _ViewQRCodeOverlayState();
}

class _ViewQRCodeOverlayState extends State<ViewQRCodeOverlay> {
  ViewQRScreenViewModel model = serviceLocator<ViewQRScreenViewModel>();
  QRCodeData content;
  Widget _favoriteButtonIcon = Icon(Icons.favorite);
  @override
  void initState() {
    super.initState();
    content = widget.content;
    genSaveQRCodeData(content, widget.save);
  }

  //Generate the qr code from data
  Future<void> genSaveQRCodeData(QRCodeData plainData, bool save) async {
    int id = await model.generateSaveQRCodeImage(plainData, save: save);
    if (id != -1) {
      content.id = id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ViewQRScreenViewModel>(
      create: (context) => model,
      child: Consumer<ViewQRScreenViewModel>(builder: (context, model, child) {
        _favoriteButtonIcon = Icon(
          Icons.favorite,
          color: content.isFav == 1 ? AppTheme.nearlyDarkPink : AppTheme.white,
        );
        return Container(
          height: MediaQuery.of(context).size.height / 1.6,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: AppTheme.notWhite,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(17.0),
              topRight: const Radius.circular(17.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Center(
            child: Stack(
              overflow: Overflow.visible,
              children: [
                Positioned(
                    left: MediaQuery.of(context).size.width / 4,
                    right: MediaQuery.of(context).size.width / 4,
                    top: 10,
                    bottom: 40,
                    child: Stack(
                      children:
                      widget.content.image.toString() != "null"?
                      [
                        BarcodeWidget(
                          barcode: Barcode.qrCode(
                              errorCorrectLevel: BarcodeQRCorrectionLevel.high),
                          data: Utils.getEncryptedActionText(widget.content),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                              color: Colors.white,
                              width: 50,
                              height: 50,
                              child: Image(
                                image: MemoryImage(
                                    base64Decode(widget.content.image)),
                              )
                          ),
                        ),
                      ]:[
                        BarcodeWidget(
                          barcode: Barcode.qrCode(
                              errorCorrectLevel: BarcodeQRCorrectionLevel.high),
                          data: Utils.getEncryptedActionText(widget.content),
                        ),
                      ],
                    )),
                Positioned(
                  left: 20,
                  top: 5,
                  child: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.black,
                        size: 30,
                      ),
                      onPressed: widget.onCancelTap),
                ),
                Positioned(
                  right: 10,
                  top: -15,
                  child: Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ], shape: BoxShape.circle),
                    child: RaisedButton(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: _favoriteButtonIcon,
                        ),
                        color: AppTheme.nearlyBlue,
                        shape: CircleBorder(),
                        onPressed: () {
                          model.updateFav(content).then((value) {
                            setState(() {
                              content.isFav == 1
                                  ? content.isFav = 0
                                  : content.isFav = 1;
                              _favoriteButtonIcon = Icon(
                                Icons.favorite,
                                color: content.isFav == 1
                                    ? AppTheme.nearlyDarkPink
                                    : AppTheme.white,
                              );
                            });
                          });
                        }),
                  ),
                ),
                Positioned(
                  left: 30,
                  bottom: 25,
                  child: RaisedButton(
                    onPressed: () {
                      WcFlutterShare.share(
                        sharePopupTitle: 'Share QR Code',
                        fileName: 'share.png',
                        mimeType: 'image/png',
                        bytesOfFile: ImageLib.encodePng(model.qrImage),
                      );
                    },
                    shape: StadiumBorder(),
                    color: AppTheme.nearlyBlue,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Share",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 30,
                  bottom: 25,
                  child: RaisedButton(
                    onPressed: () {
                      Utils().decodeQrCode(
                          Utils.getQrActionText(content), context,
                          soundEffects: false, save: false);
                    },
                    shape: StadiumBorder(),
                    color: AppTheme.nearGreen,
                    child: Text(
                      "Execute",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}