import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Utils/texts.dart';

class BookRidePage extends StatefulWidget {
  final String currentUserId;
  final UserModel userModel;

  const BookRidePage(
      {super.key, required this.currentUserId, required this.userModel});

  @override
  _BookRidePageState createState() => _BookRidePageState();
}

class _BookRidePageState extends State<BookRidePage>
    with TickerProviderStateMixin {
  TextEditingController currentLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  Set<Marker> _taxiMarkers = {};
  bool is3D = true;
  double _sheetPosition = 0.4; // Initial position of the sheet

  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor taxiIcon = BitmapDescriptor.defaultMarker;
  Set<Heatmap> _heatmaps = {};
  HeatmapGradient gradient = HeatmapGradient([
    HeatmapGradientColor(Colors.green, 0.1),
    HeatmapGradientColor(Colors.yellow, 0.3),
    HeatmapGradientColor(Colors.orange, 0.5),
    HeatmapGradientColor(Colors.red, 0.7),
    HeatmapGradientColor(Colors.purple, 1.0),
  ]);

  void _setHeatmap() {
    // Define your heatmap data points
    List<WeightedLatLng> generalPopulationPoints = [
      WeightedLatLng(LatLng(35.5666, 45.4333),
          weight: 4.0), // Sulaymaniyah City Center
      WeightedLatLng(LatLng(35.5997, 45.4500), weight: 1.0), // Slemani Museum
      WeightedLatLng(LatLng(35.5500, 45.4000), weight: 2.0), // Azmar Mountain
      WeightedLatLng(LatLng(35.6000, 45.5000),
          weight: 3.0), // Chavi Land (Amusement Park)
      WeightedLatLng(LatLng(35.5700, 45.4700),
          weight: 7.0), // Sulaymaniyah Grand Mosque
      WeightedLatLng(LatLng(35.5400, 45.4600), weight: 1.5), // Shorsh Park
      WeightedLatLng(LatLng(35.5600, 45.4800), weight: 2.5), // City Star Mall
    ];

    // Create a Heatmap layer with the heatmapId
    setState(() {
      _heatmaps.add(
        Heatmap(
          gradient: gradient,
          heatmapId: HeatmapId("heatmap1"), // Unique ID for the heatmap
          data: generalPopulationPoints,
          radius: HeatmapRadius.fromPixels(15), // Adjust the radius as needed
        ),
      );
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      DocumentSnapshot userDoc = await usersRef.doc(widget.currentUserId).get();
      if (userDoc.exists) {
        double latitude = userDoc['currentLocation']['latitude'];
        double longitude = userDoc['currentLocation']['longitude'];

        String currentLocation =
            await _getAddressFromCoordinates(latitude, longitude);

        setState(() {
          currentLocationController.text = currentLocation;
          _currentPosition = LatLng(latitude, longitude);
        });

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_currentPosition!, 15),
          );
        }
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<String> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.locality}, ${place.country}';
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Error fetching address';
    }
  }

  Future<void> _onSelectDestination(String selectedPlace) async {
    if (selectedPlace.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(selectedPlace);
        if (locations.isNotEmpty) {
          LatLng newDestination = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );

          setState(() {
            _destinationPosition = newDestination;
            destinationLocationController.text = selectedPlace;
          });

          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(_destinationPosition!, 15),
            );
          }
        }
      } catch (e) {
        print('Error fetching destination: $e');
      }
    }
  }

  Future<List<String>> _getPlaceSuggestions(String query) async {
    if (query.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(query);
        return locations
            .map((location) =>
                "${location.latitude}, ${location.longitude}") // Show formatted address or other details
            .toList();
      } catch (e) {
        print('Error fetching suggestions: $e');
        return [];
      }
    }
    return [];
  }

  void toggleMapView() {
    setState(() {
      is3D = !is3D;
    });
    if (_mapController != null) {
      CameraPosition cameraPosition = CameraPosition(
        target: _currentPosition!,
        zoom: 15,
        tilt: is3D ? 45 : 0,
        bearing: is3D ? 90 : 0,
      );
      _mapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  Future<void> _fetchTaxiLocations() async {
    taxisRef.where("isActive", isEqualTo: true).snapshots().listen((snapshot) {
      Set<Marker> updatedMarkers = {};
      for (var doc in snapshot.docs) {
        var data = doc.data();

        if (data.containsKey('location')) {
          var location = data['location']; // Get the location map
          if (location.containsKey('latitude') &&
              location.containsKey('longitude')) {
            double lat = location['latitude']; // ✅ Correct
            double lng = location['longitude']; // ✅ Correct

            updatedMarkers.add(
              Marker(
                  markerId: MarkerId(doc.id),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(title: "Taxi ${doc.id}"),
                  icon: taxiIcon),
            );
          }
        }
      }
      setState(() {
        _taxiMarkers = updatedMarkers;
      });
      print("Fetched ${snapshot.docs.length} taxis from Firestore");
    });
  }

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

  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();

    setCoustomMarkerIcon();
    _getCurrentLocation();
    _fetchTaxiLocations();
    _setHeatmap();
    _trackUserLocation(); // Start tracking user location
  }

  void _trackUserLocation() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        // Animate camera to new position
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_currentPosition!),
          );
        }

        // Update Firestore with new location
        usersRef.doc(widget.currentUserId).update({
          'currentLocation': {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': FieldValue.serverTimestamp(),
          }
        });

        print("Location updated: ${position.latitude}, ${position.longitude}");
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Stop listening when widget is disposed

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String userRole = widget.userModel.role;

    return Scaffold(
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
            icon:
                Icon(is3D ? Icons.maps_home_work_outlined : Icons.map_outlined),
            onPressed: toggleMapView,
          ),
        ],
      ),
      body: Column(
        children: [
          if (userRole != 'driver')
            Expanded(
              child: _currentPosition == null
                  ? Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        GoogleMap(
                          heatmaps: _heatmaps,
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
                                infoWindow: InfoWindow(title: "Me"),
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
                            _mapController = controller;
                          },
                        ),
                        Positioned(
                          bottom: 50,
                          right: 16,
                          child: FloatingActionButton(
                            onPressed: _updateLocation,
                            backgroundColor: taxiYelloColor,
                            child: Icon(Icons.my_location, color: Colors.white),
                          ),
                        ),
                        DraggableScrollableSheet(
                          initialChildSize: _sheetPosition,
                          minChildSize: 0.0,
                          maxChildSize: 0.4,
                          builder: (_, controller) => Container(
                            color: whiteColor,
                            child: ListView(
                              controller: controller,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8, top: 8),
                                  child: _buildLocationField(
                                      currentLocationController,
                                      "Current Location",
                                      Icons.location_on,
                                      false),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8, top: 8),
                                  child: TypeAheadField<String>(
                                    suggestionsCallback: (pattern) async {
                                      return await _getPlaceSuggestions(
                                          pattern); // Fetch suggestions
                                    },
                                    itemBuilder: (context, String suggestion) {
                                      return ListTile(
                                        title: Text(suggestion),
                                      );
                                    },
                                    onSelected: (String suggestion) {
                                      _onSelectDestination(
                                          suggestion); // Move the map only when selected
                                    },
                                    builder: (context, controller, focusNode) {
                                      return _buildLocationField(
                                          controller,
                                          "Enter Destination",
                                          Icons.location_searching,
                                          true);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  void _updateLocation() async {
    try {
      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      // Update Firestore with new location
      await usersRef.doc(widget.currentUserId).update({
        'currentLocation': {
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': FieldValue.serverTimestamp(), // Timestamp for tracking
        }
      });

      // Update UI state
      setState(() {
        _currentPosition = LatLng(latitude, longitude);
        currentLocationController.text = "$latitude, $longitude";
      });

      // Move camera to new location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 15),
        );
      }

      print("Location updated: $latitude, $longitude");
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  Widget _buildLocationField(TextEditingController controller, String hintText,
      IconData icon, bool enabled) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color.fromARGB(255, 239, 241, 239),
      ),
      child: TextField(
        cursorColor: greenColor,
        style: TextStyle(
            color: const Color.fromARGB(255, 28, 33, 36),
            fontWeight: FontWeight.w700,
            fontSize: 18),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: greenColor),
          border: InputBorder.none,
        ),
        enabled: enabled,
        controller: controller,
        onChanged: (value) {
          if (enabled) {
            _onSelectDestination(value);
          }
        },
      ),
    );
  }
}
