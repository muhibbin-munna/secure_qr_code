import 'dart:convert';
import 'dart:io';

import 'package:QRLock/utils/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:intl/intl.dart';
import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:QRLock/utils/utils.dart';
import 'package:QRLock/ui/views/base/generate_page.dart';

//Generate QR Code

class GenerateTextQRCode extends GeneratePage {
  GenerateTextQRCode({
    Key key,
    this.title,
    this.qrCodeType,
  }) : super(key: key);

  final String title;
  final QRCodeType qrCodeType;

  @override
  _GenerateTextQRCodeState createState() {
    return _GenerateTextQRCodeState();
  }
}

class _GenerateTextQRCodeState extends GenerateState {
  TextEditingController _messageController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isEncrypted = false;
  bool _obscureText = true;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File _image;
  void getImage() {
    ImagePickerGC.pickImage(
      context: context,
      source: ImgSource.Both,
      barrierDismissible: true,
      cameraIcon: Icon(
        Icons.camera,
      ),
      galleryIcon: Icon(
        Icons.image,
      ), //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
    ).then((image) {
      setState(() {
        if(image != null)
          _image = image;
      });
    });
  }
  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText; //toggle password visibility
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
        textData: _messageController.text,
        qrCodeType: widget.qrCodeType,
        password: _passwordController.text,
        qrEncryptionType:
            _isEncrypted ? QREncryptionType.ENCRYPTED : QREncryptionType.PLAIN,
        image: _image!=null?base64Encode(_image.readAsBytesSync()):null,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Container(
        height:MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ListView(
              children: <Widget>[
                _designTextField(),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.only(top: 16),
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

  //Returns the text input depending on the QR Code Type
  Widget _designTextField() {
    switch (widget.qrCodeType) {
      case QRCodeType.TEXT:
        return TextFormField(
            controller: _messageController,
            decoration: InputDecoration(hintText: "Enter Your Message"),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            });
        break;
      case QRCodeType.WEB:
        return TextFormField(
            controller: _messageController,
            decoration: InputDecoration(hintText: "http:// or https://"),
            validator: (value) {
              var urlPattern =
                  r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
              bool urllValid =
                  new RegExp(urlPattern, caseSensitive: false).hasMatch(value);
              if (value.isEmpty || !urllValid) {
                return 'Please enter valid URL';
              }
              return null;
            });
        break;
      case QRCodeType.PHONE_NUMBER:
        return TextFormField(
            controller: _messageController,
            decoration: InputDecoration(hintText: "Telephone number"),
            keyboardType: TextInputType.phone,
            validator: (value) {
              String pattern =
                  r'(^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$)';
              bool telNumberValid = new RegExp(pattern).hasMatch(value);
              if (value.isEmpty || !telNumberValid) {
                return 'Please enter valid telephone number';
              }
              return null;
            });
        break;
      case QRCodeType.EMAIL:
        return TextFormField(
            controller: _messageController,
            decoration: InputDecoration(hintText: "name@example.com"),
            validator: (value) {
              bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value);
              if (value.isEmpty || !emailValid) {
                return 'Please enter valid email';
              }
              return null;
            });

        break;
      case QRCodeType.YOUTUBE:
        return TextFormField(
            controller: _messageController,
            decoration: InputDecoration(hintText: "Youtube URL or Video ID"),
            validator: (value) {
              bool youtubePattern = value.toLowerCase().contains("youtu") && (value.toLowerCase().contains(".be") || value.toLowerCase().contains(".com "));
              if (value.isEmpty) {
                return 'Please enter valid Youtube URL or Video ID';
              }
              if(youtubePattern) {
                return null;
              }
              else {
                _messageController.text = "https://www.youtube.com/watch?v="+value;
                return null;
              }
            });

        break;
      default:
        return null;
        break;
    }
  }
}
