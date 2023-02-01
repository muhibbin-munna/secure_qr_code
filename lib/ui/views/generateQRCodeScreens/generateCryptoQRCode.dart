import 'dart:convert';
import 'dart:io';

import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:QRLock/ui/views/base/generate_page.dart';
import 'package:QRLock/utils/app_theme.dart';
import 'package:QRLock/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:intl/intl.dart';

class GenerateCryptoQRCode extends GeneratePage {
  final QRCodeType qrCodeType;

  GenerateCryptoQRCode({Key key, this.qrCodeType}) : super(key: key, qrCodeType: qrCodeType);
  @override
  State<StatefulWidget> createState() => GenerateCryptoQRCodeState();
}

class GenerateCryptoQRCodeState extends GenerateState {
  TextEditingController _amountController = TextEditingController();
  TextEditingController __messageController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  QRCodeType _qrCodeType;
  final _formKey = GlobalKey<FormState>();
  bool _isEncrypted = false;
  bool _obscureText = true;
  File _image;
  void getImage() {
    ImagePickerGC.pickImage(
      context: context,
      source: ImgSource.Both,
      cameraIcon: Icon(
        Icons.camera,
      ),
      galleryIcon: Icon(
        Icons.image,
      ), //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
    ).then((image) {
      setState(() {
        _image = image;
      });
    });
  }


  @override
  void initState() {
    _qrCodeType = widget.qrCodeType;
    super.initState();
  }

  String getCryptoName() {
    if (_qrCodeType == QRCodeType.BITCOIN) return "Bitcoin";
    if (_qrCodeType == QRCodeType.ETHEREUM)
      return "Ethereum";
    else
      return "";
  }
  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText; //toggle password visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _addressController,
                  decoration:
                      InputDecoration(hintText: getCryptoName() + " Address"),
                ),
                Padding(
                  padding: EdgeInsets.only(top:10.0),
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(hintText: "Amount"),
                  ),
                ),
                _qrCodeType==QRCodeType.BITCOIN?Padding(
                  padding: EdgeInsets.only(top:10.0),
                  child: TextFormField(
                    controller: __messageController,
                    decoration:
                        InputDecoration(hintText: "Message (Optional)"),
                  ),
                ):Container(),
                Padding(
                  padding: EdgeInsets.only(top: 10  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: SizedBox(
                          child: Checkbox(
                            value: _isEncrypted,
                            onChanged: (newValue) {
                              setState(() {
                                _isEncrypted = newValue;
                              });
                            },
                          ),
                          width: 24,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          decoration:
                          const InputDecoration(hintText: 'Password'),
                          validator: (val) => _isEncrypted && val.length < 6
                              ? 'Password too short.'
                              : null,
                          enabled: _isEncrypted,
                          obscureText: _obscureText,
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Container(
                            child: IconButton(
                              icon: Icon(_obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                _toggle();
                              },
                            ),
                            width: 20,
                          )),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child:  RaisedButton(
                        onPressed: () {
                          getImage();
                        },
                        shape: StadiumBorder(),
                        color: AppTheme.nearlyBlue,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Choose Image",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    _image!=null?Image(
                      width: 100.0,
                      image: FileImage(
                        _image,
                        scale:0.2,
                      ),
                    ):Container(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  QRCodeData submit() {
    if (_formKey.currentState.validate()) {
      // If the form is valid, produce the QR code
      //generate
      return QRCodeData(
        generatedOrHistory: 1,
        isFav: 0,
        date: DateFormat('kk:mm:ss \n EEE d MMM').format(DateTime.now()),
        cryptoMessage: __messageController.text,
        cryptoAddress: _addressController.text,
        cryptoAmount: _amountController.text,
        qrCodeType: widget.qrCodeType,
        password: _passwordController.text,
        qrEncryptionType:
        _isEncrypted ? QREncryptionType.ENCRYPTED : QREncryptionType.PLAIN,
        image: _image!=null?base64Encode(_image.readAsBytesSync()):null,
      );
    }
    return null;
  }
}
