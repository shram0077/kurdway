import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/Car_Model.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Utils/texts.dart';
import 'package:url_launcher/url_launcher.dart';

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
              return const Center(child: Text("Taxi information not found."));
            }

            final car = CarModel.fromDoc(carSnapshot.data!);

            return StreamBuilder<DocumentSnapshot>(
              stream: usersRef.doc(car.driverId).snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Center(child: Text("Driver profile not found."));
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
                        backgroundColor: Colors.yellow,
                        backgroundImage: user.profilePicture.isNotEmpty
                            ? CachedNetworkImageProvider(user.profilePicture)
                            : null,
                        child: user.profilePicture.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: robotoText(
                          user.name, Colors.black, 18, FontWeight.bold),
                      subtitle: robotoText("Driver Info Below", Colors.grey, 14,
                          FontWeight.normal),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: robotoText(
                          "Phone", Colors.black, 16, FontWeight.normal),
                      subtitle: robotoText(
                          user.phone.isNotEmpty
                              ? user.phone
                              : car.phone.isNotEmpty
                                  ? car.phone
                                  : 'Not available',
                          Colors.grey,
                          14,
                          FontWeight.normal),
                    ),
                    ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: robotoText(
                          "Car Model", Colors.black, 16, FontWeight.normal),
                      subtitle: robotoText(
                          car.carModel, Colors.grey, 14, FontWeight.normal),
                    ),
                    ListTile(
                      leading: const Icon(Icons.confirmation_number),
                      title: robotoText(
                          "License Plate", Colors.black, 16, FontWeight.normal),
                      subtitle: robotoText(
                          car.licensePlate, Colors.grey, 14, FontWeight.normal),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.call),
                            label: robotoText("Call Driver", Colors.white, 16,
                                FontWeight.normal),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () async {
                              final phone = user.phone.isNotEmpty
                                  ? user.phone
                                  : car.phone;
                              if (phone.isNotEmpty) {
                                final uri = Uri(scheme: 'tel', path: phone);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Cannot make the call")),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.close),
                            label: robotoText(
                                "Close", Colors.white, 16, FontWeight.normal),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
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
}
