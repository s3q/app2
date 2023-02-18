import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/activityProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/screens/activityDetailsScreen.dart';
import 'package:oman_trippoint/widgets/activityCardWidget.dart';
import 'package:oman_trippoint/widgets/activityCardWishlistWidget.dart';
import 'package:oman_trippoint/widgets/textIocnActWidget.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ActivityProvider activityProvider = Provider.of<ActivityProvider>(context);

    List? wishlist = userProvider.currentUser?.wishlist as List?;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppHelper.returnText(context, "Wishlist", "قائمة المفضلات"),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 30,
          ),
          if (wishlist != null)
            Expanded(
              child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: wishlist?.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                        future: activityProvider
                            .fetchActivityWStore(wishlist[index]),
                        builder: (context, snapshot) {
                          ActivitySchema? activity =
                              snapshot.data as ActivitySchema?;

                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              !snapshot.hasData ||
                              activity == null) {
                            return Card(
                                child: Container(
                              width: 200,
                              height: 200,
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: ColorsHelper.grey,
                                    ),
                                    width: 200,
                                    height: 200,
                                    //   child: Image.network(),
                                  ),
                                  Column(children: const []),
                                ],
                              ),
                            ));
                          }

                          return ActivityCardWishlistWidget(
                              activity: activity,
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, ActivityDetailsScreen.router,
                                    arguments: activity);
                              });

                          //   return ActivityCardWidget(
                          //       activity: activity,
                          //       onPressed: () {
                          //         Navigator.pushNamed(
                          //             context, ActivityDetailsScreen.router,
                          //             arguments: activity);
                          //       });
                        });
                  }),
            ),
        ],
      ),
    );
  }
}
