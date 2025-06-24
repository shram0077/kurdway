import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Screens/bookingRide/utils/taxi_sheet.dart';
import 'package:taxi/Services/DatabaseServices.dart';
import 'package:taxi/Utils/loading_page.dart';
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
  LatLng? _destinationPosition;
  Set<Marker> _taxiMarkers = {};

  TextEditingController destinationLocationController = TextEditingController();

  String? currentLocation;
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStreamSubscription;

  String? homePlaceName;
  String? workPlaceName;
  String mapstyle = '';
  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context)
        .loadString("mapstyle/style.json")
        .then((style) {
      mapstyle = style;
    });
    startLiveLocationTracking();
    setCoustomMarkerIcon();
    _fetchTaxiLocations();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchTaxiLocations() async {
    taxisRef.where("isActive", isEqualTo: true).snapshots().listen((snapshot) {
      Set<Marker> updatedMarkers = {};

      for (var doc in snapshot.docs) {
        var data = doc.data();

        if (data.containsKey('location')) {
          var location = data['location'];

          if (location.containsKey('latitude') &&
              location.containsKey('longitude')) {
            double lat = location['latitude'];
            double lng = location['longitude'];

            updatedMarkers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(lat, lng),
                icon: taxiIcon,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.5,
                      minChildSize: 0.3,
                      maxChildSize: 0.95,
                      expand: false,
                      builder: (context, scrollController) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: TaxiInfoSheet(
                          taxiId: doc.id,
                          scrollController: scrollController,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        }
      }

      setState(() {
        _taxiMarkers = updatedMarkers;
      });
    });
  }

  void startLiveLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10, // meters before it triggers another update
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
      currentLocation = await _getAddressFromCoordinates(
          position.latitude, position.longitude);

      // Optional: Update Firestore or database
      Databaseservices.updatePosition(widget.currentUserId,
          widget.userModel.role, position.latitude, position.longitude);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      // Move the map camera if needed
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentPosition!),
        );
      }
    });
  }

  // Convert coordinates to an address
  Future<String> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

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

        print('Address found: $address'); // Log the found address
        return address.isNotEmpty
            ? address
            : 'Address details unavailable'; // Return the address or a message
      } else {
        print(
            'No address found for coordinates: $latitude, $longitude'); // Log no address found
        return 'Unknown Location';
      }
    } catch (e) {
      print('Error fetching address: $e'); // Log the specific error
      return 'Error fetching address';
    }
  }

  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor taxiIcon = BitmapDescriptor.defaultMarker;
  void setCoustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/icons/placeholder.png")
        .then((icon) {
      setState(() {
        currentLocationIcon = icon;
      });
    });
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      "assets/icons/pin.png",
    ).then((icon) {
      setState(() {
        destinationIcon = icon;
      });
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/icons/taxi.png")
        .then((icon) {
      setState(() {
        taxiIcon = icon;
      });
    });
  }

  Future<void> _searchDestination(String placeName) async {
    try {
      List<Location> locations = await locationFromAddress(placeName);
      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _destinationPosition = LatLng(location.latitude, location.longitude);
        });
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_destinationPosition!, 15),
          );
        }
      }
    } catch (e) {
      print('Error finding location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found')),
      );
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
                // Navigator.push(
                //   context,
                //   PageTransition(
                //     type: PageTransitionType.bottomToTop, // Animation type
                //     child: BookRidePage(
                //         currentUserId: widget.currentUserId,
                //         userModel: widget.userModel), // Navigate to this screen
                //   ),
                // );
              },
            ),
          ],
        ),
        body: _currentPosition == null
            ? LocationLoading(title: "Getting your current location...")
            : Column(
                children: [
                  _fromField(),
                  SizedBox(
                    height: 4,
                  ),
                  _destinationField(),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        GoogleMap(
                          mapType: MapType.normal,
                          zoomControlsEnabled: false,
                          trafficEnabled: true,
                          compassEnabled: false,
                          buildingsEnabled: true,
                          myLocationButtonEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: _currentPosition!,
                            zoom: 15,
                            tilt: 45,
                            bearing: 90,
                          ),
                          markers: {
                            if (_currentPosition != null)
                              Marker(
                                markerId: MarkerId("currentLocation"),
                                position: _currentPosition!,
                                infoWindow: InfoWindow(title: "You are here"),
                                icon: currentLocationIcon,
                              ),
                            if (_destinationPosition != null)
                              Marker(
                                markerId: MarkerId("destination"),
                                position: _destinationPosition!,
                                infoWindow: InfoWindow(title: "Destination"),
                                icon: destinationIcon,
                              ),
                            ..._taxiMarkers,
                          },
                          onMapCreated: (GoogleMapController controller) {
                            controller.setMapStyle(mapstyle);
                            _mapController = controller;
                          },
                          onTap: (LatLng tappedPosition) async {
                            _destinationPosition = tappedPosition;

                            String address = await _getAddressFromCoordinates(
                                tappedPosition.latitude,
                                tappedPosition.longitude);
                            setState(() {
                              destinationLocationController.text = address;
                            });
                          },
                        ),
                        if (_destinationPosition != null)
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                    // foreground
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      destinationLocationController.clear();
                                      _destinationPosition = null;
                                    });
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.aBeeZee(
                                      color: whiteColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: greenColor,
                                    // foreground
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'Find taxi',
                                    style: GoogleFonts.aBeeZee(
                                      color: whiteColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ));
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
          style: GoogleFonts.aBeeZee(
              color: Colors.black87, fontWeight: FontWeight.bold),
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
              suffixIcon: SizedBox(
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
                              startLiveLocationTracking();
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
        style: GoogleFonts.aBeeZee(
            color: Colors.black87, fontWeight: FontWeight.bold),
        controller: destinationLocationController,
        cursorColor: greenColor,
        onSubmitted: (value) {
          _searchDestination(value); // Search and mark on map
        },
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
            borderSide: BorderSide.none,
          ),
        ),
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
