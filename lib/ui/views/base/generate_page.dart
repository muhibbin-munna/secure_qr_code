/*
 * Copyright (c) 2020 EmyDev
 */

import 'package:QRLock/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:QRLock/business_logic/models/qr_code_data.dart';
//Page that has a submit function
abstract class GeneratePage extends StatefulWidget{
  GeneratePage({Key key, this.qrCodeType}): super(key:key);
  final QRCodeType qrCodeType;
}
//State that has a submit
abstract class GenerateState extends State<GeneratePage>{
  QRCodeData submit();
}