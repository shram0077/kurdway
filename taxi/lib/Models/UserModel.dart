import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi/encryption_decryption/encryption.dart';

class UserModel {
  String userid;
  String name;
  String phone;
  String profilePicture;
  String email;
  Timestamp joinedAt;
  String status; // "available", "on-trip", "offline"
  GeoPoint currentLocation;
  String currentCity;
  double walletBalance;
  List rideHistory;
  String role;

  UserModel(
      {required this.userid,
      required this.name,
      required this.phone,
      required this.email,
      required this.joinedAt,
      required this.status,
      required this.currentLocation,
      required this.walletBalance,
      required this.rideHistory,
      required this.profilePicture,
      required this.role,
      required this.currentCity});

  // Convert Firestore DocumentSnapshot to UserModel
  factory UserModel.fromDoc(DocumentSnapshot doc) {
    var locationData = doc["currentLocation"];
    GeoPoint location;

    if (locationData is GeoPoint) {
      location = locationData;
    } else if (locationData is Map<String, dynamic>) {
      location = GeoPoint(
          locationData["latitude"] ?? 0, locationData["longitude"] ?? 0);
    } else {
      location = GeoPoint(0, 0); // Default value
    }

    return UserModel(
      userid: doc["userId"],
      name: doc['name'],
      phone: doc['phone'],
      email: MyEncriptionDecription.decryptWithAESKey(doc["email"]),
      profilePicture: doc["profilePicture"],
      joinedAt: doc["joinedAt"],
      status: doc['status'],
      currentCity: doc['currentCity'],
      currentLocation: location,
      role: doc["role"],
      walletBalance: _getDoubleFromField(
          MyEncriptionDecription.decryptWithAESKey(doc['walletBalance'])),
      rideHistory: List.from(doc['rideHistory']),
    );
  }
  static double _getDoubleFromField(String field) {
    return double.tryParse(field) ?? 0.0;
  }
}
