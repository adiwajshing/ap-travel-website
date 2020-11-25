import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  final String message;

  NoData({@required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            Image.asset('images/404.gif'),
            Text(message, style: Theme.of(context).textTheme.headline4)
          ],
        ),
      ),
    );
  }
}
