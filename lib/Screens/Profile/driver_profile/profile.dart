import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Models/Car_Model.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Screens/Profile/Edit_Profile/edit_profile.dart';
import 'package:taxi/Screens/Profile/utils/plateCar.dart';
import 'package:taxi/Utils/texts.dart';

Widget driverProfile(UserModel userModel, CarModel carModel,
    String currentUserId, BuildContext context, List mockRides) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(userModel, context),
        Divider(),
        _buildWalletSection(userModel),
        Divider(),
        _buildVehicleInformation(carModel),
        Divider(),
        _buildRecentRides(mockRides),
      ],
    ),
  );
}

Widget _buildProfileHeader(UserModel userModel, BuildContext context) {
  return Row(
    children: [
      Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 56.5,
            backgroundColor: greenColor2,
            child: CircleAvatar(
              radius: 55,
              backgroundImage:
                  CachedNetworkImageProvider(userModel.profilePicture),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: EditProfile(
                  currentUserId: userModel.userid,
                  userModel: userModel,
                ),
              ),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: greenColor2,
              child: Icon(EvaIcons.edit2Outline, size: 20, color: whiteColor),
            ),
          ),
        ],
      ),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            robotoText(userModel.name, Colors.black, 22, FontWeight.bold),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(CupertinoIcons.phone, size: 18, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: robotoText("0${userModel.phone.substring(4)}",
                      Colors.grey, 16, FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(CupertinoIcons.location, size: 18, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: robotoText(
                      userModel.currentCity, Colors.grey, 16, FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildRating(),
          ],
        ),
      ),
    ],
  );
}

Widget _buildWalletSection(UserModel userModel) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      robotoText("Wallet Balance", Colors.black, 18, FontWeight.bold),
      robotoText(
          "${userModel.walletBalance} IQD", greenColor2, 22, FontWeight.bold),
      robotoText(
          "Total Earnings: 15500", Colors.black54, 16, FontWeight.normal),
    ],
  );
}

Widget _buildVehicleInformation(CarModel? carModel) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      robotoText("Vehicle Information", Colors.black, 18, FontWeight.bold),
      SizedBox(height: 8),
      robotoText("Car: ${carModel?.carModel.split(',')[0] ?? 'Unknown'}",
          Colors.black, 16, FontWeight.normal),
      robotoText("Model: ${carModel?.carModel.split(',')[1] ?? 'Unknown'}",
          Colors.black, 16, FontWeight.normal),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          robotoText("License Plate:", Colors.black, 16, FontWeight.normal),
          plateCar(50, carModel?.licensePlate ?? 'N/A'),
        ],
      ),
    ],
  );
}

Widget _buildRecentRides(List mockRides) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          robotoText("Recent Rides", Colors.black, 18, FontWeight.bold),
          CupertinoButton(
            child: robotoText("View all", greenColor2, 15, FontWeight.w500),
            onPressed: () {},
          ),
        ],
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: mockRides.length,
        itemBuilder: (context, index) {
          var ride = mockRides[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  robotoText("Pickup: ${ride['pickupLocation']}", Colors.black,
                      16, FontWeight.w500),
                  robotoText("Destination: ${ride['destination']}", Colors.grey,
                      14, FontWeight.w400),
                  robotoText("Date: ${ride['date']}", Colors.grey, 14,
                      FontWeight.w400),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}

Widget _buildRating() {
  return Row(
    children: List.generate(
        5, (index) => Icon(EvaIcons.star, color: Colors.amber, size: 20)),
  );
}
