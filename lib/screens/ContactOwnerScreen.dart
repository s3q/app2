import 'package:oman_trippoint/helpers/adHelper.dart';
import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/chatProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/schemas/userSchema.dart';
import 'package:oman_trippoint/screens/massagesScreen.dart';
import 'package:oman_trippoint/widgets/AdContainerWidget.dart';
import 'package:oman_trippoint/widgets/DiologsWidgets.dart';
import 'package:oman_trippoint/widgets/SafeScreen.dart';
// import 'package:oman_trippoint/widgets/activityCardWidget.dart';
import 'package:oman_trippoint/widgets/appBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactOwnerScreen extends StatefulWidget {
  static String router = "contactOwner";
  const ContactOwnerScreen({super.key});

  @override
  State<ContactOwnerScreen> createState() => _ContactOwnerScreenState();
}

class _ContactOwnerScreenState extends State<ContactOwnerScreen> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              //   _moveToHome();
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  Future _gotoChat({
    required BuildContext context,
    required String userId,
    required String activityId,
    required String activityTitle,
  }) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    if (userProvider.islogin()) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      String? previousActivityId = chatProvider.chat?.activityId;

      // final userProvider = Provider.of<UserProvider>(context, listen: false);

      await chatProvider.addChat(
          context: context, userId: userId, activityId: activityId);
      if (chatProvider.chat != null) {
        if (chatProvider.chat!.users.contains(userId) &&
            chatProvider.chat!.users.contains(userProvider.currentUser!.Id)) {
          print(chatProvider.chat);
          if (previousActivityId != activityId || previousActivityId == null) {
            await chatProvider.sendMassageNewActivitySelected(
                context: context,
                text:
                    "Start a conversation to ask questions about a tourism activity",
                activityTitle: (activityTitle.trim().length <= 30
                        ? activityTitle.trim()
                        : activityTitle.trim().substring(0, 30).toString()) +
                    "|||" +
                    activityId);
          }
          Navigator.pushNamed(context, MassagesScreen.router,
              arguments: chatProvider.chat);
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _interstitialAd?.dispose();
    _loadInterstitialAd();

    _bannerAd?.dispose();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();
    _interstitialAd?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);
    ActivitySchema activitySchema =
        ModalRoute.of(context)?.settings.arguments as ActivitySchema;
    print(activitySchema.phoneNumberWhatsapp);

    print(activitySchema.phoneNumberWhatsapp == null ||
        activitySchema.phoneNumberWhatsapp == "");
    return SafeScreen(
      padding: 0,
      child: Column(children: [
        AppBarWidget(
            title:
                AppHelper.returnText(context, "Contact Owner", "راسل المالك")),
        const SizedBox(
          height: 40,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            Text(
              AppHelper.returnText(
                  context,
                  "Communicate with the owner of this activity in various ways. Important: read the terms and conditions",
                  "تواصل مع صاحب هذا النشاط بطرق المختلفة. مهم : قراءة الشروط و الاحكام "),
              textAlign: TextAlign.center,
            ),

            //   //^---------------------- adverticment -----------------------

            //         if (_bannerAd != null)
            //           Container(
            //             margin: const EdgeInsets.symmetric(vertical: 20),
            //             width: _bannerAd!.size.width.toDouble(),
            //             height: _bannerAd!.size.height.toDouble(),
            //             child: AdWidget(ad: _bannerAd!),
            //           ),

            //         //^----------------------------------------------------------
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (userProvider.currentUser == null) {
                  DialogWidgets.mustSginin(context);
                  return;
                }
                EasyLoading.show(maskType: EasyLoadingMaskType.black);
                activityProvider.addChatsCountActivity(
                    activitySchema.storeId, activitySchema.Id);
                await _gotoChat(
                    context: context,
                    userId: activitySchema.userId,
                    activityId: activitySchema.Id,
                    activityTitle: activitySchema.title);

                await Future.delayed(const Duration(milliseconds: 2000));

                EasyLoading.dismiss();
              },
              style: ElevatedButton.styleFrom(
                primary: ColorsHelper.yellow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              child: SizedBox(
                //   width: 200,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    // color: Colors.white,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    AppHelper.returnText(
                        context, " Trippoint Chat ", "Trippoint محادثة في"),
                    // style: TextStyle(color: Colors.white),
                  ),
                ]),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                final Uri _url =
                    Uri.parse("tel:${activitySchema.phoneNumberCall}");

                final Uri telLaunchUri = Uri(
                  scheme: 'tel',
                  path: activitySchema.phoneNumberCall,
                );
                launchUrl(telLaunchUri);
                await activityProvider.addCallsCountActivity(
                    activitySchema.storeId, activitySchema.Id);
              },
              style: ElevatedButton.styleFrom(
                primary: ColorsHelper.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              child: SizedBox(
                //   width: 200,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(
                    Icons.call,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    AppHelper.returnText(context, " Call ", " اتصل "),
                    style: const TextStyle(color: Colors.white),
                  ),
                ]),
              ),
            ),
            // const SizedBox(
            //   height: 10,
            // ),

            //^---------------------- adverticment -----------------------

            // if (_bannerAd != null)
            //   Container(
            //     margin: const EdgeInsets.symmetric(vertical: 20),
            //     width: _bannerAd?.size.width.toDouble(),
            //     height: _bannerAd?.size.height.toDouble(),
            //     child: AdWidget(ad: _bannerAd!),
            //   ),

            const Adcontainer(),

            //^----------------------------------------------------------
            const SizedBox(
              height: 10,
            ),

            ElevatedButton(
              onPressed: activitySchema.phoneNumberWhatsapp == null ||
                      activitySchema.phoneNumberWhatsapp == ""
                  ? null
                  : () async {
                      final Uri _url = Uri.parse(
                          "https://wa.me/${activitySchema.phoneNumberWhatsapp}");
                      // ' https://wa.me/${activitySchema.phoneNumberWhatsapp}?text=Hello');
                      launchUrl(_url,
                          mode: LaunchMode.externalNonBrowserApplication);
//                 WhatsApp whatsapp = WhatsApp();

//                 whatsapp.messagesTemplate(
// 	to: int.tryParse(activitySchema.phoneNumberWhatsapp.toString()) ?? 0,
// 	templateName: "Hey,",

// );
                    },
              style: ElevatedButton.styleFrom(
                primary: ColorsHelper.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              child: SizedBox(
                //   width: 200,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const  Icon(
                    FontAwesomeIcons.whatsapp,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    activitySchema.phoneNumberWhatsapp.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ]),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder(
                future:
                    userProvider.fetchUserData(userId: activitySchema.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        primary: ColorsHelper.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      child: SizedBox(
                        //   width: 200,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                AppHelper.returnText(
                                    context, " Instagram ", " انستجرام "),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ]),
                      ),
                    );
                  }
                  UserSchema? userSchema;
                  if (snapshot.data is UserSchema) {
                    userSchema = snapshot.data as UserSchema;
                  }
                  print(userSchema?.proAccount?["instagram"]);

                  return ElevatedButton(
                    onPressed: userSchema?.proAccount?["instagram"] == null ||
                            userSchema?.proAccount?["instagram"] == ""
                        ? null
                        : () async {
                            if (_interstitialAd != null) {
                              _interstitialAd?.show();
                            }

                            final Uri _url = Uri.parse(
                                'https://instagram.com/${userSchema?.proAccount?["instagram"]}');
                            if (await canLaunchUrl(_url)) {
                              await launchUrl(_url,
                                  mode:
                                      LaunchMode.externalNonBrowserApplication);
                            } else {
                              throw 'Could not launch $_url';
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      primary: ColorsHelper.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    child: SizedBox(
                      //   width: 200,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              FontAwesomeIcons.instagram,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              AppHelper.returnText(
                                  context, " Instagram ", " انستجرام "),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ]),
                    ),
                  );
                }),
            const SizedBox(
              height: 10,
            ),
          ]),
        ),
      ]),
    );
  }
}
