import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
// Firestore refs
final usersRef = _firestore.collection('users');
final taxisRef = _firestore.collection('taxis');
final addressRef = _firestore.collection("saved address's");

//
final fileluApiKey = "33483if6tnlmefeenc68f";
final String googleApiKey = 'AIzaSyCHy6Vz6SiDq-imJ8VbF-aGrT215ep9GIU';
