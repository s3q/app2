import 'package:oman_trippoint/helpers/colorsHelper.dart';
import 'package:oman_trippoint/schemas/massageSchema.dart';
import 'package:oman_trippoint/screens/viewImageFullScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class MassageBoxWidget extends StatelessWidget {
  MassageSchema massage;
  MassageBoxWidget({
    Key? key,
    required this.massage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    return Column(
      crossAxisAlignment: massage.from == auth.currentUser?.uid
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          margin: const EdgeInsets.only(top: 5),
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: massage.from == auth.currentUser?.uid
                  ? ColorsHelper.whiteBlue
                  : ColorsHelper.whiteYellow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (massage.type == "text")
                Text(
                  massage.massage!,
                  // maxLines: 6,
                  // overflow: TextOverflow.ellipsis,
                ),
              if (massage.type == "image")
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ViewImageFullScreen(image: massage.imagePath!),
                      ),
                    );
                  },
                  child: Image.network(
                    massage.imagePath!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(
                height: 4,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  DateFormat('hh:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(massage.createdAt)),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 11, color: Colors.grey[700]),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
