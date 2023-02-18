import 'package:oman_trippoint/helpers/appHelper.dart';
import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/providers/chatProvider.dart';
import 'package:oman_trippoint/providers/userProvider.dart';
import 'package:oman_trippoint/schemas/activitySchema.dart';
import 'package:oman_trippoint/schemas/userSchema.dart';
import 'package:oman_trippoint/screens/ContactOwnerScreen.dart';
import 'package:oman_trippoint/screens/massagesScreen.dart';
import 'package:oman_trippoint/widgets/profileAvatarWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OriginizerActivityBoxWidget extends StatefulWidget {
  ActivitySchema activitySchema;
  OriginizerActivityBoxWidget({super.key, required this.activitySchema});

  @override
  State<OriginizerActivityBoxWidget> createState() =>
      _OriginizerActivityBoxWidgetState();
}

class _OriginizerActivityBoxWidgetState
    extends State<OriginizerActivityBoxWidget> {
  void _gotoChat({
    required BuildContext context,
    required UserProvider userProvider,
    required String userId,
    required String activityId,
  }) async {
    if (userProvider.islogin()) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // final userProvider = Provider.of<UserProvider>(context, listen: false);

      await chatProvider.addChat(
          context: context, userId: userId, activityId: activityId);
      if (chatProvider.chat != null) {
        if (chatProvider.chat!.users.contains(userId) &&
            chatProvider.chat!.users.contains(userProvider.currentUser!.Id)) {
          await Navigator.pushNamed(context, MassagesScreen.router,
              arguments: chatProvider.chat);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return FutureBuilder(
        future:
            userProvider.fetchUserData(userId: widget.activitySchema.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    AppHelper.returnText(
                        context, 'Organized by', 'أنشأ من قبل'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Container(
                      //   width: 80,
                      //   height: 80,
                      //   clipBehavior: Clip.antiAlias,
                      //   decoration: BoxDecoration(
                      //     shape: BoxShape.circle,
                      //   ),
                      //   child: Image.asset(
                      //     'assets/images/user.png',
                      //   ),
                      // ),
                      Row(
                        children: [
                          CircleAvatar(
                            child: ClipOval(
                              child: Container(
                                color: ColorsHelper.grey,
                              ),
                            ),
                            maxRadius: 40,
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                            child: Text(
                              "",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),

                      ElevatedButton(
                        onPressed: null,
                        child: Text(AppHelper.returnText(
                            context, "Contact Owner", "راسل المالك")),
                        style: ElevatedButton.styleFrom(
                          primary: ColorsHelper.grey,
                          // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          UserSchema userData = snapshot.data as UserSchema;
          return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  AppHelper.returnText(context, 'Organized by', 'أنشأ من قبل'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Container(
                    //   width: 80,
                    //   height: 80,
                    //   clipBehavior: Clip.antiAlias,
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //   ),
                    //   child: Image.asset(
                    //     'assets/images/user.png',
                    //   ),
                    // ),
                    Row(
                      children: [
                        ProfileAvatarWidget(
                          profileColor: userData.profileColor,
                          profileImagePath: userData.profileImagePath,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                          child: Text(
                            userData.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: () {
                        // _gotoChat(
                        //   context: context,
                        //   userProvider: userProvider,
                        //   userId: widget.activitySchema.userId,
                        // );
                        Navigator.pushNamed(context, ContactOwnerScreen.router,
                            arguments: widget.activitySchema);
                      },
                      child: Text(AppHelper.returnText(
                          context, "Contact Owner", "راسل المالك")),
                      style: ElevatedButton.styleFrom(
                        primary: ColorsHelper.pink,
                        // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
