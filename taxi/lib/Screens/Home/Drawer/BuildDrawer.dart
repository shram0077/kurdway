import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Services/Auth.dart';
import 'package:taxi/Utils/texts.dart'; // Assuming you have a UserModel class to map user data

class CustomDrawer extends StatelessWidget {
  final String currentUserId;

  const CustomDrawer({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: StreamBuilder<DocumentSnapshot>(
        stream: usersRef.doc(currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading user data'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('User data not found'));
          }

          // Map the snapshot data to a UserModel
          UserModel userModel = UserModel.fromDoc(snapshot.data!);

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Drawer Header: User Profile Info
              UserAccountsDrawerHeader(
                accountName:
                    robotoText(userModel.name, whiteColor, 15, FontWeight.bold),
                accountEmail: robotoText(
                    "${userModel.walletBalance.toString()} IQD ",
                    whiteColor,
                    15,
                    FontWeight.bold),
                currentAccountPicture: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 2,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  userModel.profilePicture))),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage("assets/images/taxicap.png")),
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 0.5,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              color: Colors.green,
                            ),
                          ),
                        )),
                  ],
                ),
                decoration: BoxDecoration(
                  color: userModel.role == 'driver'
                      ? driverColor
                      : Colors.green, // Customize background color
                ),
              ),

              // Home (Dashboard) Option
              ListTile(
                leading: Icon(EvaIcons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  // Navigate to Home screen
                },
              ),

              // Ride History Option
              ListTile(
                leading: Icon(EvaIcons.repeatOutline),
                title: Text('Ride History'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to Ride History screen
                },
              ),

              // Payment Methods Option
              ListTile(
                leading: Icon(EvaIcons.creditCard),
                title: Text('Payment Methods'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to Payment Methods screen
                },
              ),

              // Settings Option
              ListTile(
                leading: Icon(EvaIcons.settings),
                title: Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to Settings screen
                },
              ),

              // Help and Support Option
              ListTile(
                leading: Icon(EvaIcons.questionMarkCircle),
                title: Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to Help/Support screen
                },
              ),

              // Logout Option
              ListTile(
                leading: Icon(EvaIcons.logOut),
                title: Text('Logout'),
                onTap: () {
               Auth.logout();
                  // Perform logout operation
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
