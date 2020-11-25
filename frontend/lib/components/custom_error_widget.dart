import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;

  CustomErrorWidget({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            Image.asset('images/error.gif'),
            Text(message, style: Theme.of(context).textTheme.headline4)
          ],
        ),
      ),
    );
  }
}
