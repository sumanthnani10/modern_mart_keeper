import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Storage {
  static List<DocumentSnapshot> productsList;
  static List<String> categories = [];
  static Map<String, dynamic> products = new Map<String, dynamic>();
  static Map<String, dynamic> shopDetails = new Map<String, dynamic>();
  static List<dynamic> sliders = [];
  static Map<String, dynamic> customers = new Map<String, dynamic>();

  static const APP_NAME = 'Modern Mart';
  static const APP_COLOR = Colors.lightBlueAccent;
  static const APP_LOCATION = 'nandigama';
  static const APP_NAME_ = 'modern_mart';
  static const APP_LATITUDE = 16.76818;
  static const APP_LONGITUDE = 80.29094;

  static getImageURL(id) {
    return 'https://firebasestorage.googleapis.com/v0/b/modern-mart.appspot.com/o/Images%2Fmodern_mart_nandigama%2Fproducts%2F' +
        id +
        '?alt=media&token=';
  }
}
