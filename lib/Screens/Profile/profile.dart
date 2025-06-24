import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/Car_Model.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Screens/Profile/driver_profile/profile.dart';
import 'package:taxi/Screens/Profile/passenger_profile.dart/profile.dart';
import 'package:taxi/Services/Auth.dart';
import 'package:taxi/Utils/texts.dart';

class ProfilePage extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;

  const ProfilePage({
    super.key,
    required this.currentUserId,
    required this.visitedUserId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Fetch car details for the visited user
  Future<CarModel?> getCarInfo() async {
    var carSnapshot = await taxisRef
        .where('driverId', isEqualTo: widget.visitedUserId)
        .limit(1)
        .get();

    print("Car documents found: ${carSnapshot.docs.length}");

    if (carSnapshot.docs.isNotEmpty) {
      return CarModel.fromDoc(carSnapshot.docs.first);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                centerTitle: true,
                actions: [
                  IconButton(
                      onPressed: () {
                        Auth.logout();
                      },
                      icon: Icon(Icons.logout))
                ],
                pinned: true,
                floating: false,
                expandedHeight: 100.0,
                backgroundColor: greenColor2,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                iconTheme: IconThemeData(color: whiteColor),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      EdgeInsets.only(left: 16, bottom: 16, right: 16),
                  title:
                      robotoText("Profile", whiteColor, 20, FontWeight.normal),
                ),
              ),
            ];
          },
          body: StreamBuilder(
            stream: usersRef.doc(widget.visitedUserId).snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                print("Error in user stream: \${userSnapshot.error}");
                return Center(
                  child: Text('Error loading profile: \${userSnapshot.error}',
                      style: GoogleFonts.alef(fontSize: 14, color: Colors.red)),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return Center(child: Text("User not found."));
              }

              UserModel userModel = UserModel.fromDoc(userSnapshot.data!);

              if (userModel.role != 'driver') {
                return passengerProfile(userModel, context);
              }

              return StreamBuilder(
                stream: taxisRef.doc(widget.visitedUserId).snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> carSnapshot) {
                  if (carSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (carSnapshot.hasError) {
                    print("Error in car stream: \${carSnapshot.error}");
                    return Center(
                      child: Text(
                          'Error loading car info: \${carSnapshot.error}',
                          style: GoogleFonts.alef(
                              fontSize: 14, color: Colors.red)),
                    );
                  }

                  if (!carSnapshot.hasData || !carSnapshot.data!.exists) {
                    return Center(child: Text("No car information available"));
                  }

                  CarModel carModel = CarModel.fromDoc(carSnapshot.data!);

                  return driverProfile(
                    userModel,
                    carModel,
                    widget.currentUserId,
                    context,
                    mockRides,
                  );
                },
              );
            },
          )),
    );
  } // Mock Data for Recent Rides

  List<Map<String, String>> mockRides = [
    {
      'pickupLocation': 'New York City',
      'destination': 'Los Angeles',
      'date': '2025-03-01',
    },
    {
      'pickupLocation': 'Baghdad',
      'destination': 'Erbil',
      'date': '2025-02-28',
    },
    {
      'pickupLocation': 'Sulaymaniyeh',
      'destination': 'Kirkuk',
      'date': '2025-02-27',
    },
  ];
}
