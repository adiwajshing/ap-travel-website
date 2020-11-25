import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:frontend/controller/user_controller.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/utils/firebase_auth.dart';
import 'package:frontend/utils/Jwt.dart';

class GoogleButton extends StatefulWidget {
  final bool disableOnTap;

  GoogleButton({@required this.disableOnTap});

  @override
  _GoogleButtonState createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Theme.of(context).accentColor, width: 1),
        ),
        color: Colors.white,
      ),
      child: OutlineButton(
        highlightColor: Colors.blueGrey[100],
        splashColor: Colors.blueGrey[200],
        onPressed: widget.disableOnTap
            ? null
            : () async {
                setState(() {
                  _isProcessing = true;
                });
                try {
                  // ignore: omit_local_variable_types
                  Map userCredentials =
                      await FirebaseAuthService.signInWithGoogle();
                  logger.d(userCredentials);
                  // ignore: omit_local_variable_types
                  bool gotJwt = await UserController.googleSignupController(
                      idToken: userCredentials['idToken'] as String);
                  if(gotJwt){
                  Get.find<Jwt>()
                      .setToken(userCredentials['idToken'] as String);
                  Provider.of<User>(context, listen: false)
                      .updateUserInProvider(User(
                    name: userCredentials['name'] as String,
                    phone_number: userCredentials['phone_number'] as String,
                    email: userCredentials['email'] as String,
                  ));
                  Provider.of<User>(context, listen: false)
                      .setLoggedInStatus(true);
                  showSimpleNotification(
                    Text(
                      'Logged in!!!',
                      style: TextStyle(color: Colors.white),
                    ),
                    background: Colors.green,
                  );}
                  else{
                    showSimpleNotification(
                      Text(
                        'An error occurred while logging in',
                        style: TextStyle(color: Colors.white),
                      ),
                      background: Colors.red,
                    );
                  }
                } catch (e) {
                  logger.e(e);
                  showSimpleNotification(
                    Text(
                      'An error occurred while logging in',
                      style: TextStyle(color: Colors.white),
                    ),
                    background: Colors.red,
                  );
                }
                setState(() {
                  _isProcessing = false;
                });
                Navigator.pop(context);
              },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Theme.of(context).accentColor, width: 3),
        ),
        highlightElevation: 0,
        // borderSide: BorderSide(color: Colors.blueGrey, width: 3),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: _isProcessing
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).accentColor,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage('images/google_logo.png'),
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blueGrey,
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
