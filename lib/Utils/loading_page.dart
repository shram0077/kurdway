
import 'package:flutter/material.dart';

class LocationLoading extends StatefulWidget {
  final String title;

  const LocationLoading({super.key, required this.title});
  @override
  _LocationLoadingState createState() => _LocationLoadingState();
}

class _LocationLoadingState extends State<LocationLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _animation,
        child: Text(
         widget.title,
          style: TextStyle(
            color: const Color.fromARGB(255, 147, 146, 146),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto', // Ensure Roboto is your font
          ),
        ),
      ),
    );
  }
}