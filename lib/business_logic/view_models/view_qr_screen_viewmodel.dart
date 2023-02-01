/*
 * Copyright (c) 2020 EmyDev
 */
import 'dart:convert';

import 'package:barcode/barcode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:QRLock/utils/encryption.dart';
import 'package:QRLock/utils/utils.dart';
import 'package:QRLock/services/service_locator.dart';

import 'history_screen_viewmodel.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart' as Image;

// This class handles the generation of QR code image.

class ViewQRScreenViewModel extends ChangeNotifier {
  HistoryScreenViewModel model = serviceLocator<HistoryScreenViewModel>();

  Image.Image _qrImage;

  Image.Image get qrImage => _qrImage;
  //Generate QR Code
  Future<int> generateSaveQRCodeImage(QRCodeData plainData,
      {bool save = false}) async {
    int id = -1;
    Image.Image data = await _generate(plainData); //Get QR Code raw data

    _qrImage = data; //Turn raw data into image

    if (save) {
      id = await model.addGeneratedData(plainData); //Add generated data
    }

    notifyListeners(); //Notify listeners to update views

    return id;
  }

  Future<Image.Image> _generate(QRCodeData qrCodeData) async {
    String actionTextData =
        Utils.getQrActionText(qrCodeData); // get qr code data string
    if (qrCodeData.qrEncryptionType == QREncryptionType.ENCRYPTED) {
      actionTextData = Cryptography.encrypt(
          actionTextData, qrCodeData.password); //encrypt qr code
    }
    // Create an image
    final image = Image.Image(500, 500);

    // Fill it with a solid color (white)
    Image.fill(image, Image.getColor(255, 255, 255));

    // Draw the barcode
    drawBarcode(image, Barcode.qrCode(
      errorCorrectLevel: BarcodeQRCorrectionLevel.high
    ), actionTextData, x:50, y:50, width: 400, height: 400, font: Image.arial_24);
    if(qrCodeData.image.toString() != "null") {
      Image.Image overlayImage = Image.decodeImage(
          base64Decode(qrCodeData.image));
      Image.Image overlay = Image.Image(100, 100);
      Image.drawImage(overlay, overlayImage);
      Image.copyInto(image, overlay, dstX: ((500-(overlay.width))/2).round(),
          dstY: ((500-(overlay.height))/2).round());
    }
    return image;
  }

  updateFav(QRCodeData plainData) async {
    await model.toggleFavorite(plainData);
    notifyListeners();
  }
}
