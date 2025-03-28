import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restart_app/restart_app.dart';
import 'package:taxi/Constant/colors.dart'; // Your colors
import 'package:taxi/Services/DatabaseServices.dart';
import 'package:taxi/Utils/texts.dart';

class OtpVerification extends StatefulWidget {
  final String licensePlate;
  final String carBM;
  final String gender;
  final String name;
  final String phoneNo;
  final bool isRegistered;
  final String profilePictureUri;
  final dynamic isDriver;
  const OtpVerification({super.key, 
    required this.licensePlate,
    required this.carBM,
    required this.gender,
    required this.name,
    required this.phoneNo,
    required this.isRegistered,
    required this.profilePictureUri,
    required this.isDriver,
  });

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool isLoading = false;
  bool sendingCode = false;
  int taxiNumber = 100;

  Future<void> verifyPhoneNumber() async {
    setState(() {
      sendingCode = true;
    });
    String phoneNumber = widget.phoneNo.trim();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-sign-in (if supported)
        await FirebaseAuth.instance.signInWithCredential(credential);
        setState(() {
          sendingCode = false;
        });
        Fluttertoast.showToast(msg: "Phone number automatically verified!");
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          sendingCode = false;
        });
        Fluttertoast.showToast(msg: "Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        setState(() {
          sendingCode = false;
        });
        Fluttertoast.showToast(msg: "OTP code sent!");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> verifyOTP() async {
    String otpCode = _otpController.text.trim();

    if (otpCode.isEmpty) {
      Fluttertoast.showToast(msg: "Enter the OTP");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      print("User-entered OTP: $otpCode");
      print("Stored Verification ID: $_verificationId");

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user == null) {
        print("User authentication failed!");
        Fluttertoast.showToast(msg: "User authentication failed!");
        return;
      }

      Fluttertoast.showToast(msg: "Phone verified successfully!");

      String userId = userCredential.user!.uid;

      if (widget.isDriver == "none") {
        print("User just trying to Logging ");
        Restart.restartApp();
      } else {
        if (widget.isDriver == true) {
          await Databaseservices.createUser(
            userId,
            widget.name,
            widget.phoneNo.trim(),
            widget.profilePictureUri,
            '',
            'driver',
            context,
          );
          await Databaseservices.createtaxiInformation(
            userId,
            widget.name,
            widget.phoneNo.trim(),
            widget.licensePlate,
            widget.carBM,
            context,
          );
        } else if (!widget.isRegistered) {
          await Databaseservices.createUser(
            userId,
            widget.name,
            widget.phoneNo.trim(),
            widget.profilePictureUri,
            '',
            'passenger',
            context,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.message ==
          "The verification code from SMS/TOTP is invalid. Please check and enter the correct verification code again.") {
        Fluttertoast.showToast(
            backgroundColor: Colors.red,
            msg: "Please Enter the valid OPT Code");
      }
      print("🔥 Firebase Auth Error: ${e.message}");
      Fluttertoast.showToast(msg: "Firebase Error: ${e.message}");
      print(e.message);
    } catch (e) {
      print("❌ General Error: ${e.toString()}");
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verifyPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          isLoading ? null : verifyOTP();
        },
        backgroundColor: splashGreenBGColor,
        child: isLoading
            ? CircularProgressIndicator(color: whiteColor)
            : Icon(
                CupertinoIcons.arrow_right,
                color: whiteColor,
              ),
      ),
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.8,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.globe)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 9.0, left: 12, bottom: 5),
              child: robotoText("Enter Verification Code", blackColor, 30,
                  FontWeight.normal)),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 15),
            child: Text.rich(
              TextSpan(
                text: "We sent verification code to ",
                style: GoogleFonts.roboto(
                  color: blackColor.withOpacity(0.5),
                  fontSize: 16,
                ),
                children: [
                  TextSpan(
                    text: widget.phoneNo,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: blackColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _otpController,
              enabled: sendingCode == true ? false : true,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6, // Limit OTP to 6 digits (or as per your OTP length)
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                hintText: 'e.g. 123456',
                hintStyle: GoogleFonts.roboto(
                  color: blackColor.withOpacity(0.3),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide(color: splashGreenBGColor, width: 2.0),
                ),
                counterText: "", // Hide the counter
              ),
            ),
          ),
          TextButton(
              onPressed: () {
                // to resend the code
                verifyPhoneNumber();
              },
              child: robotoText(
                  "Resend code", splashGreenBGColor, 16, FontWeight.w500)),
        ],
      ),
    );
  }
}
