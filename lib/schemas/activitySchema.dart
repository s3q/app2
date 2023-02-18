import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActivitySchema {
  int createdAt;
  int lastUpdate;
  bool isActive;
  bool disabled;
  bool verified;
  double lat;
  double lng;
  List images;
  String title;
  String Id;
  String category;
  int viewsCount;
  int likesCount;
  String userId;
//   String pricesDescription;
  String priceNote;
  List prices;
  String phoneNumberCall;
  List dates;
  String? phoneNumberWhatsapp;
  String description;
  String importantInformation;
  String address;
  List availableDays;
  bool cTrippointChat;
  List reviews;
  String? storeId;
  int callsCount;
  int sharesCount;
  int chatsCount;

//   Map<String, int> suitableAges;
  Map suitableAges;
  Map genderSuitability;
//   Map<String, bool> genderSuitability;
  bool op_GOA;

  List tags;

  ActivitySchema({
    this.storeId,
    required this.createdAt,
    required this.isActive,
    required this.disabled,
    required this.verified,
    required this.lastUpdate,
    required this.userId,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.callsCount = 0,
    this.sharesCount = 0,
    this.chatsCount = 0,
    required this.dates,
    required this.Id,
    required this.lat,
    required this.lng,
    required this.address,
    required this.availableDays,
    this.phoneNumberWhatsapp,
    required this.phoneNumberCall,
    required this.description,
    required this.images,
    required this.importantInformation,
    required this.cTrippointChat,
    required this.category,
    required this.priceNote,
    required this.prices,
    required this.op_GOA,
    required this.title,
    required this.reviews,
    required this.suitableAges,
    required this.genderSuitability,
    required this.tags,
  });

    static ActivitySchema toSchema(Map data) {
    return ActivitySchema(
        createdAt: data["createdAt"],
        isActive: data["isActive"],
        verified: data["verified"],
        disabled: data["disabled"],
        lastUpdate: data["lastUpdate"],
        userId: data["userId"],
        dates: data["dates"]  ?? [],
        Id: data["Id"],
        lat: data["lat"],
        lng: data["lng"],
        address: data["address"],
        availableDays: data["availableDays"]  ?? [],
        phoneNumberCall: data["phoneNumberCall"],
        description: data["description"],
        images: data["images"]  ?? [],
        importantInformation: data["importantInformation"],
        cTrippointChat: data["cTrippointChat"],
        category: data["category"],
        priceNote: data["priceNote"],
        prices: data["prices"]  ?? [],
        op_GOA: data["op_GOA"],
        title: data["title"],
        reviews: data["reviews"] ?? [],
        suitableAges: data["suitableAges"],
        genderSuitability: data["genderSuitability"],
        viewsCount: data["viewaCount"] ?? 0,
        callsCount: data["callsCount"] ?? 0,
        likesCount: data["likesCount"] ?? 0,
        sharesCount: data["sharesCount"] ?? 0,
        chatsCount: data["chatsCount"] ?? 0,
        phoneNumberWhatsapp: data["phoneNumberWhatsapp"],
        storeId: data["storeId"], 
        tags: data["tags"]
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "Id": Id,
      "createdAt": createdAt,
      "isActive": isActive,
      "lastUpdate": lastUpdate,
      "availableDays": availableDays,
      "viewCount": viewsCount,
      "likesCount": likesCount,
      "callsCount": callsCount,
      "sharesCount": sharesCount,
      "chatsCount": chatsCount,
      "userId": userId,
      "dates": dates,
      "lat": lat,
      "lng": lng,
      "address": address,
      "phoneNumberCall": phoneNumberCall,
      "phoneNumberWhatsapp": phoneNumberWhatsapp,
      "description": description,
      "images": images,
      "importantInformation": importantInformation,
      "cTrippointChat": cTrippointChat,
      "category": category,
      "priceNote": priceNote,
      "prices": prices,
      "op_GOA": op_GOA,
      "suitableAges": suitableAges,
      "genderSuitability": genderSuitability,
      "reviews": reviews,
      "title": title,
      "tags": tags,
    };
  }
}
