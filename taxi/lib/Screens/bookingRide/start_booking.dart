import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Screens/bookingRide/bookingRide.dart';
import 'package:taxi/Utils/texts.dart';

class StartBooking extends StatefulWidget {
  final String currentUserId;
  final UserModel userModel;
  const StartBooking(
      {super.key, required this.currentUserId, required this.userModel});

  @override
  State<StartBooking> createState() => _StartBookingState();
}

class _StartBookingState extends State<StartBooking> {
  LatLng? _currentPosition;
  String? currentLocation;

  String? homePlaceName;
  String? workPlaceName;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    loadUserAddresses();
  }

  // Fetch the current location of the user from Firestore
  Future<void> _getCurrentLocation() async {
    try {
      DocumentSnapshot userDoc = await usersRef.doc(widget.currentUserId).get();
      if (userDoc.exists) {
        double latitude = userDoc['currentLocation']['latitude'];
        double longitude = userDoc['currentLocation']['longitude'];

        currentLocation = await _getAddressFromCoordinates(latitude, longitude);

        setState(() {
          _currentPosition = LatLng(latitude, longitude);
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  // Convert coordinates to an address
  Future<String> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.locality}, ${place.subLocality}';
      }
      setState(() {});
      return 'Unknown Location';
    } catch (e) {
      return 'Error fetching address';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          width: 125,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: taxiYelloColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              robotoText("for Myself", whiteColor, 15, FontWeight.w500),
              Icon(Icons.arrow_drop_down, color: whiteColor),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: blackColor),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.map),
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.bottomToTop, // Animation type
                  child: BookRidePage(
                      currentUserId: widget.currentUserId,
                      userModel: widget.userModel), // Navigate to this screen
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 9,
        ),
        child: Column(
          children: [
            _fromField(),
            SizedBox(
              height: 8,
            ),
            _destinationField()
          ],
        ),
      ),
    );
  }

  // From field
  Container _fromField() {
    return Container(
      margin: const EdgeInsets.only(
        top: 5,
        left: 12,
        right: 12,
      ),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0)
      ]),
      child: GestureDetector(
        onTap: () {
          // _showLocationPicker(); // Trigger bottom sheet when tapped
        },
        child: TextField(
          onTap: _showLocationPicker,
          enabled: true,
          cursorColor: greenColor,
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(15),
              hintText: 'From: $currentLocation',
              hintStyle: GoogleFonts.aBeeZee(
                  color: Colors.grey, fontWeight: FontWeight.bold),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  CupertinoIcons.placemark,
                  color: Colors.grey,
                ),
              ),
              suffixIcon: Container(
                width: 100,
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const VerticalDivider(
                        color: Colors.black,
                        indent: 10,
                        endIndent: 10,
                        thickness: 0.1,
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            onPressed: () {
                              _getCurrentLocation();
                              loadUserAddresses();
                            },
                            icon: Icon(
                              CupertinoIcons.refresh,
                              color: taxiYelloColor,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none)),
        ),
      ),
    );
  }

  // Destination field
  Container _destinationField() {
    return Container(
      margin: const EdgeInsets.only(
        top: 5,
        left: 12,
        right: 12,
      ),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0)
      ]),
      child: TextField(
        cursorColor: greenColor,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'Where to?',
            hintStyle: GoogleFonts.aBeeZee(
                color: Colors.grey, fontWeight: FontWeight.bold),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                CupertinoIcons.map_pin_ellipse,
                color: Colors.grey,
              ),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none)),
      ),
    );
  }

  // Show the location picker modal bottom sheet
  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 4,
              ),
              Text(
                'Select Your Location',
                style: GoogleFonts.aBeeZee(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Home address',
                    style: GoogleFonts.aBeeZee(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Icon(
                    CupertinoIcons.home,
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, top: 7),
                width: double.infinity,
                height: 55,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.04),
                      spreadRadius: 4,
                      blurRadius: 10,
                    )
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      homePlaceName != null
                          ? homePlaceName.toString()
                          : "No home address set.",
                      style: GoogleFonts.aBeeZee(
                        fontSize: 16,
                        color: blackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    const VerticalDivider(
                      color: Colors.black,
                      indent: 10,
                      endIndent: 10,
                      thickness: 0.1,
                    ),
                    IconButton(
                        color: Colors.green,
                        onPressed: () {},
                        icon: Icon(homePlaceName != null
                            ? CupertinoIcons.pencil_outline
                            : CupertinoIcons.add_circled)),
                  ],
                ),
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Work',
                    style: GoogleFonts.aBeeZee(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Icon(
                    CupertinoIcons.bag,
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, top: 7),
                width: double.infinity,
                height: 55,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: blackColor.withOpacity(0.04),
                      spreadRadius: 4,
                      blurRadius: 10,
                    )
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Text(
                      workPlaceName != null
                          ? "Work Address: $workPlaceName"
                          : "No work address set.",
                      style: GoogleFonts.aBeeZee(
                        fontSize: 16,
                        color: blackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    const VerticalDivider(
                      color: Colors.black,
                      indent: 10,
                      endIndent: 10,
                      thickness: 0.1,
                    ),
                    IconButton(
                        color: Colors.green,
                        onPressed: () {},
                        icon: Icon(homePlaceName != null
                            ? CupertinoIcons.pencil_outline
                            : CupertinoIcons.add_circled)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> getUserAddresses(String userId) async {
    try {
      // Fetch user address document from Firestore
      DocumentSnapshot docSnapshot = await addressRef.doc(userId).get();

      // Check if the document exists
      if (docSnapshot.exists) {
        // Extract the data from the document
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // Convert GeoPoint to LatLng if present
        if (data.containsKey('home_address') &&
            data['home_address'] is GeoPoint) {
          GeoPoint homeGeoPoint = data['home_address'];
          data['home_address'] =
              LatLng(homeGeoPoint.latitude, homeGeoPoint.longitude);
        }

        if (data.containsKey('work_address') &&
            data['work_address'] is GeoPoint) {
          GeoPoint workGeoPoint = data['work_address'];
          data['work_address'] =
              LatLng(workGeoPoint.latitude, workGeoPoint.longitude);
        }

        // Return the data with GeoPoints converted to LatLng
        return data;
      } else {
        print('No address data found for user');
        return null;
      }
    } catch (e) {
      // Handle error, print error message
      print('Error retrieving user address: $e');
      return null;
    }
  }

  // Function to load user addresses from Firestore
  Future<void> loadUserAddresses() async {
    String userId = widget.currentUserId; // Replace with the actual userId
    Map<String, dynamic>? addresses = await getUserAddresses(userId);

    if (addresses != null) {
      // Access the addresses as LatLng objects
      LatLng homeLocation = addresses['home_address'] ?? LatLng(0, 0);
      LatLng workLocation = addresses['work_address'] ?? LatLng(0, 0);

      // Get the place names from LatLng coordinates
      String homeName = await _getPlaceNameFromCoordinates(
          homeLocation.latitude, homeLocation.longitude);
      String workName = await _getPlaceNameFromCoordinates(
          workLocation.latitude, workLocation.longitude);

      setState(() {
        // Store the place names
        homePlaceName = homeName;
        workPlaceName = workName;
      });
    } else {
      // Handle case when no addresses are available
      print("No addresses found.");
    }
  }

  // Function to get place name from coordinates
  Future<String> _getPlaceNameFromCoordinates(
      double latitude, double longitude) async {
    try {
      // Use the geocoding package to get the address from the coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.locality}, ${place.subLocality}'; // You can customize this
      }
      return 'Unknown Location';
    } catch (e) {
      print('Error getting place name: $e');
      return 'Error fetching address';
    }
  }
}
