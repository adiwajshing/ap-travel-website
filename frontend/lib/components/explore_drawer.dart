import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/components/edit_profile.dart';
import 'package:frontend/controller/user_controller.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/utils/Jwt.dart';
import 'package:frontend/views/home_page.dart';
import 'package:frontend/views/my_booking_page.dart';

import 'auth_dialog.dart';

class ExploreDrawer extends StatefulWidget {
  const ExploreDrawer({
    Key key,
  }) : super(key: key);

  @override
  _ExploreDrawerState createState() => _ExploreDrawerState();
}

class _ExploreDrawerState extends State<ExploreDrawer> {
  final List<bool> _isHovering = [false, false, false, false, false];

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).bottomAppBarColor,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'STAYSIA',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 3,
                ),
              ),
              // Column(
              //   children: [
              //     InkWell(
              //       onHover: (value) {
              //         setState(() {
              //           value ? _isHovering[0] = true : _isHovering[0] = false;
              //         });
              //       },
              //       onTap: () {},
              //       child: Column(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           Text(
              //             'Discover',
              //             style: TextStyle(
              //               color: _isHovering[0]
              //                   ? Theme.of(context).hintColor
              //                   : Theme.of(context).accentColor,
              //             ),
              //           ),
              //           SizedBox(height: 5),
              //           Visibility(
              //             maintainAnimation: true,
              //             maintainState: true,
              //             maintainSize: true,
              //             visible: _isHovering[0],
              //             child: Container(
              //               height: 2,
              //               width: 20,
              //               color: Theme.of(context).accentColor,
              //             ),
              //           )
              //         ],
              //       ),
              //     ),
              //     SizedBox(
              //       width: 50,
              //     ),
              //     InkWell(
              //       onHover: (value) {
              //         setState(() {
              //           value ? _isHovering[1] = true : _isHovering[1] = false;
              //         });
              //       },
              //       onTap: () {},
              //       child: Column(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           Text(
              //             'Contact Us',
              //             style: TextStyle(
              //               color: _isHovering[1]
              //                   ? Theme.of(context).hintColor
              //                   : Theme.of(context).accentColor,
              //             ),
              //           ),
              //           SizedBox(height: 5),
              //           Visibility(
              //             maintainAnimation: true,
              //             maintainState: true,
              //             maintainSize: true,
              //             visible: _isHovering[1],
              //             child: Container(
              //               height: 2,
              //               width: 20,
              //               color: Theme.of(context).hintColor,
              //             ),
              //           )
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onHover: (value) {
                  setState(() {
                    value ? _isHovering[2] = true : _isHovering[2] = false;
                  });
                },
                onTap: !Provider.of<User>(context).isLoggedIn
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) => AuthDialog(),
                        );
                      }
                    : null,
                child: !Provider.of<User>(context).isLoggedIn
                    ? Text(
                        'Sign in',
                        style: TextStyle(
                          color: _isHovering[2]
                              ? Theme.of(context).hintColor
                              : Theme.of(context).accentColor,
                        ),
                      )
                    : Column(
                        children: [
                          Chip(
                            padding: EdgeInsets.only(
                              top: 8.0,
                              bottom: 8.0,
                            ),
                            backgroundColor: Theme.of(context).accentColor,
                            label: Row(
                              children: [
                                CircleAvatar(
                                    radius: 15,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: Icon(
                                      Icons.account_circle,
                                      size: 30,
                                      color: Theme.of(context).accentColor,
                                    )),
                                SizedBox(width: 5),
                                Text(
                                  Provider.of<User>(context).name,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          InkWell(
                              onHover: (value) {
                                setState(() {
                                  value
                                      ? _isHovering[4] = true
                                      : _isHovering[4] = false;
                                });
                              },
                              child: Provider.of<User>(context).isLoggedIn
                                  ? FlatButton(
                                      color: Theme.of(context).accentColor,
                                      hoverColor: Theme.of(context).hintColor,
                                      highlightColor:
                                          Theme.of(context).hintColor,
                                      shape: StadiumBorder(),
                                      onPressed: Provider.of<User>(context)
                                              .isLoggedIn
                                          ? () {
                                              Navigator.pushNamed(
                                                  context, MyBookingPage.id);
                                            }
                                          : null,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                        ),
                                        child: Text(
                                          'My Bookings',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox()),
                          SizedBox(height: 10),
                          InkWell(
                              onHover: (value) {
                                setState(() {
                                  value
                                      ? _isHovering[3] = true
                                      : _isHovering[3] = false;
                                });
                              },
                              child: Provider.of<User>(context).isLoggedIn
                                  ? FlatButton(
                                      color: Theme.of(context).accentColor,
                                      hoverColor: Theme.of(context).hintColor,
                                      highlightColor:
                                          Theme.of(context).hintColor,
                                      shape: StadiumBorder(),
                                      onPressed:
                                          Provider.of<User>(context).isLoggedIn
                                              ? () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        EditProfile(),
                                                  );
                                                }
                                              : null,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                        ),
                                        child: Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox()),
                          SizedBox(height: 10),
                          FlatButton(
                            color: Theme.of(context).accentColor,
                            hoverColor: Theme.of(context).hintColor,
                            highlightColor: Theme.of(context).hintColor,
                            onPressed: _isProcessing
                                ? null
                                : () async {
                                    setState(() {
                                      _isProcessing = true;
                                    });
                                    // ignore: omit_local_variable_types
                                    bool result =
                                        await UserController.logoutController();
                                    if (result) {
                                      Provider.of<User>(context, listen: false)
                                          .setLoggedInStatus(false);
                                      // ignore: omit_local_variable_types
                                      SharedPreferences pref =
                                          await SharedPreferences.getInstance();
                                      await pref.remove('jwt');
                                      Get.find<Jwt>().setToken('');
                                      await Navigator.pushNamedAndRemoveUntil(context, HomePage.id, (route) => false);
                                      showSimpleNotification(
                                        Text(
                                          'Successfully Logged out!',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        background: Colors.green,
                                      );
                                    } else {
                                      showSimpleNotification(
                                        Text(
                                          'An error occurred while logging out',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        background: Colors.red,
                                      );
                                    }
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                  },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: 8.0,
                                bottom: 8.0,
                              ),
                              child: _isProcessing
                                  ? SpinKitCircle(
          color: Theme.of(context).accentColor,
        )
                                  : Text(
                                      'Sign out',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          )
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
