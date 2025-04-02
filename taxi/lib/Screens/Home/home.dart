import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Screens/Home/Drawer/BuildDrawer.dart';
import 'package:taxi/Screens/bookingRide/start_booking.dart';
import 'package:taxi/Services/Auth.dart';
import 'package:taxi/Utils/cardWallet.dart';
import 'package:taxi/Utils/card_Selection.dart';
import 'package:taxi/Utils/homeAppBar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi/Utils/texts.dart';

class HomePage extends StatefulWidget {
  final String currentUserId;
  final Auth authController = Get.find<Auth>();

  HomePage({super.key, required this.currentUserId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  bool isLoading = true;
  bool trackLocation = false;
  UserModel? _userModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserData();
    requestLocationPermission();
  }

  Future<void> fetchUserData() async {
    try {
      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await usersRef.doc(widget.currentUserId).get();

      if (userDoc.exists) {
        // Successfully fetched user data, create UserModel from Firestore document
        _userModel = UserModel.fromDoc(userDoc);

        setState(() {
          isLoading = false; // Set loading to false when data is fetched
        });
      } else {
        print("User document does not exist.");
        setState(() {
          isLoading = false; // Set loading to false in case of failure
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false; // Set loading to false in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        drawer: CustomDrawer(
          currentUserId: widget.currentUserId,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                HomeAppBar(currentUserId: widget.currentUserId),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8, left: 8),
                  child: isLoading
                      ? loadingCardWallet()
                      : WalletCard(
                          isLoading: isLoading, userModel: _userModel!),
                ),
                Divider(
                  endIndent: 30,
                  indent: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    isLoading
                        ? LoadingCardSelection(
                            color: taxiYelloColor,
                            imgPath: "assets/images/taxicap.png",
                            sloganText: "Book a Ride",
                          )
                        : buildCardSelection(
                            context,
                            "assets/images/taxicap.png",
                            "Book a Ride",
                            StartBooking(
                              currentUserId: widget.currentUserId,
                              userModel: _userModel!,
                            ),
                            taxiYelloColor,

                            //   BookRidePage(
                            //       userModel: _userModel!,
                            //       currentUserId:
                            //           widget.currentUserId), // Open the map page
                            //
                          ),
                    buildCardSelection(
                        context,
                        "assets/images/bus_logo.png",
                        "Bus Tracker",
                        HomePage(currentUserId: widget.currentUserId),
                        Colors.orangeAccent),
                  ],
                )
              ],
            ),
          ],
        ));
  }

  Future<void> requestLocationPermission() async {
    if (!mounted) return;

    setState(() {
      trackLocation = true;
    });

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: greenColor2,
            title: robotoText(
                "Location Required", taxiYelloColor, 25, FontWeight.bold),
            content: robotoText(
                "Please enable location services for better functionality.",
                whiteColor,
                18,
                FontWeight.w500),
            actions: [
              TextButton(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                  if (mounted) Navigator.pop(context);
                },
                child: robotoText("Enable", whiteColor, 14, FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    robotoText("Cancel", Colors.white70, 14, FontWeight.bold),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: greenColor2,
            title: robotoText(
                "Permission Required", taxiYelloColor, 25, FontWeight.bold),
            content: robotoText(
                "Location permission is permanently denied. Please enable it from settings.",
                whiteColor,
                18,
                FontWeight.w500),
            actions: [
              TextButton(
                onPressed: () async {
                  await Geolocator.openAppSettings();
                  if (mounted) Navigator.pop(context);
                },
                child: robotoText(
                    "Open Settings", Colors.white70, 14, FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    robotoText("Cancel", Colors.white70, 14, FontWeight.bold),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Get user's current location with best accuracy
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    var userDoc = await usersRef.doc(widget.currentUserId).get();
    var lastLocation = userDoc.data()?['currentLocation'];

    var lastUpdate = lastLocation?['timestamp'];

    if (lastLocation != null &&
        (lastLocation['latitude'] - position.latitude).abs() < 0.0001 &&
        (lastLocation['longitude'] - position.longitude).abs() < 0.0001 &&
        lastUpdate != null &&
        DateTime.now().difference(lastUpdate.toDate()).inSeconds < 5) {
      print("📍 Location has not changed significantly.");
    } else {
      await usersRef.doc(widget.currentUserId).update({
        'currentLocation': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': FieldValue.serverTimestamp(),
        }
      });

      if (_userModel!.role == 'driver') {
        await taxisRef.doc(widget.currentUserId).update({
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': FieldValue.serverTimestamp(),
          }
        });
      }

      print("✅ Location updated: ${position.latitude}, ${position.longitude}");
      await getCityFromCoordinates(
          position.latitude, position.longitude, widget.currentUserId);
    }

    if (mounted) {
      setState(() {
        trackLocation = false;
      });
    }
  }

  Future<void> getCityFromCoordinates(
      double lat, double lon, String currentUserId) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Construct a more detailed address string with null checks
        String address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        print('Address found: $address');

        // Update Firestore with the constructed address (or a part of it)
        await usersRef.doc(currentUserId).update({
          "currentCity":
              address.isNotEmpty ? address : 'Address details unavailable',
        });
      } else {
        print('⚠️ No address found for coordinates: $lat, $lon');
        await usersRef.doc(currentUserId).update({
          "currentCity": 'Unknown Location',
        });
      }
    } catch (e) {
      print('⚠️ Error fetching address: $e');
      await usersRef.doc(currentUserId).update({
        "currentCity": 'Error fetching address',
      });
    }
  }
}
