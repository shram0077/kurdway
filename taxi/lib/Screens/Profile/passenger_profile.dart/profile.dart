import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Screens/Profile/Edit_Profile/edit_profile.dart';
import 'package:taxi/Utils/texts.dart';

passengerProfile(UserModel userModel, context) {
  return SingleChildScrollView(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    child: Column(
      children: [
        Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 56.5,
                  backgroundColor: greenColor2,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: CachedNetworkImageProvider(
                      userModel.profilePicture,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: EditProfile(
                            currentUserId: userModel.userid,
                            userModel: userModel,
                          )),
                    );
                  },
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: greenColor2,
                    child: Icon(
                      EvaIcons.edit2Outline,
                      size: 19,
                      color: whiteColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 7.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  robotoText(userModel.name, Colors.black, 20, FontWeight.bold),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.phone,
                        size: 18,
                        color: Colors.grey,
                      ),
                      robotoText(
                    "· 0${userModel.phone.substring(4)}",
                          Colors.grey,
                          15,
                          FontWeight.w700)
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.location,
                        size: 18,
                        color: Colors.grey,
                      ),
                      robotoText(" · ${userModel.currentCity}", Colors.grey, 14,
                          FontWeight.bold),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        Divider(),
        Row(
          children: [
            robotoText("Ride Preferences", blackColor, 18, FontWeight.w600)
          ],
        ),
        Card(
          child: Column(
            children: [
              _buildListTile(Icons.history, 'Ride history'),
              _buildListTile(Icons.wallet, 'Wallet'),
              _buildListTile(Icons.document_scanner, 'Transactions'),
            ],
          ),
        ),
        Divider(),
        Row(
          children: [robotoText("General", blackColor, 18, FontWeight.w600)],
        ),
        Card(
          child: Column(
            children: [
              _buildListTile(Icons.language, 'Languages'),
              _buildListTile(Icons.location_on, 'Location'),
            ],
          ),
        ),
        Divider(),
        Row(
          children: [
            robotoText("App Support & Privacy", blackColor, 18, FontWeight.w600)
          ],
        ),
        Card(
          child: Column(
            children: [
              _buildListTile(Icons.support_agent, 'Support'),
              _buildListTile(Icons.feedback, 'Feedback'),
              _buildListTile(Icons.report, "Report an Issue"),
              _buildListTile(Icons.privacy_tip, "Data Privacy Options"),
              _buildListTile(Icons.star, 'Rate App'),
            ],
          ),
        ),
        Divider(),
        _buildListTile(Icons.logout, 'Log Out'),
        SizedBox(height: 20),
        Text('App Version 2.3', style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}

Widget _buildListTile(IconData icon, String title) {
  return CupertinoListTile(
    leading: Icon(
      icon,
    ),
    title: robotoText(title, blackColor, 16, FontWeight.w500),
    trailing: Icon(
      Icons.arrow_forward_ios,
      size: 16,
    ),
    onTap: () {},
  );
}
