import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/Car_Model.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Screens/bookingRide/utils/booking_sheet.dart/booking_sheet.dart';

class TaxiInfoSheet extends StatelessWidget {
  final String taxiId;
  final ScrollController scrollController;

  const TaxiInfoSheet({
    super.key,
    required this.taxiId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        StreamBuilder<DocumentSnapshot>(
          stream: taxisRef.doc(taxiId).snapshots(),
          builder: (context, carSnapshot) {
            if (carSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!carSnapshot.hasData || !carSnapshot.data!.exists) {
              return Center(
                child: Text(
                  "Taxi information not found.",
                  style: GoogleFonts.poppins(),
                ),
              );
            }

            final car = CarModel.fromDoc(carSnapshot.data!);

            return StreamBuilder<DocumentSnapshot>(
              stream: usersRef.doc(car.driverId).snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Center(
                    child: Text(
                      "Driver profile not found.",
                      style: GoogleFonts.poppins(),
                    ),
                  );
                }

                final user = UserModel.fromDoc(userSnapshot.data!);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.black,
                        backgroundImage: user.profilePicture.isNotEmpty
                            ? CachedNetworkImageProvider(user.profilePicture)
                            : null,
                        child: user.profilePicture.isEmpty
                            ? const Icon(
                                CupertinoIcons.person_fill,
                                color: Colors.white,
                                size: 36,
                              )
                            : null,
                      ),
                      title: Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            CupertinoIcons.star_fill,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(CupertinoIcons.phone),
                      title: Text(
                        "Phone",
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                      ),
                      subtitle: Text(
                        user.phone.isNotEmpty
                            ? user.phone
                            : car.phone.isNotEmpty
                                ? car.phone
                                : 'Not available',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.car_detailed),
                      title: Text(
                        "Car Model",
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                      ),
                      subtitle: Text(
                        car.carModel,
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    customLicensePlateTile(car.licensePlate),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton.filled(
                            color: greenColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            borderRadius: BorderRadius.circular(10),
                            child: Text(
                              "Book",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => BookingSheet(
                                  taxiId: taxiId,
                                  driverName: user.name,
                                  carModel: car.carModel,
                                  onBookingConfirmed: (address, position) {
                                    print(
                                        'Booking for $address at ${position.latitude}, ${position.longitude}');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black,
                            child: Text(
                              "Close",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget customLicensePlateTile(String licensePlate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 16, top: 4),
            child: Icon(CupertinoIcons.number, size: 24, color: Colors.black54),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "License Plate",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: buildPlateFromText(licensePlate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlateFromText(String plateText) {
    final parts = plateText.trim().split(' ');
    if (parts.length >= 3) {
      return buildPlate(
        provinceNumber: parts[0],
        letter: parts[1],
        number: parts.sublist(2).join(' '),
      );
    } else {
      return Text(
        'Invalid Plate Format',
        style: GoogleFonts.poppins(color: Colors.red),
      );
    }
  }

  Widget buildPlate({
    required String provinceNumber,
    required String letter,
    required String number,
  }) {
    double h = 45;

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 200,
        minWidth: 120,
        minHeight: 45,
        maxHeight: 45,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(6),
        color: const Color.fromARGB(255, 244, 242, 242),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: h,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 249, 30, 14),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("I", style: _plateSideTextStyle(smaller: true)),
                Text("R", style: _plateSideTextStyle(smaller: true)),
                Text("Q", style: _plateSideTextStyle(smaller: true)),
                Container(
                  width: 20,
                  color: Colors.black.withOpacity(0.9),
                  height: 0.3,
                ),
                Text("KR", style: _plateSideTextStyle(smaller: true)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(provinceNumber, style: _plateMainTextStyle(smaller: true)),
                Text(" $letter ", style: _plateMainTextStyle(smaller: true)),
                Text(number, style: _plateMainTextStyle(smaller: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _plateMainTextStyle({bool smaller = false}) => GoogleFonts.poppins(
        fontSize: smaller ? 18 : 25,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      );

  TextStyle _plateSideTextStyle({bool smaller = false}) => GoogleFonts.poppins(
        fontSize: smaller ? 7 : 9.5,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
}
