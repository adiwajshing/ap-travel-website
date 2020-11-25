import 'package:flutter/material.dart';
import 'package:frontend/components/login_side.dart';
import 'package:frontend/components/signup_side.dart';

class AuthDialog extends StatefulWidget {
  @override
  _AuthDialogState createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  bool isLogIn = true;

  void toggleDialog() {
    setState(() {
      isLogIn = !isLogIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: AnimatedSwitcher(
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: isLogIn
            ? LogInSide(
                key: UniqueKey(),
                toggleDialog: toggleDialog,
              )
            : SignUpSide(
                key: UniqueKey(),
                toggleDialog: toggleDialog,
              ),
        duration: Duration(milliseconds: 500),
      ),
    );
  }
}
