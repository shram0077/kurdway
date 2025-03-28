
import 'package:flutter/cupertino.dart';
import 'package:taxi/Constant/colors.dart';

loadingProfileContiner() {
  return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.all(0.5),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: splashGreenBGColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 78, 89, 123).withOpacity(0.1),
              spreadRadius: 0.2,
              blurRadius: 0.2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ));
}