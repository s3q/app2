import 'dart:math';

import 'package:flutter/material.dart';

class UserSchema {
  String? email;
  String name;
  int? lastLogin;
  int? createdAt;
  String Id;
  String? storeId;
  String? providerId;
  String? phoneNumber;
  Map<String, dynamic>? deviceInfo;
  String? displaySizes;
  Map<dynamic, dynamic>? proAccount;
  int? dateOfBirth;
  bool isProAccount;
  String? gender;
  String ip;
  List? chatList;
  String? profileImagePath;
  int? profileColor;
  String? city;

  List? wishlist;

  static List colors = [
    0xFFFFE082,
    0xFF90CAF9,
    0xFFB39DDB,
    0xFFEF9A9A,
    0xFF18FFFF,
    0xFFEEEEEE
  ];
  UserSchema({
    this.storeId,
    this.email,
    required this.name,
    this.lastLogin,
    this.createdAt,
    required this.Id,
    this.providerId,
    this.phoneNumber,
    this.deviceInfo,
    this.displaySizes,
    this.dateOfBirth,
    this.proAccount,
    this.isProAccount = false,
    this.gender,
    this.chatList,
    required this.ip,
    this.profileColor,
    this.profileImagePath,
    this.city,
     this.wishlist,
  });

  Map<String, dynamic> toMap() {
    return {
        "storeId": storeId,
      "email": email,
      "name": name,
      "lastLogin": lastLogin,
      "createdAt": createdAt,
      "Id": Id,
      "providerId": providerId,
      "phoneNumber": phoneNumber,
      "deviceInfo": deviceInfo,
      "displaySizes": displaySizes,
      "dateOfBirth": dateOfBirth,
      "proAccount": proAccount,
      "isProAccount": isProAccount,
      "gender": gender,
      "chatList": chatList,
      "ip": ip,
      "profileColor": colors[Random().nextInt(colors.length)],
      "profileImagePath": profileImagePath,
      "city": city,
      "wishlist": wishlist,
    };
  }
}
