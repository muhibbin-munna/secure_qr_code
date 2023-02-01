/*
 * Copyright (c) 2020 EmyDev
 */


import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:QRLock/utils/utils.dart';
import 'package:QRLock/services/service_locator.dart';
import 'package:QRLock/services/storage/SqlitePersistence.dart';


// This class handles the history loading from the storage and displaying it in a form convenient
// for displaying on a list.

class HistoryScreenViewModel extends ChangeNotifier {

  final DatabaseHelper _storageService = serviceLocator<DatabaseHelper>();

  List<HistoryItemPresenter> _historyItems;
  List<HistoryItemPresenter> _generatedItems;
  List<HistoryItemPresenter> _favoriteItems;

  //returns the history items list
  List<HistoryItemPresenter> get historyItems {
    return _historyItems;
  }

  //returns the history items list
  List<HistoryItemPresenter> get favoriteItems {
    return _favoriteItems;
  }

  //returns the generated items list
  List<HistoryItemPresenter> get generatedItems {
    return _generatedItems;
  }

  //Get the history data from sqlite
  void refreshData() async {

    if(_historyItems!=null)
      _historyItems.clear(); //Clear the old history items
    else
      _historyItems = [];

    if(_generatedItems!=null)
      _generatedItems.clear(); //Clear old generated items
    else
      _generatedItems = [];

    if(_favoriteItems!=null)
      _favoriteItems.clear(); //Clear the old favorite items
    else
      _favoriteItems = [];

    List<QRCodeData> _qrHistoryItems = await _loadHistoryItemsDB(); //Load the items from DB
    _refreshItemPresenters(_qrHistoryItems, 0);

    List<QRCodeData> _qrGeneratedItems = await _loadGeneratedItemsDB(); //Load Generated Items from DB
    _refreshItemPresenters(_qrGeneratedItems, 1);

    notifyListeners(); //notify listeners to update data in views
  }

  void _refreshItemPresenters(items, int generatedOrHistory) {
    for (int i = items.length - 1; i >= 0; i--) {
      AssetImage icon = Utils.getIconType(
          items[i].qrCodeType); //Get Icon to display in listview
      HistoryItemPresenter itemPresenter = HistoryItemPresenter(items[i], icon);

      if(itemPresenter.qrCodeDataItem.isFav == 1) {
        _favoriteItems.add(itemPresenter); //add presenter to favorite items
      }

      if (generatedOrHistory == 1) {
        _generatedItems.add(itemPresenter); //add presenter to generated items
      }
      else {
        _historyItems.add(itemPresenter); //add presenter to history items
      }
    }
  }


  //Add generated QR Code to DB
  Future<int> addGeneratedData(QRCodeData qrCodeData) async {
    //save to storage
    int id = await _storageService.insertQRCodeData(qrCodeData);

    refreshData();
    return id;
  }
  //Add scanned QR Code to DB
  Future<void> addHistoryData(QRCodeData qrCodeData) async {
    //save to storage
    await _storageService.insertQRCodeData(qrCodeData);

    refreshData();
  }
  //Get history items from DB
  Future<List<QRCodeData>> _loadHistoryItemsDB() async {
    final objects  =  await _storageService.getHistoryItems();
    return objects.map((map) => QRCodeData().fromMap(map)).toList();
  }
  //Get generated items from DB
  Future<List<QRCodeData>> _loadGeneratedItemsDB() async {
    final objects  =  await _storageService.getGeneratedItems();
    return objects.map((map) => QRCodeData().fromMap(map)).toList();
  }

  //clears all history items in db
  Future<void> clearAllGeneratedHistory(int generatedOrHistory) async{

    await _storageService.deleteAllQRData(generatedOrHistory);

    refreshData();

  }

  //clears all history items in db
  Future<void> clearAllFavorite() async{

    await _storageService.deleteAllFavorite();

    refreshData();
  }

  //Add generated QR Code to DB
  Future<void> toggleFavorite(QRCodeData qrCodeData) async {
    //save to storage
    int isFav = qrCodeData.isFav==1?0:1;
    _storageService.updateItem(qrCodeData.id, isFav);

    refreshData();
  }




}
//Presenter class to be shown in listview
class HistoryItemPresenter
{
  QRCodeData qrCodeDataItem; //The item
  AssetImage icon; //The Icon
  //Constructor
  HistoryItemPresenter(this.qrCodeDataItem, this.icon);

}
