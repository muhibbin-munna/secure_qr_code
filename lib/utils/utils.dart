import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:QRLock/ui/views/execute_qr_code.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'configuration.dart';
import 'encryption.dart';

//The Type Of the QR Code
enum QRCodeType {
  TEXT, //Plain Text QR Code
  WEB, //URL
  PHONE_NUMBER, //Phone number
  GEO_LOCATION, //Location
  EMAIL, //Email address
  SMS, //SMS Phone number and message
  WHATSAPP, //WhatsApp Phone number and message
  BITCOIN, //Bitcoin
  ETHEREUM, //Ethereum
  YOUTUBE, //Youtube video
}
//If the QR Code is encrypted or not
enum QREncryptionType {
  PLAIN, //Not Encrypted
  ENCRYPTED, //Encrypted
}

class Utils {
  static const platform = const MethodChannel('actionChannel');
  //Get Icon of list in generate and history screens
  static AssetImage getIconType(QRCodeType qrCodeType) {
    AssetImage icon;
    switch (qrCodeType) {
      case QRCodeType.WEB:
        icon = AssetImage("assets/web.png");
        break;
      case QRCodeType.PHONE_NUMBER:
        icon = AssetImage("assets/call.png");
        break;
      case QRCodeType.TEXT:
        icon = AssetImage("assets/text.png");
        break;
      case QRCodeType.GEO_LOCATION:
        icon = AssetImage("assets/location.png");
        break;
      case QRCodeType.EMAIL:
        icon = AssetImage("assets/email.png");
        break;
        break;
      case QRCodeType.SMS:
        icon = AssetImage("assets/sms.png");
        break;
      case QRCodeType.WHATSAPP:
        icon = AssetImage("assets/whats.png");
        break;
      case QRCodeType.BITCOIN:
        icon = AssetImage("assets/bitcoin.png");
        break;
      case QRCodeType.ETHEREUM:
        icon = AssetImage("assets/ethereum.png");
        break;
      case QRCodeType.YOUTUBE:
        icon = AssetImage("assets/youtube.png");
        break;
      default:
        icon = AssetImage("assets/text.png");
        break;
    }
    return icon;
  }

  //Get plain text string from QR Code Data
  static String getQrActionText(QRCodeData qrCodeData) {
    String textData;

    if (qrCodeData.qrCodeType != QRCodeType.SMS &&
        qrCodeData.qrCodeType != QRCodeType.GEO_LOCATION &&
        qrCodeData.qrCodeType != QRCodeType.BITCOIN &&
        qrCodeData.qrCodeType != QRCodeType.ETHEREUM) {
      //handle text data here (plain text, tel_number, web, email
      if (qrCodeData.qrCodeType == QRCodeType.TEXT ||
          qrCodeData.qrCodeType == QRCodeType.WEB || qrCodeData.qrCodeType == QRCodeType.YOUTUBE)
        textData = qrCodeData.textData;
      else if (qrCodeData.qrCodeType == QRCodeType.PHONE_NUMBER)
        textData = "tel:" + qrCodeData.textData;
      else if (qrCodeData.qrCodeType == QRCodeType.EMAIL)
        textData = "mailto:" + qrCodeData.textData;
      else if (qrCodeData.qrCodeType == QRCodeType.WHATSAPP){
        textData = Uri.encodeFull('https://wa.me/'+qrCodeData.whatsAppTelNumber+'?text='+qrCodeData.whatsAppText);
      }
    } else if (qrCodeData.qrCodeType == QRCodeType.SMS) {
      textData = "sms:" + qrCodeData.smsTelNumber + ":" + qrCodeData.smsText;
    } else if (qrCodeData.qrCodeType == QRCodeType.GEO_LOCATION) {
      textData = "geo:" + qrCodeData.geoLat + "," + qrCodeData.geoLng;
    }
    else if (qrCodeData.qrCodeType == QRCodeType.BITCOIN) {
      textData = "bitcoin:" + qrCodeData.cryptoAddress + "?amount=" + qrCodeData.cryptoAmount;
      if(qrCodeData.cryptoMessage !=null)
        {
          textData += ("&message=" + qrCodeData.cryptoMessage);
        }
    }
    else if (qrCodeData.qrCodeType == QRCodeType.ETHEREUM) {
      textData = "ethereum:" + qrCodeData.cryptoAddress + "?value=" + qrCodeData.cryptoAmount;
    }
    return textData;
  }

  //Get plain text string from QR Code Data and encrypt if necessary
  static String getEncryptedActionText(QRCodeData qrCodeData) {
    String textData=getQrActionText(qrCodeData);
    if (qrCodeData.qrEncryptionType == QREncryptionType.ENCRYPTED) {
      textData =
          Cryptography.encrypt(textData, qrCodeData.password); //encrypt qr code
    }
    return textData;
  }

  //Check if the qrCode is encrypted
  static isEncrypted(String scannedText) {
    return scannedText.startsWith(Configuration.fingerprint);
  }

  //Check if password is correct
  static String isPasswordCorrect(String scannedText, String password) {
    String trimmedText =
        scannedText.substring(Configuration.fingerprint.length);
    String decodedText = Cryptography.decrypt(trimmedText, password);

    if (decodedText.startsWith(Configuration.fingerprint))
      return decodedText.substring(Configuration.fingerprint.length);
    else
      return null;
  }

  //Decode QR Code and execute it
  void decodeQrCode(String scannedText, BuildContext context,
      {bool soundEffects = false, bool save = true}) {
    SharedPreferences.getInstance().then((prefs) {
      if (soundEffects== null || !soundEffects) {
        soundEffects = prefs.getBool("soundEffects");
      }
      if (soundEffects!= null && soundEffects) FlutterBeep.beep();
    });
    String decodedText = scannedText;
    TextEditingController _passwordController = TextEditingController();
    if (isEncrypted(scannedText)) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            _passwordController.clear();
            return AlertDialog(
              title: Text('Encrypted QR Code'),
              content: Container(
                child: Column(
                  children: <Widget>[
                    Text("Enter the correct password to proceed"),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(hintText: 'Password'),
                    )
                  ],
                ),
                height: 200,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    decodedText = isPasswordCorrect(
                        scannedText, _passwordController.text);
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ExecuteQRCode(
                              title: "QR Code",
                              password: _passwordController.text,
                              plainText: decodedText,
                              scannedText: scannedText,
                              qrEncryptionType: QREncryptionType.ENCRYPTED,
                              save: save),
                        ));
                  },
                ),
                FlatButton(
                  child: Text("CANCEL"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => ExecuteQRCode(
                  title: "QR Code",
                  plainText: decodedText,
                  scannedText: scannedText,
                  qrEncryptionType: QREncryptionType.PLAIN,
                  save: save)));
    }
  }

  //Preform the action using url launcher (except SMS)
  static Future<void> performAction(QRCodeData qrCodeData) async {
    String actionTextData = Utils.getQrActionText(qrCodeData);
    switch (qrCodeData.qrCodeType) {
      case QRCodeType.TEXT:
        break;

      case QRCodeType.WEB:
        if (await canLaunch(actionTextData)) {
          await launch(actionTextData, forceSafariVC: false);
        } else {
          throw 'Could not launch $qrCodeData.text_data';
        }
        break;
      case QRCodeType.PHONE_NUMBER:
        if (await canLaunch(actionTextData)) {
          await launch(actionTextData);
        } else {
          throw "Can't phone that number " + actionTextData;
        }
        break;
      case QRCodeType.GEO_LOCATION:
        final String googleMapsUrl = "comgooglemaps://?center=" +
            qrCodeData.geoLat +
            "," +
            qrCodeData.geoLng;
        final String appleMapsUrl = "https://maps.apple.com/?q=" +
            qrCodeData.geoLat +
            "," +
            qrCodeData.geoLng;

        if (await canLaunch(googleMapsUrl)) {
          await launch(googleMapsUrl);
        }
        if (await canLaunch(appleMapsUrl)) {
          await launch(appleMapsUrl, forceSafariVC: false);
        } else {
          throw "Couldn't launch URL";
        }
        break;
      case QRCodeType.EMAIL:
        if (await canLaunch(actionTextData)) {
          await launch(actionTextData);
        } else {
          throw "Can't mail this email " + actionTextData;
        }
        break;
      case QRCodeType.SMS:
        _sendSMS(qrCodeData.smsText, qrCodeData.smsTelNumber);
        break;
      case QRCodeType.WHATSAPP:
        if (await canLaunch(actionTextData)) {
          await launch(actionTextData);
        } else {
          throw "Can't send this WhatsApp message " + actionTextData;
        }
        break;
      case QRCodeType.BITCOIN:
      case QRCodeType.ETHEREUM:
        return _openCrypto(actionTextData);
        break;
      case QRCodeType.YOUTUBE:
        if (await canLaunch(actionTextData)) {
          await launch(actionTextData);
        } else {
          throw "Can't open this Youtube video " + actionTextData;
        }
        break;
    }
  }

  //Uses a platform channel to send the sms
  static void _sendSMS(String message, String recipent) async {
    await platform.invokeMethod("sendSMS", [recipent, message]);
  }


  //Uses a platform channel to send the sms
  static void _openCrypto(String cryptoURI) async {
    return await platform.invokeMethod("openCrypto", cryptoURI);
  }

  //Function that gets QRCodeData from plain text
  static QRCodeData extractQRCodeData(
      String plainText, QREncryptionType qrEncryptionType, String password) {
    QRCodeData qrCodeData = new QRCodeData();
    qrCodeData.password = password;
    qrCodeData.qrEncryptionType = qrEncryptionType;
    qrCodeData.date =
        DateFormat('kk:mm:ss \n EEE d MMM').format(DateTime.now());
    qrCodeData.generatedOrHistory = 0;
    if (plainText.toLowerCase().startsWith("tel:")) {
      //tel number
      plainText.replaceFirst("TEL:", "tel:");
      qrCodeData.textData = plainText.substring("tel:".length);
      qrCodeData.qrCodeType = QRCodeType.PHONE_NUMBER;
    } else if (plainText.toLowerCase().startsWith("https://wa.me") ||
        plainText.toLowerCase().startsWith("http://wa.me")) {
      //whatsapp
      plainText=Uri.decodeFull(plainText);
      plainText.replaceFirst("http://wa.me/", "");
      plainText.replaceFirst("https://wa.me/", "");
      var newText=plainText.split('?text=');
      qrCodeData.whatsAppText = newText[1];
      qrCodeData.whatsAppTelNumber = newText[0];
      qrCodeData.qrCodeType = QRCodeType.WHATSAPP;
    } else if ((plainText.toLowerCase().startsWith("http://") ||
        plainText.toLowerCase().startsWith("https://")) && plainText.toLowerCase().contains("youtu")) {
      //web
      plainText.replaceFirst("HTTPS://", "https://");
      plainText.replaceFirst("HTTP://", "http://");
      qrCodeData.textData = plainText;
      qrCodeData.qrCodeType = QRCodeType.YOUTUBE;
    } else if (plainText.toLowerCase().startsWith("http://") ||
        plainText.toLowerCase().startsWith("https://")) {
      //web
      plainText.replaceFirst("HTTPS://", "https://");
      plainText.replaceFirst("HTTP://", "http://");
      qrCodeData.textData = plainText;
      qrCodeData.qrCodeType = QRCodeType.WEB;
    } else if (plainText.toLowerCase().startsWith("mailto:")) {
      //email
      plainText.replaceFirst("MAILTO:", "mailto:");
      qrCodeData.textData = plainText.substring("mailto:".length);
      qrCodeData.qrCodeType = QRCodeType.EMAIL;
    } else if (plainText.toLowerCase().startsWith("sms:")) {
      //SMS
      plainText.replaceFirst("SMS:", "sms:");
      String data = plainText.substring("sms:".length);
      int idx = data.indexOf(":");
      qrCodeData.smsTelNumber = data.substring(0, idx);
      qrCodeData.smsText = data.substring(idx + 1);
      qrCodeData.qrCodeType = QRCodeType.SMS;
    } else if (plainText.toLowerCase().startsWith("smsto:")) {
      //SMS
      plainText.replaceFirst("SMSTO:", "smsto:");
      String data = plainText.substring("smsto:".length);
      int idx = data.indexOf(":");
      qrCodeData.smsTelNumber = data.substring(0, idx);
      qrCodeData.smsText = data.substring(idx + 1);
      qrCodeData.qrCodeType = QRCodeType.SMS;
    } else if (plainText.toLowerCase().startsWith("geo:")) {
      //GEO
      plainText.replaceFirst("GEO:", "geo:");
      String data = plainText.substring("geo:".length);
      int idx = data.indexOf(",");
      qrCodeData.geoLat = data.substring(0, idx);
      qrCodeData.geoLng = data.substring(idx + 1);
      qrCodeData.qrCodeType = QRCodeType.GEO_LOCATION;
    } else if (plainText.toLowerCase().startsWith("bitcoin:")) {
      //GEO
      plainText.replaceFirst("BITCOIN:", "bitcoin:");
      String data = plainText.substring("bitcoin:".length);
      int idx = data.indexOf("?");
      if(idx==-1)
        idx=data.length-1;
      qrCodeData.cryptoAddress = data.substring(0, idx);

      String message_str = "&message=";
      int messageIndex=data.indexOf(message_str);

      if(messageIndex!=-1) {
        int start_of_next_paramater = data.indexOf("?", messageIndex + 1);
        qrCodeData.cryptoMessage = data.substring(messageIndex + message_str.length,
            ((start_of_next_paramater == -1) ? data.length
                : messageIndex + message_str.length + start_of_next_paramater));
      }

      String amount_str = "?amount=";
      int amountIndex=data.indexOf(amount_str);
      if(amountIndex!=-1) {
        int start_of_next_paramater = data.indexOf("&", amountIndex + 1);
        qrCodeData.cryptoAmount = data.substring(amountIndex + amount_str.length,
            ((start_of_next_paramater == -1) ? data.length - 1
                : start_of_next_paramater));
      }
      qrCodeData.qrCodeType = QRCodeType.BITCOIN;
    }
    else if (plainText.toLowerCase().startsWith("ethereum:")) {
      //GEO
      plainText.replaceFirst("ETHEREUM:", "ethereum:");
      String data = plainText.substring("ethereum:".length);
      int idx = data.indexOf("?");
      if(idx==-1)
        idx=data.length-1;
      qrCodeData.cryptoAddress = data.substring(0, idx);

      String amount_str = "?value=";
      int amountIndex=data.indexOf(amount_str);
      if(amountIndex!=-1) {
        int start_of_next_paramater = data.indexOf("?", amountIndex + 1);
        qrCodeData.cryptoAmount = data.substring(amountIndex + amount_str.length,
            ((start_of_next_paramater == -1) ? data.length - 1
                : start_of_next_paramater));
      }
      qrCodeData.qrCodeType = QRCodeType.ETHEREUM;
    }
    else {
      //text
      qrCodeData.textData = plainText;
      qrCodeData.qrCodeType = QRCodeType.TEXT;
    }

    return qrCodeData;
  }
}
