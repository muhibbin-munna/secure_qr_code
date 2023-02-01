/*
 * Copyright (c) 2020 EmyDev
 */

import 'package:QRLock/utils/utils.dart';

class QRCodeData {
  //The Data Stored In the QR Code
  //This has fields for all types, and a parameter which tells us which type
  //This is used for both saving scanned QR Codes and saving generated QR Codes
  int id; //An ID for storing the data
  String textData; //Data for plain text QR Code
  QRCodeType qrCodeType; //The QR Code Type see the QRCodeType class for more information
  String date; //The date the QR Code was scanned or generated formatted as kk:mm:ss \n EEE d MMM
  QREncryptionType qrEncryptionType; //This field is simply used to know if the QR Code is encrypted or not
  String password; //The password of the encrypted QR Code if its encrypted, null if it isn't
  int generatedOrHistory; //if the value is 1 means it is generated, 0 means it is scanned
  //SMS Data
  String smsTelNumber;
  String smsText;
  //WhatsApp Data
  String whatsAppTelNumber;
  String whatsAppText;
  //Geo Location QR Code Data
  String geoLat;
  String geoLng;
  //Crypto data
  String cryptoMessage;
  String cryptoAmount;
  String cryptoAddress;
  int isFav;
  String image;

  //Initializer
  QRCodeData({this.cryptoMessage, this.cryptoAmount, this.cryptoAddress, this.whatsAppTelNumber, this.whatsAppText, this.id, this.isFav, this.textData, this.qrCodeType, this.date,
      this.qrEncryptionType, this.password, this.generatedOrHistory,
      this.smsTelNumber, this.smsText, this.geoLat, this.geoLng, this.image});

  //Function that takes map and turns it into the data
  QRCodeData fromMap(Map map) {
    return QRCodeData(
      id: map['id'],
      isFav: map['isFav'],
      textData: map['text_data'].toString(),
      qrCodeType: QRCodeType.values[map['qr_code_type']],
      date: map['date'].toString(),
      qrEncryptionType: QREncryptionType.values[map['qr_encryption_type']],
      password: map['password'].toString(),
      generatedOrHistory: map['generated_or_history'],
      smsTelNumber: map['sms_tel_number'].toString(),
      smsText: map['sms_text'].toString(),
      geoLat: map['geo_lat'].toString(),
      geoLng: map['geo_lng'].toString(),
      whatsAppTelNumber: map['whatsAppTelNumber'].toString(),
      whatsAppText: map['whatsAppText'].toString(),
      image: map['image'].toString(),
      cryptoAddress: map['cryptoAddress'].toString(),
      cryptoAmount: map['cryptoAmount'].toString(),
      cryptoMessage: map['cryptoMessage'].toString(),
    );
  }
  //Function that returns a map from the QR Code Data
  //Used in saving data to sqlite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isFav' : isFav==null?0:isFav,
      'text_data':textData.toString(),
      'qr_code_type': qrCodeType.index,
      'date':date.toString(),
      'qr_encryption_type':qrEncryptionType.index,
      'password':password.toString(),
      'generated_or_history':generatedOrHistory,
      'sms_tel_number':smsTelNumber.toString(),
      'sms_text':smsText.toString(),
      'geo_lat':geoLat.toString(),
      'geo_lng':geoLng.toString(),
      'whatsAppTelNumber':whatsAppTelNumber.toString(),
      'whatsAppText':whatsAppText.toString(),
      'image':image.toString(),
      'cryptoAmount':cryptoAmount.toString(),
      'cryptoMessage':cryptoMessage.toString(),
      'cryptoAddress':cryptoAddress.toString(),
    };
  }

}