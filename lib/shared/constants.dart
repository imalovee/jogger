import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const interStyle  = TextStyle(
  fontFamily: "Inter",
  fontSize: 14,
  fontWeight: FontWeight.w600
);

String formatDuration(Duration duration) {
  final DateTime time = DateTime(0).add(duration);
  return DateFormat('HH:mm:ss').format(time);
}

class AppButton extends StatelessWidget {
  const AppButton({super.key,  this.callback});

  
  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: callback,
      child: Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu),
            Icon(Icons.person)
          ],
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
        ),
      ),
    );
  }
}