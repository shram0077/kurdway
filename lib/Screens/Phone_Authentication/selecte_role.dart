import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Screens/Phone_Authentication/Information_pages/driver_informations.dart';
import 'package:taxi/Screens/Phone_Authentication/Information_pages/passeners_informaion.dart';
import 'package:taxi/Utils/texts.dart';

class SelecteYourRole extends StatefulWidget {
  const SelecteYourRole(
      {super.key, required this.phoneNo, required this.isRegistered});
  final String phoneNo;
  final bool isRegistered;

  @override
  State<SelecteYourRole> createState() => _SelecteYourRoleState();
}

class _SelecteYourRoleState extends State<SelecteYourRole> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        centerTitle: false,
        title: robotoText("Role", blackColor, 20, FontWeight.w500),
        backgroundColor: whiteColor,
        elevation: 0.8,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.globe,
                color: blackColor,
              )),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 12, bottom: 5),
              child: robotoText(
                  "Select Your Role!", blackColor, 32, FontWeight.normal)),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 15),
            child: robotoText(
                "Please tell us whether you're a taxi driver or a passenger?",
                blackColor.withOpacity(0.5),
                16,
                FontWeight.normal),
          ),
          SizedBox(
            height: 25,
          ),
          Center(
            child: Column(
              children: [
                buildCardRole("Taxi Driver", "assets/images/taxicap.png", true),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  indent: 20,
                  endIndent: 20,
                ),
                SizedBox(
                  height: 10,
                ),
                buildCardRole("Passenger", "assets/images/passenger.png", false)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCardRole(String text, String imgPath, isChossedTaxiDriver) {
    return GestureDetector(
      onTap: () async {
        if (isChossedTaxiDriver) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: DriverInfoForm(
                phoneNo: widget.phoneNo,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: PassenersInformaion(
                phoneNo: widget.phoneNo,
              ),
            ),
          );
        }
      },
      child: Card(
        child: Container(
          width: 205,
          height: 180,
          decoration: ShapeDecoration(
            color: splashGreenBGColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 10,
              ),
              Image.asset(
                imgPath, // Update with your image path
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              Container(
                width: 205,
                height: 48,
                decoration: ShapeDecoration(
                  color: taxiYelloColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12)),
                  ),
                ),
                child: Center(
                  child: robotoText(text, blackColor, 18, FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
