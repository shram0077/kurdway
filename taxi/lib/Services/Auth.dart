import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';

class Auth extends GetxController {
  static final _auth = FirebaseAuth.instance;
 static void logout() async {
    try {
      await _auth.signOut();

    Restart.restartApp();
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
    }
  }

}
