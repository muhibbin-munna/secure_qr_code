/*
 * Copyright (c) 2020 EmyDev
 */

import 'package:flutter/material.dart';

//Page that takes title and icon as a parameter
abstract class BasePage extends StatefulWidget {
  BasePage({Key key, this.title, this.icon}) : super(key: key);

   final String title;

   final IconData icon;

}