import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:QRLock/utils/configuration.dart';
import 'package:QRLock/utils/utils.dart';
import 'package:QRLock/business_logic/view_models/history_screen_viewmodel.dart';
import 'package:QRLock/ui/views/view_qr_code_overlay.dart';

import '../../utils/app_theme.dart';

//Extension to easily style the card widget
extension CardModifier on Widget {
  Widget styleCard() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2, right: 12),
      child: Container(
        child: this,
      ),
    );
  }
}

//Scanned or generated items display
class QRMessageListItem extends StatefulWidget {
  final AnimationController overlayAnimationController;
  final AnimationController animationController;
  final List<HistoryItemPresenter> items;
  QRMessageListItem(
      {this.animationController, this.overlayAnimationController, this.items});

  @override
  _QRMessageListItemState createState() => _QRMessageListItemState();
}

class _QRMessageListItemState extends State<QRMessageListItem>
    with TickerProviderStateMixin {
  bool multiple = true;

  bool overlayVisible = false;

  bool blurVisible = false;

  QRCodeData overlayData;
  @override
  void initState() {
    super.initState();
  }

  Widget getBlur() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.5),
    );
  }

  //Get the view qr code overlay
  Widget getOverlay({QRCodeData content}) {
    return Positioned(
      bottom: -600,
      child: Visibility(
        visible: overlayVisible,
        child: AnimatedBuilder(
          animation: widget.overlayAnimationController,
          child: ViewQRCodeOverlay(
            content: content,
            onCancelTap: () {
              dismissOverlay();
            },
            save: false,
          ),
          builder: (BuildContext context, Widget child) {
            return Transform(
                transform: Matrix4.translationValues(
                    0, widget.overlayAnimationController.value * -600, 0),
                child: child);
          },
        ),
      ),
    );
  }

  //dismiss the overlay
  void dismissOverlay() {
    if (!widget.overlayAnimationController.isAnimating) {
      setState(() {
        blurVisible = false;
      });
      widget.overlayAnimationController.reverse().then((value) {
        setState(() {
          overlayVisible = false;
        });
      });
    }
  }

  //Get the text to be displayed
  String _getDisplayableTitle(QRCodeData qrCodeData) {
    switch (qrCodeData.qrCodeType) {
      case QRCodeType.TEXT:
        return _limitWith3Dots(qrCodeData.textData);
        break;
      case QRCodeType.WEB:
      case QRCodeType.YOUTUBE:
      case QRCodeType.PHONE_NUMBER:
      case QRCodeType.EMAIL:
        int idx = qrCodeData.textData.indexOf("?");
        if (idx == -1) idx = qrCodeData.textData.length;
        return qrCodeData.textData.substring(0, idx);
        break;
      case QRCodeType.GEO_LOCATION:
        return "Location";
        break;
      case QRCodeType.BITCOIN:
        return "Bitcoin";
        break;
      case QRCodeType.ETHEREUM:
        return "Ethereum";
        break;
      case QRCodeType.SMS:
        return "To: " + qrCodeData.smsTelNumber;
        break;
      case QRCodeType.WHATSAPP:
        return "To: " + qrCodeData.whatsAppTelNumber;
        break;
      default:
        return null;
    }
  }

  //Get the subtitle
  String _getDisplayableData(QRCodeData qrCodeData) {
    switch (qrCodeData.qrCodeType) {
      case QRCodeType.TEXT:
        return "";
        break;
      case QRCodeType.WEB:
      case QRCodeType.YOUTUBE:
      case QRCodeType.PHONE_NUMBER:
      case QRCodeType.EMAIL:
        return "";
        break;
      case QRCodeType.GEO_LOCATION:
        return qrCodeData.geoLat + "," + qrCodeData.geoLng;
        break;
      case QRCodeType.SMS:
        return "Content: " + _limitWith3Dots(qrCodeData.smsText);
        break;
      case QRCodeType.WHATSAPP:
        return "Content: " + _limitWith3Dots(qrCodeData.whatsAppText);
        break;
      case QRCodeType.BITCOIN:
      case QRCodeType.ETHEREUM:
        return "To: "+qrCodeData.cryptoAddress;
        break;
      default:
        return null;
    }
  }

  //Limit Text and overflow with 3 dots
  String _limitWith3Dots(String text) {
    var dots = "...";
    if (text.length > Configuration.maxListItemLimit) {
      text = text.substring(0, Configuration.maxListItemLimit) + dots;
    }
    return text;
  }

  //Get trailing widget for each item
  _getTrailing(QRCodeData historyItem) {
    List<Widget> trail = [];
    trail.add(Row(
      children: <Widget>[
        Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: AppTheme.nearlyBlue,
        ),
      ],
    ));

    if (historyItem.isFav == 1) {
      trail.add(Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5, top: 5),
            child: Icon(Icons.favorite, color: AppTheme.nearlyDarkPink),
          ),
        ],
      ));
    }
    return trail;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: [
        ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final isEncrypted = item.qrCodeDataItem.qrEncryptionType ==
                QREncryptionType.ENCRYPTED;
            final Animation<double> animation =
                Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: widget.animationController,
                curve: Interval((1 / widget.items.length) * index, 1.0,
                    curve: Curves.fastOutSlowIn),
              ),
            );
            if (!widget.animationController.isAnimating)
              widget.animationController.forward();
            return AnimatedBuilder(
              animation: widget.animationController,
              child: Container(
                child: Card(
                  color: AppTheme.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0)),
                  child: ListTile(
                    title: Text(
                      _getDisplayableTitle(item.qrCodeDataItem),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    bottom:
                                        _getDisplayableData(item.qrCodeDataItem)
                                                .isEmpty
                                            ? 0
                                            : 10),
                                child: Text(
                                    _getDisplayableData(item.qrCodeDataItem))),
                            Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(item.qrCodeDataItem.date)),
                            Container(
                              height: 20,
                            )
                          ],
                        )),
                    leading: Stack(
                      overflow: Overflow.visible,
                      children: [
                        Container(
                          width: 50,
                          child: Image(
                            image: item.icon,
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          child: Container(
                            width: 50,
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 5, top: 5),
                                  child: Image.asset(
                                    'assets/enc.png',
                                    height: 20,
                                    width: 20,
                                    color: isEncrypted
                                        ? AppTheme.nearlyBlue
                                        : AppTheme.darkerChipBackground,
                                  ),
                                ),
                                Image.asset(
                                  'assets/plain.png',
                                  height: 20,
                                  width: 20,
                                  color: !isEncrypted
                                      ? AppTheme.nearlyBlue
                                      : AppTheme.darkerChipBackground,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    trailing: Container(
                        width: 30,
                        height: 80,
                        child: Wrap(
                            alignment: WrapAlignment.center,
                            children: _getTrailing(item.qrCodeDataItem))),
                    onTap: () {
                      setState(() {
                        overlayVisible = true;
                        overlayData = item.qrCodeDataItem;
                        blurVisible = true;
                        widget.overlayAnimationController.forward();
                      });
                    },
                  ),
                ).styleCard(),
              ),
              builder: (BuildContext context, Widget child) {
                return FadeTransition(
                  opacity: animation,
                  child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 50 * (1.0 - animation.value), 0.0),
                    child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                        child: child),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          top: -100,
          child: Visibility(
            child: GestureDetector(child: getBlur(), onTap: dismissOverlay),
            visible: blurVisible,
          ),
        ),
        getOverlay(content: overlayData),
      ],
    );
  }
}
