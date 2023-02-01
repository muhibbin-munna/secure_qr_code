/*
 * Copyright (c) 2020 EmyDev
 */

import 'package:flutter/material.dart';
//The data for the tabs
class TabIconData {
  TabIconData({ //Constructor
    this.imagePath = '',
    this.index = 0,
    this.selectedImagePath = '',
    this.isSelected = false,
    this.animationController,
  });

  String imagePath; //Location of image when not selected
  String selectedImagePath; //Location of image when selected
  bool isSelected; //If the tab is selected
  int index; //It's index between all the tabs

  AnimationController animationController; //Animation controller for tab animation

  static List<TabIconData> tabIconsList = <TabIconData>[ //List of Tabs
    TabIconData(
      imagePath: 'assets/tabs/tab_1.png',
      selectedImagePath: 'assets/tabs/tab_1s.png',
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/tabs/tab_2.png',
      selectedImagePath: 'assets/tabs/tab_2s.png',
      index: 1,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/tabs/tab_3.png',
      selectedImagePath: 'assets/tabs/tab_3s.png',
      index: 2,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/tabs/tab_4.png',
      selectedImagePath: 'assets/tabs/tab_4s.png',
      index: 3,
      isSelected: false,
      animationController: null,
    ),
  ];
}
