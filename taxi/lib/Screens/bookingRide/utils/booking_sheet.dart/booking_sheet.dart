import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const Color greenColor = Color(0xFF27AE60);

class BookingSheet extends StatefulWidget {
  final String taxiId;
  final String driverName;
  final String carModel;
  final Function(String address, LatLng position) onBookingConfirmed;

  const BookingSheet({
    super.key,
    required this.taxiId,
    required this.driverName,
    required this.carModel,
    required this.onBookingConfirmed,
  });

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();

  LatLng? _destinationPosition;
  GoogleMapController? _mapController;
  bool _isSearching = false;
  bool _showClearButton = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Listener to show/hide the clear button in the text field
    _destinationController.addListener(() {
      if (_showClearButton != _destinationController.text.isNotEmpty) {
        setState(() {
          _showClearButton = _destinationController.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    // Clean up resources
    _destinationController.dispose();
    _mapController?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Debounces the search to avoid excessive API calls while the user is typing.
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _searchDestination(query);
      }
    });
  }

  /// Searches for a location using geocoding and updates the map.
  Future<void> _searchDestination(String placeName) async {
    setState(() => _isSearching = true);

    try {
      List<Location> locations = await locationFromAddress(placeName);
      if (locations.isNotEmpty) {
        final location = locations.first;
        _destinationPosition = LatLng(location.latitude, location.longitude);

        // Fetch a more user-friendly address format
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final formattedAddress =
              '${p.name ?? ''}, ${p.thoroughfare ?? ''}, ${p.locality ?? ''}';
          // Update controller without triggering another search
          _destinationController.value = TextEditingValue(
            text: formattedAddress,
            selection: TextSelection.collapsed(offset: formattedAddress.length),
          );
        }

        // Animate map to the new position
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_destinationPosition!, 15.0),
        );

        setState(() {});
      } else {
        _showErrorSnackBar('Location not found. Please try another search.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred. Please check your connection.');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  /// Clears the destination and resets the UI.
  void _clearDestination() {
    _destinationController.clear();
    setState(() {
      _destinationPosition = null;
    });
  }

  /// Validates the form and confirms the booking.
  void _submitBooking() {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      widget.onBookingConfirmed(
        _destinationController.text,
        _destinationPosition!,
      );

      Navigator.of(context).pop(); // Close booking sheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking confirmed! Your driver is on the way.'),
          backgroundColor: greenColor,
        ),
      );
    }
  }

  /// Helper to show a standardized error SnackBar.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using Padding with viewInsets to handle keyboard overlap
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDragHandle(),
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildDestinationInput(),
                const SizedBox(height: 16),
                _buildMapView(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A small visual indicator that the sheet is draggable.
  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// The header section with driver and car information.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book a Ride',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'With ${widget.driverName} in a ${widget.carModel}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// The destination text input field.
  Widget _buildDestinationInput() {
    return TextFormField(
      controller: _destinationController,
      onChanged: _onSearchChanged,
      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a destination.';
        }
        if (_destinationPosition == null) {
          return 'Please select a valid location from the search.';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Where are you going?',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        prefixIcon: const Icon(CupertinoIcons.search, color: Colors.grey),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: greenColor),
                ),
              ),
            if (_showClearButton && !_isSearching)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _clearDestination,
              ),
          ],
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: greenColor, width: 1.5),
        ),
      ),
    );
  }

  /// The map view that appears when a destination is selected.
  Widget _buildMapView() {
    // Animate the size of the container to smoothly show/hide the map.
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _destinationPosition == null
          ? const SizedBox.shrink()
          : SizedBox(
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _destinationPosition!,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: _destinationPosition!,
                    ),
                  },
                  onMapCreated: (controller) => _mapController = controller,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
    );
  }

  /// The main action buttons for confirming or canceling the booking.
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: (_isSearching || _destinationPosition == null)
              ? null
              : _submitBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: greenColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: Text(
            'Confirm Booking',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
