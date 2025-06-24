import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Screens/Home/Drawer/BuildDrawer.dart';
import 'package:taxi/Screens/bookingRide/start_booking.dart';
import 'package:taxi/Utils/cardWallet.dart';
import 'package:taxi/Utils/homeAppBar.dart';
import 'package:taxi/Utils/texts.dart';

class HomePage extends StatefulWidget {
  final String currentUserId;

  const HomePage({super.key, required this.currentUserId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<UserModel?> getUserModel(String userId) async {
    try {
      DocumentSnapshot userDoc = await usersRef.doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromDoc(userDoc);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: CustomDrawer(currentUserId: widget.currentUserId),
      body: FutureBuilder<UserModel?>(
        future: getUserModel(widget.currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: greenColor));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Failed to load user data."));
          }

          final userModel = snapshot.data!;
          return buildHomeContent(userModel);
        },
      ),
    );
  }

  Widget buildHomeContent(UserModel userModel) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeAppBar(currentUserId: widget.currentUserId),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: WalletCard(isLoading: false, userModel: userModel),
            ),
            const Divider(indent: 30, endIndent: 30),
            // Removed the previous reklam image container here
            const Spacer(),
          ],
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Material(
                borderRadius: BorderRadius.circular(40),
                elevation: 12,
                shadowColor: taxiYelloColor.withOpacity(_glowAnimation.value),
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StartBooking(
                          currentUserId: widget.currentUserId,
                          userModel: userModel,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: taxiYelloColor,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/images/taxicap.png",
                          width: 36,
                          height: 36,
                        ),
                        const SizedBox(width: 12),
                        robotoText(
                            "Book a Ride", Colors.black87, 20, FontWeight.bold),
                        const Spacer(),
                        Icon(
                          Icons.drive_eta_outlined,
                          color: blackColor,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
