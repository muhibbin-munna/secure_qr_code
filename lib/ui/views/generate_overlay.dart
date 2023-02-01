import 'package:QRLock/ui/views/generateQRCodeScreens/generateCryptoQRCode.dart';
import 'package:QRLock/utils/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:QRLock/ui/views/generateQRCodeScreens/generateLocationQRCode.dart';

//Overlay for generating the QR Code (Do not wrap child with scaffold!)
class GenerateOverlay extends StatefulWidget {
  final Widget content;
  final Function onSubmitTap;
  final Function onCancelTap;
  GenerateOverlay(
      {Key key, @required this.content, this.onSubmitTap, this.onCancelTap})
      : super(key: key);
  @override
  _GenerateOverlayState createState() => _GenerateOverlayState();
}

class _GenerateOverlayState extends State<GenerateOverlay> {
  //The overlay content
  Widget content;
  //The overlay height
  double height;
  @override
  void initState() {
    content = widget.content;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height / 1.4;
    return Center(
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Positioned(
            child: Container(
              height: height,
              width: MediaQuery.of(context).size.width,
              child: Container(
                child: content,
                height: height,
                width: MediaQuery.of(context).size.width,
              ),
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
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.black,
                ),
                onPressed: widget.onCancelTap),
          ),
          Positioned(
            right: 10,
            top: -20,
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
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  color: Colors.green,
                  shape: CircleBorder(),
                  onPressed: widget.onSubmitTap),
            ),
          ),
        ],
      ),
    );
  }
}
