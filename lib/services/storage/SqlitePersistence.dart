/*
 * Copyright (c) 2020 EmyDev
 */

import 'package:path/path.dart';
import 'package:QRLock/business_logic/models/qr_code_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

// singleton class to manage the database
class DatabaseHelper {

  // This is the actual database filename that is saved in the docs directory.
  static const DatabaseName = 'qr_codes.db';

  static const QRCodeDataTableName = 'qr_code_data';

  Database db;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;

  DatabaseHelper();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // Open the database, can also add an onUpdate callback parameter.
    return await openDatabase(
      join(await getDatabasesPath(), DatabaseName),
      onCreate: (db, version) {
        return db.execute(
          '''CREATE TABLE $QRCodeDataTableName(
            id Integer PRIMARY KEY AUTOINCREMENT, 
            isFav Integer,
            text_data String,
            qr_code_type Integer, 
            date String, 
            qr_encryption_type Integer,
            password String,
            generated_or_history Integer,
            sms_tel_number String,  
            sms_text text,
            whatsAppTelNumber String,
            whatsAppText text,
            cryptoMessage text,
            cryptoAmount String,
            cryptoAddress String,
            geo_lat String,
            geo_lng String,
            image String,
            v_card_name String,
            v_card_company String,
            v_card_title	String,
            v_card_phone_number String,	
            v_card_email	 String,	
            v_card_address	 String,	
            v_card_address2	 String,	
            v_card_website	 String,	
            v_card_memo String
            );
          ''',
        );
      },
      version: 1,
    );
  }

  Future<List<Map<String, dynamic>>> getHistoryItems() async {
    Database db = await database;
    final ret = await db.rawQuery(
        'SELECT * FROM $QRCodeDataTableName '
            'where generated_or_history = ?', ['0']);
    return ret;
  }

  Future<List<Map<String, dynamic>>> getGeneratedItems() async {
    Database db = await database;
    final ret = await db.rawQuery(
        'SELECT * FROM $QRCodeDataTableName '
            'where generated_or_history = ?', ['1']);
    return ret;
  }


  Future<int> insertQRCodeData(QRCodeData qrData) async {
    Database db = await database;
    return await db.insert(QRCodeDataTableName, qrData.toMap());
  }

  deleteAllQRData(int generatedOrHistory) async {
    Database db = await database;
    final ret = await db.rawQuery(
        'DELETE FROM $QRCodeDataTableName '
            'where generated_or_history = ?', [generatedOrHistory]);
    return ret;
  }

  void updateItem(int id, int isFav) async {
    Database db = await database;
    await db.rawQuery(
        'UPDATE $QRCodeDataTableName SET isFav = ? '
            'where id = ?', [isFav, id]);
  }

  deleteAllFavorite() async {
    Database db = await database;
    await db.rawQuery(
        'UPDATE $QRCodeDataTableName SET isFav = ? ', ['0']);
  }

}

