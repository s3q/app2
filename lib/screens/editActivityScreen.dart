import 'dart:io';
import 'dart:typed_data';

import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/screens/activityCreatedScreen.dart';
import 'package:oman_trippoint/screens/homeScreen.dart';
import 'package:oman_trippoint/screens/pickLocationScreen.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:oman_trippoint/widgets/checkboxWidget.dart';
import 'package:oman_trippoint/widgets/dividerWidget.dart';
import 'package:oman_trippoint/widgets/inputTextFieldWidget.dart';
import 'package:oman_trippoint/widgets/loadingWidget.dart';
import 'package:oman_trippoint/widgets/pickupLocationWidget.dart';
import 'package:oman_trippoint/widgets/snakbarWidgets.dart';
import 'package:oman_trippoint/widgets/uploadDatesBoxWidget.dart';
import 'package:oman_trippoint/widgets/uploadImagePagesWidget.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:translator/translator.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

enum BestTutorSite { Days, Dates }

class EditActivityScreen extends StatefulWidget {
  static String router = "edit_activity";
  const EditActivityScreen({super.key});

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late String Id;
  int count = 0;

  final _phoneNumberWhatsappController = TextEditingController();
  final _phoneNumberCallController = TextEditingController();

  PageController pageViewController = PageController(initialPage: 0);

  bool _checkboxChatT = true;
  final _checkboxChatW = ValueNotifier<bool>(false);
  final _checkboxChatC = ValueNotifier<bool>(true);
  final _instagramCheck = ValueNotifier<bool>(false);
  final _daysOrDatesCheck = ValueNotifier<bool>(true);
  final _avilableDates = ValueNotifier<List>([]);
  bool _checkboxOp_SFC = true;
  bool _checkboxOp_GOA = true;
  bool _checkboxOp_SCT = false;

  bool _isLoading = false;
//   List overlay = [];

  final _uploadedImagesPath = ValueNotifier<List<String>>([]);
  Map<int, String> uploadedumagesPath = {};
  List deletedImagesPath = [];

  String? errorInUploadImages;
  final _errorMassage = ValueNotifier<String?>(null);

  List _categories = AppHelper.categories.map((e) => e["title"]).toList();

  Map<String, dynamic> data = {};
  Map<String, int?> suitableAges = {};
  Map<String, dynamic> genderSuitability = {};

  Map<String, dynamic> prices = {};

  List dates = [];

  Map weekDays = {
    "sunday": false,
    "monday": false,
    "tuesday": false,
    "wednesday": false,
    "thursday": false,
    "friday": false,
    "saturday": false,
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _pickImage() async {
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      images.forEach((e) {
        _uploadedImagesPath.value = [e.path, ..._uploadedImagesPath.value];
      });
    }
  }

  void removeUploadedImage(value) {
    bool re = _uploadedImagesPath.value.remove(value);
    print(re);
  }

  void bookmarkMainPhoto(value) {
    _uploadedImagesPath.value.remove(value);
    _uploadedImagesPath.value.insertAll(0, value);
    print("Home");
  }

  Future _submit(BuildContext context, ActivitySchema activitySchema) async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    try {
      ActivityProvider activityProvider =
          Provider.of<ActivityProvider>(context, listen: false);
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      bool validation = _formKey.currentState!.validate();

      Map<String, dynamic> activityData = activitySchema.toMap();
      if (data["lat"] == null || data["lng"] == null) {
        SnakbarWidgets.error(
            context,
            AppHelper.returnText(context, "Add your tourism activity location",
                "أضف موقع نشاطك السياحي"));
        throw 99;
      }
      if (validation) {
        _formKey.currentState!.save();

        if (_daysOrDatesCheck.value) {
          dates = [];
        } else {
          for (var d in weekDays.keys) {
            weekDays[d] = false;
          }
        }

        data["prices"] = prices.values.toList();
        data["genderSuitability"] = genderSuitability;
        data["dates"] = dates;

        data["suitableAges"]["max"] = suitableAges["max"];
        data["suitableAges"]["min"] = suitableAges["min"];

        data["availableDays"] = weekDays.keys.map((v) {
          if (weekDays[v] == true) {
            print(v);
            return v;
          }
        }).toList();

        //   data["availableDays"] = data["availableDays"].map((e) {
        //     if (e != null && e?.toString().trim() != "") {
        //       return e;
        //     }
        //   }).toList();

        //   data["availableDays"].removeWhere(((key, value) => value == null));
        data["availableDays"]
            .removeWhere((e) => e == null || e?.toString().trim() == "");
        data["dates"]
            .removeWhere((e) => e == null || e?.toString().trim() == "");

        print(data["availableDays"]);

        print(uploadedumagesPath);

        setState(() {
          _isLoading = true;
        });

        //   overlay = AppHelper.showOverlay(context, LoadingWidget());

        String Id = data["Id"];
        for (var cimage in activitySchema.images) {
          if (!uploadedumagesPath.containsValue(cimage)) {
            deletedImagesPath.add(cimage);
          }
        }
        data["images"] = [];
        for (var cacheImage in uploadedumagesPath.values) {
          if (cacheImage.trim() == "" || cacheImage == null) {
            //   uploadedumagesPath.remove(e);
            continue;
          }

          String prefix =
              uploadedumagesPath.values.singleWhere((e) => e == cacheImage) == 0
                  ? "main"
                  : "regu";

          if (!cacheImage.startsWith("http")) {
            String path =
                "${ActivityProvider.collection}/$Id/displayImages/${prefix + const Uuid().v4()}.jpg";
            final storageRef = FirebaseStorage.instance.ref(path);
            File file = File(cacheImage);
            print("cacheImage 000 images ");

            await storageRef.putFile(file).then((p0) async {
              await p0.ref
                  .getDownloadURL()
                  .then((value) => data["images"].add(value));
            });
          } else if (!deletedImagesPath.contains(cacheImage)) {
            print("Network 000 images ");
            print(cacheImage);
            data["images"].add(cacheImage);
          }
          // return path;

          print("delete images");
          print(deletedImagesPath);
        }
        for (String l in deletedImagesPath) {
          try {
            if ((l
                            .toString()
                            .split(
                                "/activites/${activitySchema.Id}/displayImages/")
                            .length ==
                        2 ||
                    l
                            .toString()
                            .split(
                                "/activites%2F${activitySchema.Id}%2FdisplayImages%2F")
                            .length ==
                        2) &&
                l.toString() != "") {
              String imageName = l
                          .toString()
                          .split(
                              "/activites/${activitySchema.Id}/displayImages/")
                          .length ==
                      1
                  ? l
                      .toString()
                      .split("/activites%2F${activitySchema.Id}%2FdisplayImages%2F")[
                          1]
                      .split(".jpg")[0]
                  : l
                      .toString()
                      .split(
                          "/activites/${activitySchema.Id}/displayImages/")[1]
                      .split(".jpg")[0];

              Reference ref = FirebaseStorage.instance.ref(
                  "activites/${activitySchema.Id}/displayImages/$imageName.jpg");

              await ref.delete();
            }
          } catch (err) {
            print(err);
          }
        }
        data["images"].removeWhere((e) => e == null);

        // activityData.images = uploadedumagesPath.values.toList();
        data.remove("reviews");
        print(data);

        data = data.map((key, value) {
          if (activityData[key] != data[key]) {
            return MapEntry(key, value);
          }
          return MapEntry(key, data[key]);
        });

        // $ ------------------------ translate ---------------------
        List tags = [];
        GoogleTranslator translator = GoogleTranslator();
        print(data["title"]);
        print("translate");

        await translator
            .translate(data["title"], from: "auto", to: "ar")
            .then((value) => tags.add(value.text));
        await translator
            .translate(data["title"], from: "auto", to: "en")
            .then((value) => tags.add(value.text));

        await translator
            .translate(data["address"], from: "auto", to: "ar")
            .then((value) => tags.add(value.text));
        await translator
            .translate(data["address"], from: "auto", to: "en")
            .then((value) => tags.add(value.text));

        tags.add(data["address"].toString().tr());

        data["tags"] = tags;
        // $ ----------------------------------------------------------

        data.removeWhere(((key, value) => value == null));

        print(data);

        ActivitySchema updatedActivitySchema = ActivitySchema.toSchema(data);
        print(updatedActivitySchema);

        bool done = await activityProvider.updateActivityData(
            context: context,
            data: updatedActivitySchema.toMap(),
            activityStoreId: activitySchema.storeId.toString());

        setState(() {
          _isLoading = false;
        });

        if (done == false) {
          throw 99;
        }

        //   overlay[1].remove();

        EasyLoading.showSuccess('Saved');

        await FirebaseFunctions.instance
            .httpsCallable("increaseCountersAppStatistics")
            .call({
          "year": AppHelper.currentYear,
          "field": "editedActivitiesCount",
        });

        Navigator.pushNamedAndRemoveUntil(context, HomeScreen.router, (route) {
          return false;
        });

        print("Done");
      }
    } catch (err) {
      print(err);
      _errorMassage.value = err.toString();
      //   Navigator.pushNamedAndRemoveUntil(context, HomeScreen.router, (route) {
      //     return false;
      //   });
      EasyLoading.showError(
          AppHelper.returnText(context, "Something wrong", "حدث خطأ ما"));
    }
    await Future.delayed(const Duration(milliseconds: 1500));
    EasyLoading.dismiss();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // EasyLoading.dismiss();

    // overlay[0].dispose();
  }

  List wilaayatsAndRegion = [];
  final pricesCount = ValueNotifier<List>([
    1,
  ]);
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);

    if (userProvider.currentUser?.isProAccount == false &&
        userProvider.proCurrentUser == null) {
      return SafeScreen(
          child: Center(
        child: Text(AppHelper.returnText(context,
            "You should have been logging in.", ".يجب أن تقوم بتسجيل الدخول")),
      ));
    } else if (userProvider.currentUser?.isProAccount == false ||
        userProvider.proCurrentUser == null) {
      print("user");
      //  ! error code
    }

    _phoneNumberCallController.text =
        userProvider.proCurrentUser!.publicPhoneNumber;
    _phoneNumberWhatsappController.text =
        userProvider.proCurrentUser!.publicPhoneNumber;

    // !!!!! init code

    ActivitySchema activitySchema =
        ModalRoute.of(context)!.settings.arguments as ActivitySchema;
    if (count == 0) {
      for (var r in AppHelper.wilayats.keys.toList()) {
        wilaayatsAndRegion.addAll([r, ...AppHelper.wilayats[r]]);
      }

      activitySchema.images.asMap().map((key, value) {
        uploadedumagesPath[key + 1] = value;

        return MapEntry(key, value);
      });

      print(uploadedumagesPath);
      //   uploadedumagesPath = activitySchema.images.asMap() as Map<int, String>;

      data = activitySchema.toMap();

      weekDays = weekDays.map((key, value) {
        if (activitySchema.availableDays.contains(key)) {
          return MapEntry(key, true);
        }
        return MapEntry(key, value);
      });

      dates = data["dates"];

      prices = activitySchema.prices.asMap().map((key, value) {
        // prices["${key + 1}"] = value;

        return MapEntry("${key + 1}", value);
      });
      print(prices);

      _checkboxChatT = activitySchema.cTrippointChat;
      _checkboxChatW.value = activitySchema.phoneNumberWhatsapp != null &&
              activitySchema.phoneNumberWhatsapp.toString().trim() != ""
          ? true
          : false;
      _checkboxOp_GOA = activitySchema.op_GOA;
      _checkboxChatC.value =
          activitySchema.phoneNumberCall.trim() != "" ? true : false;

      genderSuitability = data["genderSuitability"];

      suitableAges["max"] = data["suitableAges"]["max"];
      suitableAges["min"] = data["suitableAges"]["min"];
      count = 1;
    }

    print(data["category"].toString().tr());
    print(_categories[0].toString().tr());

    return SafeScreen(
      padding: 0,
      child: Column(
        children: [
          AppBarWidget(
            title:
                AppHelper.returnText(context, "Edit Activity", "تعديل النشاط"),
          ),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                const SizedBox(
                  height: 30,
                ),
                AbsorbPointer(
                  absorbing: _isLoading,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        //   OutlinedButton.icon(
                        //     icon: Icon(Icons.photo_camera_back_outlined),
                        //     label: const Text("Add photos"),
                        //     onPressed: () async {
                        //       setState(() {
                        //         errorInUploadImages = null;
                        //       });
                        //       _pickImage();
                        //     },
                        //   ),
                        //   if (errorInUploadImages != null)
                        //     Text(errorInUploadImages!),
                        UploadImagePagesWidget(
                            imagesPath: uploadedumagesPath,
                            onImageAdded: (images) {
                              uploadedumagesPath = images;
                              print(uploadedumagesPath);
                            }),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              InputTextFieldWidget(
                                text: data["title"],
                                labelText: AppHelper.returnText(
                                    context, "Title *", "العنوان *"),
                                helperText: AppHelper.returnText(
                                    context,
                                    "Give your activity a title.",
                                    "ضع لنشاطك عنوانًا."),
                                validator: (val) {
                                  print("Title !!!!!!!!!!");
                                  print(val);
                                  if (val == null) {
                                    return AppHelper.returnText(
                                        context,
                                        "Use 5 characters or more for the title",
                                        "استخدم 5 أحرف أو أكثر للعنوان");
                                  }
                                  if (val.trim() == "" || val.length < 5) {
                                    return AppHelper.returnText(
                                        context,
                                        "Use 5 characters or more for the title",
                                        "استخدم 5 أحرف أو أكثر للعنوان");
                                  }
                                  if (val.length > 100) {
                                    return AppHelper.returnText(
                                        context,
                                        "The title is too long",
                                        "العنوان طويل جدًا");
                                  }
                                  //   if (val.contains(r'[A-Za-z]')) {
                                  //     return "The name should only consist of letters";
                                  //   }
                                },
                                onSaved: (val) {
                                  data["title"] = val?.trim();
                                },
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              SearchField(
                                suggestions: _categories
                                    .map((e) => SearchFieldListItem(
                                        e.toString().trim().tr(),
                                        item: e.toString()))
                                    .toList(),
                                suggestionState: Suggestion.expand,
                                hint: AppHelper.returnText(context,
                                    'Choose Category *', "اختر التصنيف *"),
                                hasOverlay: true,
                                searchStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                validator: (x) {
                                  String? cat = AppHelper
                                      .categoriesAaE[x.toString().trim()];

                                  if (!_categories.contains(x) || x!.isEmpty) {
                                    if (cat != null) {
                                      data["category"] = cat.toString().trim();

                                      return null;
                                    }
                                    return AppHelper.returnText(
                                        context,
                                        'Please enter category from the list',
                                        "الرجاء إدخال فئة من القائمة");
                                  }

                                  //   data["category] = x.toString();
                                },
                                onSubmit: (p0) {
                                  print(p0);
                                },
                                searchInputDecoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black45,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black45),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                maxSuggestionsInViewPort: 6,
                                itemHeight: 40,
                                initialValue: SearchFieldListItem(
                                    data["category"].toString().trim().tr(),
                                    item: data["category"].toString().trim()),
                                onSuggestionTap: (x) {
                                  data["category"] = x.item.toString().trim();
                                },
                              ),

                              const SizedBox(
                                height: 40,
                              ),
                              Text(AppHelper.returnText(
                                  context,
                                  "You can add more than one price to your activity that suits your customers more.",
                                  "يمكنك إضافة أكثر من سعر إلى نشاطك بما يناسب عملائك أكثر.")),
                              const SizedBox(
                                height: 20,
                              ),

                              ValueListenableBuilder(
                                  valueListenable: pricesCount,
                                  builder: (context, value, child) {
                                    print(value);
                                    return Column(children: [
                                      Row(
                                        key: Key(Uuid().v4()),
                                        children: [
                                          Expanded(
                                            child: InputTextFieldWidget(
                                              text: prices["1"]?["price"],
                                              labelText: "OMR *",
                                              validator: (val) {
                                                bool empty = true;
                                                print(prices.values);
                                                prices.values.map((e) {
                                                  if (e != null) {
                                                    if (e.toString().trim() !=
                                                        "") {
                                                      empty = false;
                                                    }
                                                  }
                                                });
                                                if (val.toString().trim() !=
                                                    "") {
                                                  empty = false;
                                                }
                                                if (empty) {
                                                  return AppHelper.returnText(
                                                      context,
                                                      "One price at least",
                                                      "سعر واحد على الأقل");
                                                }

                                                if (val.length > 10) {
                                                  return AppHelper.returnText(
                                                      context,
                                                      "Too long",
                                                      "النص طويل جدا");
                                                }
                                                if (AppHelper.isNumeric(
                                                    val.toString())) {
                                                  return AppHelper.returnText(
                                                      context,
                                                      "English numbers only",
                                                      "ارقام انجليزية فقط");
                                                }

                                                //   if (val.contains(r'[A-Za-z]')) {
                                                //     return "The name should only consist of letters";
                                                //   }
                                                return null;
                                              },
                                              onSaved: (val) {
                                                prices["1"] = {
                                                  "price": val?.trim(),
                                                };
                                              },
                                              onChanged: (val) {
                                                prices["1"] = {
                                                  "price": val?.trim(),
                                                };
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: InputTextFieldWidget(
                                              text: prices["1"]?["des"],
                                              labelText: AppHelper.returnText(
                                                  context,
                                                  "Description *",
                                                  "الوصف *"),
                                              validator: (val) {
                                                if (prices["1"]?["price"] !=
                                                    null) {
                                                  if (val == null)
                                                    return AppHelper.returnText(
                                                        context,
                                                        "Type the description",
                                                        "اكتب الوصف");
                                                  if (val.trim() == "" ||
                                                      val.length < 1)
                                                    return AppHelper.returnText(
                                                        context,
                                                        "Type the description",
                                                        "اكتب الوصف");
                                                }
                                                if (val.length > 50) {
                                                  return AppHelper.returnText(
                                                      context,
                                                      "Too long",
                                                      "النص طويل جدا");
                                                }
                                                //   if (val.contains(r'[A-Za-z]')) {
                                                //     return "The name should only consist of letters";
                                                //   }
                                                return null;
                                              },
                                              onSaved: (val) {
                                                if (prices["1"]?["price"] !=
                                                    null) {
                                                  prices["1"] = {
                                                    "price": prices["1"]
                                                        ?["price"],
                                                    "des": val?.trim(),
                                                  };
                                                }
                                              },
                                              onChanged: (val) {
                                                if (prices["1"]?["price"] !=
                                                    null) {
                                                  prices["1"] = {
                                                    "price": prices["1"]
                                                        ?["price"],
                                                    "des": val?.trim(),
                                                  };
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (pricesCount.value.contains(2))
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      if (pricesCount.value.contains(2))
                                        Row(
                                          key: Key(Uuid().v4()),
                                          children: [
                                            Expanded(
                                              child: InputTextFieldWidget(
                                                text: prices["2"]?["price"],
                                                labelText: "OMR ",
                                                validator: (val) {
                                                  //   if (val.contains(r'[A-Za-z]')) {
                                                  //     return "The name should only consist of letters";
                                                  //   }
                                                  if (val.length > 10) {
                                                    return AppHelper.returnText(
                                                        context,
                                                        "Too long",
                                                        "النص طويل جدا");
                                                  }
                                                  if (AppHelper.isNumeric(
                                                      val.toString())) {
                                                    return AppHelper.returnText(
                                                        context,
                                                        "English numbers only",
                                                        "ارقام انجليزية فقط");
                                                  }
                                                  return null;
                                                },
                                                onSaved: (val) {
                                                  if (val.toString().trim() !=
                                                      "") {
                                                    prices["2"] = {
                                                      "price": val?.trim(),
                                                    };
                                                  }
                                                },
                                                onChanged: (val) {
                                                  if (val.toString().trim() !=
                                                      "") {
                                                    prices["2"] = {
                                                      "price": val?.trim(),
                                                    };
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: InputTextFieldWidget(
                                                text: prices["2"]?["des"],
                                                labelText: AppHelper.returnText(
                                                    context,
                                                    "Description",
                                                    "الوصف"),
                                                validator: (val) {
                                                  if (prices["2"]?["price"] !=
                                                      null) {
                                                    if (val == null) {
                                                      return AppHelper.returnText(
                                                          context,
                                                          "Type the description",
                                                          "اكتب الوصف");
                                                    }

                                                    if (val.trim() == "" ||
                                                        val.length < 1) {
                                                      return AppHelper.returnText(
                                                          context,
                                                          "Type the description",
                                                          "اكتب الوصف");
                                                    }
                                                  }
                                                  if (val.length > 50) {
                                                    return AppHelper.returnText(
                                                        context,
                                                        "Too long",
                                                        "النص طويل جدا");
                                                  }
                                                  return null;
                                                },
                                                onSaved: (val) {
                                                  if (prices["2"]?["price"] !=
                                                      null) {
                                                    prices["2"] = {
                                                      "price": prices["2"]
                                                          ?["price"],
                                                      "des": val?.trim(),
                                                    };
                                                  }
                                                },
                                                onChanged: (val) {
                                                  if (prices["2"]?["price"] !=
                                                      null) {
                                                    prices["2"] = {
                                                      "price": prices["2"]
                                                          ?["price"],
                                                      "des": val?.trim(),
                                                    };
                                                  }
                                                },
                                              ),
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  prices.remove("2");
                                                  if (pricesCount.value
                                                      .contains(3)) {
                                                    pricesCount.value = [1, 3];
                                                  } else {
                                                    pricesCount.value = [
                                                      1,
                                                    ];
                                                  }
                                                },
                                                icon:
                                                    Icon(Icons.delete_rounded))
                                          ],
                                        ),
                                      if (pricesCount.value.contains(3))
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      if (pricesCount.value.contains(3))
                                        Row(
                                          key: Key(Uuid().v4()),
                                          children: [
                                            Expanded(
                                              child: InputTextFieldWidget(
                                                text: prices["3"]?["price"],
                                                labelText: "OMR",
                                                validator: (val) {
                                                  //   if (val.contains(r'[A-Za-z]')) {
                                                  //     return "The name should only consist of letters";
                                                  //   }
                                                  if (val.length > 10) {
                                                    return AppHelper.returnText(
                                                        context,
                                                        "Too long",
                                                        "النص طويل جدا");
                                                  }
                                                  if (AppHelper.isNumeric(
                                                      val.toString())) {
                                                    return AppHelper.returnText(
                                                        context,
                                                        "English numbers only",
                                                        "ارقام انجليزية فقط");
                                                  }

                                                  return null;
                                                },
                                                onSaved: (val) {
                                                  if (val.toString().trim() !=
                                                      "") {
                                                    prices["3"] = {
                                                      "price": val?.trim(),
                                                    };
                                                  }
                                                },
                                                onChanged: (val) {
                                                  if (val.toString().trim() !=
                                                      "") {
                                                    prices["3"] = {
                                                      "price": val?.trim(),
                                                    };
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: InputTextFieldWidget(
                                                text: prices["3"]?["des"],
                                                labelText: AppHelper.returnText(
                                                    context,
                                                    "Description",
                                                    "الوصف"),
                                                validator: (val) {
                                                  if (prices["3"]?["price"] !=
                                                      null) {
                                                    if (val == null) {
                                                      return AppHelper.returnText(
                                                          context,
                                                          "Type the description",
                                                          "اكتب الوصف");
                                                    }
                                                    if (val.trim() == "" ||
                                                        val.length < 1) {
                                                      return AppHelper.returnText(
                                                          context,
                                                          "Type the description",
                                                          "اكتب الوصف");
                                                    }
                                                  }
                                                  if (val.length > 50) {
                                                    return AppHelper.returnText(
                                                        context,
                                                        "Too long",
                                                        "النص طويل جدا");
                                                  }
                                                  return null;
                                                },
                                                onSaved: (val) {
                                                  if (prices["3"]?["price"] !=
                                                      null) {
                                                    prices["3"] = {
                                                      "price": prices["3"]
                                                          ?["price"],
                                                      "des": val?.trim(),
                                                    };
                                                  }
                                                },
                                                onChanged: (val) {
                                                  if (prices["3"]?["price"] !=
                                                      null) {
                                                    prices["3"] = {
                                                      "price": prices["3"]
                                                          ?["price"],
                                                      "des": val?.trim(),
                                                    };
                                                  }
                                                },
                                              ),
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  prices.remove("3");

                                                  pricesCount.value = [1, 2];
                                                },
                                                icon:
                                                    Icon(Icons.delete_rounded))
                                          ],
                                        ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      OutlinedButton.icon(
                                          icon: Icon(Icons.add_rounded),
                                          onPressed: () {
                                            if (pricesCount.value.length < 3) {
                                              //   pricesCount.value.add(
                                              //       pricesCount.value.length + 1);
                                              if (pricesCount.value.length ==
                                                      2 &&
                                                  !pricesCount.value
                                                      .contains(2)) {
                                                pricesCount.value = [
                                                  ...pricesCount.value,
                                                  2
                                                ];
                                                return;
                                              }
                                              pricesCount.value = [
                                                ...pricesCount.value,
                                                pricesCount.value.length + 1
                                              ];
                                            }
                                          },
                                          label: Text(AppHelper.returnText(
                                              context,
                                              "Add Price",
                                              "إضافة سعر")))
                                    ]);
                                  }),

                              const SizedBox(
                                height: 20,
                              ),
                              InputTextFieldWidget(
                                text: data["priceNote"],
                                textInputAction: TextInputAction.newline,
                                keyboardType: TextInputType.multiline,
                                labelText: AppHelper.returnText(
                                    context, "Price Notes ", "ملاحظات السعر"),
                                minLines: 4,
                                helperText: AppHelper.returnText(
                                    context,
                                    "You can add a description that explains the prices more.",
                                    "بامكانك اضافة وصف يوضح الاسعار أكثر. "),
                                validator: (val) {
                                  if (val.length > 500) {
                                    return AppHelper.returnText(
                                        context,
                                        "The text is too long",
                                        "النص طويل جدا");
                                  }
                                  return null;
                                },
                                onSaved: (val) {
                                  data["priceNote"] = val?.trim();
                                },
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              InputTextFieldWidget(
                                text: data["description"],
                                textInputAction: TextInputAction.newline,
                                keyboardType: TextInputType.multiline,
                                labelText: AppHelper.returnText(
                                    context, "Description", "الوصف"),
                                minLines: 4,
                                helperText: AppHelper.returnText(
                                    context,
                                    "Add more details about the activity.",
                                    "أضف المزيد من التفاصيل حول النشاط ."),
                                validator: (val) {
                                  //   if (val == null) {
                                  //     return AppHelper.returnText(
                                  //         context,
                                  //         "Use 10 characters or more for description",
                                  //         "استخدم 10 أحرف أو أكثر للوصف");
                                  //   }
                                  //   if (val.trim() == "" || val.length < 10) {
                                  //     return AppHelper.returnText(
                                  //         context,
                                  //         "Use 10 characters or more for description",
                                  //         "استخدم 10 أحرف أو أكثر للوصف");
                                  //   }
                                  if (val.length > 800) {
                                    return AppHelper.returnText(
                                        context,
                                        "The text is too long",
                                        "النص طويل جدا");
                                  }

                                  return null;
                                },
                                onSaved: (val) {
                                  data["description"] = val?.trim();
                                },
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              InputTextFieldWidget(
                                text: data["importantInformation"],
                                textInputAction: TextInputAction.newline,
                                keyboardType: TextInputType.multiline,
                                labelText: AppHelper.returnText(context,
                                    "Important Information", "معلومات مهمة"),
                                minLines: 4,
                                helperText: AppHelper.returnText(
                                    context,
                                    "Add information that the customer must follow",
                                    "أضف معلومات يجب ان يتبعها العميل"),
                                validator: (val) {
                                  //   if (val == null)
                                  //     return AppHelper.returnText(context, "Use 10 characters or more for important information", "استخدم 10 أحرف أو أكثر في المعلومات مهمة");
                                  //   if (val.trim() == "" || val.length < 10)
                                  //     return AppHelper.returnText(context, "Use 10 characters or more for important information", "استخدم 10 أحرف أو أكثر في المعلومات مهمة");

                                  if (val.length > 800) {
                                    return AppHelper.returnText(
                                        context,
                                        "The text is too long",
                                        "النص طويل جدا");
                                  }

                                  return null;
                                },
                                onSaved: (val) {
                                  data["importantInformation"] =
                                      val?.trim() ?? "";
                                },
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              //   InputTextFieldWidget(
                              //     labelText: AppHelper.returnText(
                              //         context, "Address *", "العنوان *"),
                              //     text: data["address"],
                              //     validator: (val) {
                              //       if (val == null) {
                              //         return AppHelper.returnText(
                              //             context,
                              //             "Use 2 characters or more for address",
                              //             "استخدم حرفين أو أكثر للعنوان");
                              //       }
                              //       if (val.trim() == "" || val.length < 2) {
                              //         return AppHelper.returnText(
                              //             context,
                              //             "Use 2 characters or more for address",
                              //             "استخدم حرفين أو أكثر للعنوان");
                              //       }
                              //       if (val.length > 100) {
                              //         return AppHelper.returnText(
                              //             context,
                              //             "The text is too long",
                              //             "النص طويل جدا");
                              //       }
                              //       return null;
                              //     },
                              //     onSaved: (val) {
                              //       print(val);
                              //       data["address"] = val?.trim();
                              //     },
                              //   ),

                              SearchField(
                                suggestions: wilaayatsAndRegion.map((wr) {
                                  return SearchFieldListItem(
                                    wr.toString().trim().tr(),
                                    item: wr.toString().trim(),
                                  );
                                }).toList(),
                                suggestionState: Suggestion.expand,
                                hint: AppHelper.returnText(context,
                                    'Choose Wilaya *', "اختر الولاية *"),
                                hasOverlay: true,
                                searchStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                validator: (x) {
                                  String? wialya = AppHelper
                                      .wilayatsAaE[x.toString().trim()];

                                  if (!wilaayatsAndRegion.contains(x) ||
                                      x!.isEmpty) {
                                    if (wialya != null) {
                                      data["address"] =
                                          wialya.toString().trim();
                                      return null;
                                    }

                                    return AppHelper.returnText(
                                        context,
                                        'Please enter address from the list',
                                        "الرجاء إدخال ولاية من القائمة");
                                  }

                                  data["address"] = x.toString().trim();
                                },
                                onSubmit: (p0) {
                                  print(p0);
                                },
                                searchInputDecoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black45,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black45),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                maxSuggestionsInViewPort: 6,
                                itemHeight: 40,
                                initialValue: data["address"] == null
                                    ? null
                                    : SearchFieldListItem(
                                        data["address"].toString().trim().tr(),
                                        item:
                                            data["address"].toString().trim()),
                                onSuggestionTap: (x) {
                                  print(x.item);
                                  data["address"] = x.item.toString().trim();
                                },
                              ),

                              const SizedBox(
                                height: 20,
                              ),
                              PickupLocationWidget(
                                onChanged: (latlang) {
                                  data["lat"] = latlang.latitude;
                                  data["lng"] = latlang.longitude;
                                },
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              Text(
                                AppHelper.returnText(
                                    context,
                                    "Choose how you would like to be contacted by customers: *",
                                    "اختر الطريقة التي تود أن يتواصل بها العملاء معك: *"),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              CheckboxWidget(
                                  label: AppHelper.returnText(context,
                                      "Trippoint Chat", "Trippoint محادثات"),
                                  isCheck: _checkboxChatT,
                                  onChanged: (isChecked) {
                                    print(isChecked);
                                    _checkboxChatT = isChecked;
                                  }),
                              CheckboxWidget(
                                  label: AppHelper.returnText(
                                      context, "Whatsapp", "واتساب"),
                                  isCheck: _checkboxChatW.value,
                                  onChanged: (isChecked) {
                                    print(isChecked);
                                    _checkboxChatW.value = isChecked;
                                  }),
                              ValueListenableBuilder(
                                valueListenable: _checkboxChatW,
                                builder: (context, value, child) {
                                  return InputTextFieldWidget(
                                    enabled: value as bool,
                                    keyboardType: TextInputType.number,
                                    text: data["phoneNumberWhatsapp"],
                                    labelText: AppHelper.returnText(
                                        context,
                                        "Whatsapp Phone Number ",
                                        " رقم الهاتف الواتساب"),
                                    //   labelStyle:,
                                    helperText:
                                        "Add Your Phone Number to recive massages on whatsapp.",
                                    validator: (val) {
                                      // AppHelper.checkPhoneValidation(
                                      //     context, val);
                                      // if (val?.length != 8) {
                                      //   return "invalid phone number";
                                      // }
                                    },

                                    onSaved: (val) {
                                      data["phoneNumberWhatsapp"] = val?.trim();
                                    },
                                  );
                                },
                              ),
                              CheckboxWidget(
                                  label: AppHelper.returnText(
                                      context, "Calls", "المكالمات"),
                                  isCheck: _checkboxChatC.value,
                                  onChanged: (isChecked) {
                                    _checkboxChatC.value =
                                        !_checkboxChatC.value;
                                  }),

                              ValueListenableBuilder(
                                valueListenable: _checkboxChatC,
                                builder: (context, value, child) {
                                  return InputTextFieldWidget(
                                    enabled: value as bool,
                                    keyboardType: TextInputType.number,
                                    text: data["phoneNumberCall"],
                                    labelText: AppHelper.returnText(context,
                                        "Phone Number ", "رقم الهاتف "),
                                    //   labelStyle:,
                                    helperText: AppHelper.returnText(
                                        context,
                                        "Add Your Phone Number to receive calls.",
                                        "أضف رقم هاتفك لتلقي المكالمات."),

                                    validator: (val) {
                                      if (_checkboxChatC.value) {
                                        AppHelper.checkPhoneValidation(
                                            context, val);
                                        if (val?.length != 8) {
                                          return AppHelper.returnText(
                                              context,
                                              "Invalid phone number, try again",
                                              "رقم الهاتف غير صالح ، حاول مرة أخرى");
                                        }
                                      }
                                    },
                                    onSaved: (val) {
                                      data["phoneNumberCall"] = val?.trim();
                                    },
                                  );
                                },
                              ),

                              // CheckboxWidget(
                              //     label:
                              //         "Would you like to add the activity Instagram page ?",
                              //     isCheck: _instagramCheck.value,
                              //     onChanged: (isChecked) {
                              //       print(isChecked);
                              //       _instagramCheck.value =
                              //           !_instagramCheck.value;
                              //     }),
                              // // SizedBox(height: 5,),
                              // ValueListenableBuilder(
                              //   valueListenable: _instagramCheck,
                              //   builder: (context, value, child) {
                              //     return InputTextFieldWidget(
                              //       enabled: value as bool,
                              //       keyboardType: TextInputType.number,

                              //       labelText: "instagram Account",
                              //       //   labelStyle:,
                              //       helperText: "Add Your instagram.",

                              //       validator: (val) {},
                              //       onSaved: (val) {
                              //         data["instagramAccount"] = val?.trim();
                              //       },
                              //     );
                              //   },
                              // ),
                              const SizedBox(
                                height: 40,
                              ),
                              InputDatesOrDays(
                                dates: dates,
                                weekDays: weekDays,
                                onChangedDates: (d1) {
                                  print(d1);
                                  dates = d1;
                                },
                                onChangedDays: (d2) {
                                  print(d2);
                                  weekDays = d2;
                                },
                                onChanged: (c1) {
                                  _daysOrDatesCheck.value = c1;
                                },
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Text(AppHelper.returnText(
                                  context,
                                  "What is the allowed age for this activity? (Optional)",
                                  "ما هو العمر المسموح به لهذا النشاط؟ (اختياري)")),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: InputTextFieldWidget(
                                      keyboardType: TextInputType.number,
                                      labelText: AppHelper.returnText(context,
                                          "Maximum Age ", "الحد الأقصى للعمر "),
                                      text: suitableAges["max"] != null
                                          ? suitableAges["max"].toString()
                                          : "",
                                      validator: (val) {
                                        if (val.length > 3) {
                                          return AppHelper.returnText(
                                              context,
                                              "The text is too long",
                                              "النص طويل جدا");
                                        }
                                      },
                                      onSaved: (val) {
                                        try {
                                          if (val.toString().trim() != "") {
                                            suitableAges["max"] =
                                                int.parse(val?.trim());
                                          }
                                        } catch (err) {}
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: InputTextFieldWidget(
                                      keyboardType: TextInputType.number,
                                      labelText: AppHelper.returnText(context,
                                          "Minimum Age ", "الحد الإدنى للعمر "),
                                      text: suitableAges["min"] != null
                                          ? suitableAges["min"].toString()
                                          : "",
                                      validator: (val) {
                                        if (val.length > 3) {
                                          return AppHelper.returnText(
                                              context,
                                              "The text is too long",
                                              "النص طويل جدا");
                                        }
                                      },
                                      onSaved: (val) {
                                        try {
                                          if (val.toString().trim() != "") {
                                            suitableAges["min"] =
                                                int.parse(val?.trim());
                                          }
                                        } catch (err) {}
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),

                              Text(AppHelper.returnText(
                                  context,
                                  "Who this activity for ? (Optional)",
                                  "لمن هذا النشاط؟ (اختياري)")),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: CheckboxWidget(
                                        label: AppHelper.returnText(
                                            context, "Men Only", "الرجال فقط"),
                                        isCheck:
                                            genderSuitability["man"] ?? false,
                                        onChanged: (isChecked) {
                                          print(isChecked);
                                          genderSuitability["man"] = isChecked;
                                        }),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: CheckboxWidget(
                                        label: AppHelper.returnText(context,
                                            "Ladies Only", "النساء فقط"),
                                        isCheck:
                                            genderSuitability["woman"] ?? false,
                                        onChanged: (isChecked) {
                                          print(isChecked);
                                          genderSuitability["woman"] =
                                              isChecked;
                                        }),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 30,
                              ),
                              CheckboxWidget(
                                  label: AppHelper.returnText(
                                      context,
                                      "Do you have group bookings such as families ?",
                                      "هل لديك حجوزات جماعية مثل العائلات؟"),
                                  isCheck: _checkboxOp_GOA,
                                  onChanged: (isChecked) {
                                    print(isChecked);
                                    _checkboxOp_GOA = isChecked;
                                  }),

                              const SizedBox(
                                height: 20,
                              ),

                              ValueListenableBuilder(
                                valueListenable: _errorMassage,
                                builder: (context, value, child) {
                                  if (value.runtimeType != String) {
                                    return const SizedBox();
                                  }
                                  return Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.all(10),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: ColorsHelper.red,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(value.toString()),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  AppHelper.unfocus();
                                  await _submit(context, activitySchema);
                                },
                                child: Text(AppHelper.returnText(
                                    context, "Submit", "تأكيد")),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class RasiedButtonContainer extends StatefulWidget {
  Function onChanged;
  RasiedButtonContainer({required this.onChanged});

  @override
  State<RasiedButtonContainer> createState() => _RasiedButtonContainerState();
}

class _RasiedButtonContainerState extends State<RasiedButtonContainer> {
  BestTutorSite _site = BestTutorSite.Days;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListTile(
            title: Text(AppHelper.returnText(context, "Days", "الأيام")),
            leading: Radio(
              value: BestTutorSite.Days,
              groupValue: _site,
              onChanged: (value) {
                if (value != _site) {
                  widget.onChanged();
                }
                setState(() {
                  _site = value as BestTutorSite;
                });
              },
            ),
          ),
        ),
        Expanded(
          child: ListTile(
            title: Text(AppHelper.returnText(context, "Dates", "التواريخ")),
            leading: Radio(
              value: BestTutorSite.Dates,
              groupValue: _site,
              onChanged: (value) {
                if (value != _site) {
                  widget.onChanged();
                }
                setState(() {
                  _site = value as BestTutorSite;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class InputDatesOrDays extends StatefulWidget {
  Map weekDays;
  List dates;
  Function(Map) onChangedDays;
  Function(List) onChangedDates;
  Function(bool) onChanged;
  InputDatesOrDays({
    super.key,
    required this.weekDays,
    required this.dates,
    required this.onChangedDates,
    required this.onChangedDays,
    required this.onChanged,
  });

  @override
  State<InputDatesOrDays> createState() => _InputDatesOrDaysState();
}

class _InputDatesOrDaysState extends State<InputDatesOrDays> {
  bool _daysOrDatesCheck = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          )),
      child: Column(children: [
        RasiedButtonContainer(
          onChanged: () {
            setState(() {
              _daysOrDatesCheck = !_daysOrDatesCheck;
            });
            widget.onChanged(_daysOrDatesCheck);
          },
        ),

        const SizedBox(
          height: 10,
        ),
        //   absorbing: (value as bool),
        if (_daysOrDatesCheck == true)
          Column(
            children: [
              Text(AppHelper.returnText(
                  context,
                  "Choose days your activity is available.",
                  ".اختر الأيام التي يكون فيها نشاطك متاحًا")),
              ...widget.weekDays.keys.map((v) {
                return CheckboxWidget(
                    label: v,
                    isCheck: widget.weekDays[v] ?? false,
                    onChanged: (isChecked) {
                      print(isChecked);
                      widget.weekDays[v] = isChecked;

                      widget.onChangedDays(widget.weekDays);
                    });
              }).toList(),
            ],
          ),
        if (_daysOrDatesCheck == false)
          UploadDatesBoxWidget(
              dates: widget.dates,
              onDatesSelected: (fdates) {
                print(fdates);
                widget.onChangedDates(fdates);
                //   widget.dates = fdates;
              }),
      ]),
    );
  }
}
