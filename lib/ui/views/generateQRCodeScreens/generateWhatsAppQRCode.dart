import 'dart:convert';
import 'dart:io';
import 'package:QRLock/utils/app_theme.dart';

import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:QRLock/ui/views/base/generate_page.dart';
import 'package:QRLock/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:intl/intl.dart';

class GenerateWhatsAppQRCode extends GeneratePage {
  GenerateWhatsAppQRCode({Key key}) : super(key: key);
  @override
  _GenerateWhatsAppQRCodeState createState() => _GenerateWhatsAppQRCodeState();
}

class _GenerateWhatsAppQRCodeState extends GenerateState {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _messageController = TextEditingController();
  TextEditingController _whatsAppPhoneNumber = TextEditingController();
  TextEditingController _countryCode = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ListView(
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          "+"
                        ),
                        Container(
                          width: 50,
                          child: TextFormField(
                              controller: _countryCode,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                bool telNumberValid=true;
                                if(value.isEmpty || value.length>3){
                                  telNumberValid=false;
                                }
                                if (!telNumberValid) {
                                  return 'Please enter valid country code';
                                }
                                return null;
                              }),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width-158,
                          child: TextFormField(
                              controller: _whatsAppPhoneNumber,
                              decoration:
                              InputDecoration(hintText: "Enter Phone Number"),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                String pattern =
                                    r'(^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$)';
                                bool telNumberValid =
                                new RegExp(pattern).hasMatch(value);
                                if (value.isEmpty || !telNumberValid) {
                                  return 'Please enter valid tel number';
                                }
                                return null;
                              }),
                        ),
                      ],
                    ),
                    TextFormField(
                        controller: _messageController,
                        decoration:
                            InputDecoration(hintText: "Enter WhatsApp Message"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter an WhatsApp Message';
                          }
                          return null;
                        }),
                    Row(
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
              )),
        ),
      ),
    );
  }

  @override
  QRCodeData submit() {
    if (_formKey.currentState.validate()) {
      QRCodeData data = QRCodeData(
        generatedOrHistory: 1,
        date: DateFormat('kk:mm:ss \n EEE d MMM').format(DateTime.now()),
        whatsAppTelNumber: "+"+_countryCode.text+_whatsAppPhoneNumber.text,
        whatsAppText: _messageController.text,
        qrCodeType: QRCodeType.WHATSAPP,
        password: _passwordController.text,
        qrEncryptionType:
            _isEncrypted ? QREncryptionType.ENCRYPTED : QREncryptionType.PLAIN,
        image: _image!=null?base64Encode(_image.readAsBytesSync()):null,
      );
      return data;
    } else {
      return null;
    }
  }
}
