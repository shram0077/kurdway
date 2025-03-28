import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:taxi/Constant/colors.dart';
import 'package:taxi/Models/UserModel.dart';
import 'package:taxi/Utils/texts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletCard extends StatefulWidget {
  final bool isLoading;
  final UserModel userModel;

  const WalletCard({Key? key, required this.isLoading, required this.userModel})
      : super(key: key);

  @override
  _WalletCardState createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  bool _isBalanceVisible = true;

  @override
  void initState() {
    super.initState();
    _loadBalanceVisibility();
  }

  // Load the visibility setting from SharedPreferences
  void _loadBalanceVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceVisible = prefs.getBool('isBalanceVisible') ??
          true; // Default to true if no setting found
    });
  }

  // Save the visibility setting to SharedPreferences
  void _toggleBalanceVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
      prefs.setBool('isBalanceVisible', _isBalanceVisible); // Save the setting
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 9.0, top: 4, right: 5, bottom: 5),
      width: 395,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color.fromARGB(255, 8, 171, 90),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.isLoading
                  ? Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(149, 220, 220, 220)),
                    )
                  : robotoText("Balance", whiteColor, 22, FontWeight.bold),
              IconButton(
                onPressed:
                    _toggleBalanceVisibility, // Toggle balance visibility
                icon: Icon(
                  _isBalanceVisible ? EvaIcons.eyeOff : EvaIcons.eye,
                  color: whiteColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              widget.isLoading
                  ? SizedBox()
                  : Icon(
                      EvaIcons.creditCard,
                      color: whiteColor,
                    ),
              widget.isLoading
                  ? Container(
                      width: 110,
                      height: 25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(149, 220, 220, 220)),
                    )
                  : robotoText(
                      _isBalanceVisible
                          ? " ****"
                          : " ${widget.userModel.walletBalance}",
                      whiteColor,
                      22,
                      FontWeight.bold), // Hide balance if false
              widget.isLoading
                  ? SizedBox()
                  : _isBalanceVisible
                      ? Container()
                      : robotoText(" IQD", whiteColor, 22, FontWeight.w900),
            ],
          ),
          SizedBox(
            height: 21,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 3),
                width: 130,
                height: 31,
                decoration: ShapeDecoration(
                  color: greenColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: whiteColor,
                      size: 20,
                    ),
                    robotoText(
                        " Transactions", whiteColor, 15, FontWeight.bold),
                  ],
                ),
              ),
              Spacer(),
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/Card_Payment.png")),
                      color: greenColor2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  robotoText("withdrawal", whiteColor, 13, FontWeight.w800),
                ],
              ),
              SizedBox(
                width: 8,
              ),
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/deposit.png")),
                      color: greenColor2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  robotoText("Deposit", whiteColor, 13, FontWeight.w800),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

loadingCardWallet() {
  return Container(
    padding: const EdgeInsets.only(left: 9.0, top: 4, right: 5, bottom: 5),
    width: 395,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Color(0xFF0AD36F),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color.fromARGB(149, 220, 220, 220)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 5),
              child: Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(149, 220, 220, 220)),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color.fromARGB(149, 220, 220, 220)),
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              width: 110,
              height: 25,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color.fromARGB(149, 220, 220, 220)),
            )
          ],
        ),
        SizedBox(
          height: 21,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 3),
              width: 130,
              height: 31,
              decoration: ShapeDecoration(
                color: const Color.fromARGB(149, 220, 220, 220),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            Spacer(),
            Column(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: ShapeDecoration(
                    color: const Color.fromARGB(149, 220, 220, 220),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 8,
            ),
            Column(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: ShapeDecoration(
                    color: const Color.fromARGB(149, 220, 220, 220),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    ),
  );
}
