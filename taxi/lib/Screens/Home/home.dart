import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Constant/firesbase.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Screens/Home/Drawer/BuildDrawer.dart';
import 'package:taxi/Screens/bookingRide/start_booking.dart';
import 'package:taxi/Utils/Loadings/AppBar_loading.dart';
import 'package:taxi/Utils/Loadings/Cardwallet_loading.dart';
import 'package:taxi/Utils/Loadings/bookRide_loading.dart';
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                loadingAppBarContainer(),
                SizedBox(
                  height: 25,
                ),
                buildLoadingCard(),
                const Divider(indent: 30, endIndent: 30),
                const Spacer(),

                // Optionally add a placeholder for the Book a Ride button shimmer, or just empty space
                loadingBookRideButton(),
              ],
            );
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
                shadowColor:
                    taxiYellowColor.withOpacity(_glowAnimation.value * 0.6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  splashColor: taxiYellowColor.withOpacity(0.3),
                  highlightColor: taxiYellowColor.withOpacity(0.1),
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
                      color: taxiYellowColor,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: taxiYellowColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/images/taxicap.png",
                          width: 36,
                          height: 36,
                        ),
                        const SizedBox(width: 16),
                        robotoText(
                          "Book a Ride",
                          taxiDarkText,
                          20,
                          FontWeight.bold,
                        ),
                        const Spacer(),
                        Icon(
                          Icons.drive_eta_outlined,
                          color: taxiDarkText,
                          size: 26,
                        ),
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
