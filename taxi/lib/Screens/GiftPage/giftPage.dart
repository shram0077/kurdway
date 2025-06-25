// Dummy Pages
import 'package:flutter/material.dart';
import 'package:taxi/Utils/texts.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: robotoText("Favorites", Colors.white, 20, FontWeight.bold),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show a notification dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: robotoText(
                      "Notification", Colors.black, 20, FontWeight.bold),
                  content: robotoText("You have new updates!", Colors.black, 16,
                      FontWeight.normal),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child:
                          robotoText("OK", Colors.blue, 16, FontWeight.normal),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gift Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/taxicap.png', // Ensure you have this image in your assets
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  robotoText(
                    "Congratulations! You've received a special gift.",
                    Colors.black,
                    18,
                    FontWeight.bold,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You claimed your gift! 🎁"),
                        ),
                      );
                    },
                    child: robotoText(
                        "Claim Gift", Colors.white, 16, FontWeight.normal),
                  ),
                ],
              ),
            ),
            // Notifications List Section
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: robotoText(
                  "Notifications",
                  Colors.black,
                  20,
                  FontWeight.bold,
                ),
              ),
            ),
            // Notification List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5, // You can change this number based on your data
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.notification_important),
                  title: robotoText("Notification #${index + 1}", Colors.black,
                      16, FontWeight.normal),
                  subtitle: robotoText("You have new updates.", Colors.grey, 14,
                      FontWeight.normal),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Handle notification tap
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: robotoText(
                            "Notification #${index + 1} tapped!",
                            Colors.white,
                            16,
                            FontWeight.normal),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
