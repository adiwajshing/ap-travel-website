import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/controller/user_controller.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/utils/Jwt.dart';

import '../main.dart';
import 'google_sign_in_button.dart';

class LogInSide extends StatefulWidget {
  final Function toggleDialog;

  const LogInSide({Key key, this.toggleDialog}) : super(key: key);

  @override
  _LogInSideState createState() => _LogInSideState();
}

class _LogInSideState extends State<LogInSide> {
  final _formKey = GlobalKey<FormState>();
  String _email;
  String _password;
  bool isLogIn = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: 400,
          color: Theme.of(context).primaryColor,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'STAYSIA',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.headline1.color,
                      fontSize: 24,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    bottom: 8,
                  ),
                  child: Text(
                    'Email address',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.subtitle2.color,
                      fontSize: 18,
                      // fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      // letterSpacing: 3,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20,
                  ),
                  child: TextFormField(
                    validator: (String value) {
                      if (value.isEmpty || value.trim() == '') {
                        return 'Please Enter Your Email';
                      } else if (!(value.contains('@') &&
                          value.contains('.'))) {
                        return 'Invalid Email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofocus: false,
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.blueGrey[800],
                          width: 3,
                        ),
                      ),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.blueGrey[300],
                      ),
                      hintText: 'Email',
                      fillColor: Colors.white,
                      errorStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    bottom: 8,
                  ),
                  child: Text(
                    'Password',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.subtitle2.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // letterSpacing: 3,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20,
                  ),
                  child: TextFormField(
                    validator: (String value) {
                      if (value.isEmpty || value.trim() == '') {
                        return 'Please Enter Your Password';
                      } else if (value.length < 6) {
                        return 'Length should be greater than 5';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    autofocus: false,
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.blueGrey[800],
                          width: 3,
                        ),
                      ),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.blueGrey[300],
                      ),
                      hintText: 'Password',
                      fillColor: Colors.white,
                      errorStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          width: 200,
                          child: FlatButton(
                            color: Colors.blueGrey[800],
                            hoverColor: Colors.blueGrey[900],
                            highlightColor: Colors.black,
                            disabledColor: Colors.blueGrey[800],
                            onPressed: isLogIn
                                ? null
                                : () async {
                                    if (_formKey.currentState.validate()) {
                                      setState(() {
                                        isLogIn = true;
                                      });
                                      try {
                                        Get.find<Jwt>().setToken(
                                            await UserController
                                                .loginController(
                                          email: _email?.trim(),
                                          password: _password,
                                        ));
                                        if (Get.find<Jwt>().token.value == '') {
                                          logger.d('here lol');
                                          setState(() {
                                            isLogIn = false;
                                          });
                                          showSimpleNotification(
                                            Text(
                                              'An error occurred while logging in',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            background: Colors.red,
                                          );
                                        } else {
                                          final pref = await SharedPreferences
                                              .getInstance();
                                          await pref.setString('jwt',
                                              Get.find<Jwt>().token.value);
                                          logger.d(
                                              'here ${Get.find<Jwt>().token.value}');
                                          // ignore: omit_local_variable_types
                                          User currentUser =
                                              await UserController
                                                  .getProfileController();

                                          if (currentUser != null) {
                                            Provider.of<User>(context,
                                                    listen: false)
                                                .updateUserInProvider(
                                                    currentUser);
                                            Provider.of<User>(context,
                                                    listen: false)
                                                .setLoggedInStatus(true);
                                            showSimpleNotification(
                                              Text('Logged in successfully'),
                                              background: Colors.green,
                                            );
                                          } else {
                                            showSimpleNotification(
                                              Text(
                                                'An error occurred while logging in',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              background: Colors.red,
                                            );
                                          }
                                          setState(() {
                                            isLogIn = false;
                                          });
                                          logger.d(Provider.of<User>(context,
                                              listen: false));
                                          Navigator.pop(context);
                                        }
                                      } catch (e) {
                                        logger.e(e);
                                        showSimpleNotification(
                                          Text(
                                            'An error occurred while logging in',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          background: Colors.red,
                                        );
                                        setState(() {
                                          isLogIn = false;
                                        });
                                      }
                                    }
                                  },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 15.0,
                                bottom: 15.0,
                              ),
                              child: isLogIn
                                  ? SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'Log in',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 40.0,
                    right: 40.0,
                  ),
                  child: Container(
                    height: 1,
                    width: double.maxFinite,
                    color: Colors.blueGrey[200],
                  ),
                ),
                SizedBox(height: 30),
                Center(child: GoogleButton(disableOnTap: isLogIn,)),
                SizedBox(height: 30),
                Center(
                    child: FlatButton(
                  padding: EdgeInsets.all(20),
                  color: Theme.of(context).accentColor,
                  hoverColor: Theme.of(context).hintColor,
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                  onPressed:isLogIn
                      ? null
                      : () {
                    widget.toggleDialog();
                  },
                  child: Text(
                    'SignUp Instead',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'By proceeding, you agree to our Terms of Use and confirm you have read our Privacy Policy.',
                    maxLines: 2,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.subtitle2.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      // letterSpacing: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
