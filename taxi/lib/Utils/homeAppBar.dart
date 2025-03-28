import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Utils/TaxiToggleButton.dart';
import 'package:taxi/Utils/loadings.dart';
import 'package:taxi/Utils/texts.dart';

class HomeAppBar extends StatefulWidget {
  final String currentUserId;
  // ignore: use_super_parameters
  const HomeAppBar({
    key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersRef.doc(widget.currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: loadingProfileContiner());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Snapshot Error',
                style: GoogleFonts.alef(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            );
          }

          UserModel userModel = UserModel.fromDoc(snapshot.data!);
          return AppBar(
            backgroundColor: greenColor2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
            iconTheme: IconThemeData(color: whiteColor),
            titleSpacing: 0,
            toolbarHeight: 85,
            title: SizedBox(
              width: double.infinity,
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 12.0, left: 12, bottom: 5),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: userModel.role == 'driver' ? 3 : 0,
                                ),
                                robotoText("Hi, ${userModel.name}", whiteColor,
                                    21, FontWeight.bold)
                              ],
                            )),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, bottom: 15),
                          child: robotoText(
                              userModel.role == 'driver'
                                  ? "Find your ride and start earning!"
                                  : "Let's get started! Find your ride.",
                              const Color.fromARGB(255, 241, 241, 241),
                              16,
                              FontWeight.w500),
                        ),
                      ]),
                  userModel.role == 'driver'
                      ? TaxiToggleButton(
                          currentUserId: userModel.userid,
                        )
                      : IconButton(
                          onPressed: () {}, icon: Icon(Icons.notifications)),
                ],
              ),
            ),
          );
        });
  }
}
