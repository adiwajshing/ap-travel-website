import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:frontend/components/auth_dialog.dart';
import 'package:frontend/controller/review_controller.dart';

import 'package:frontend/models/review.dart';
import 'package:frontend/models/user.dart';

import '../main.dart';

class AddReview extends StatefulWidget {
  final int hotelId;
  final Function updateHotel;

  AddReview({Key key, this.hotelId, this.updateHotel}) : super(key: key);

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String _title;
  double newRating = 1;

  // ignore: omit_local_variable_types
  String _review;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          height: 450,
          width: 400,
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    bottom: 8,
                  ),
                  child: Text(
                    'Title',
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
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    obscureText: false,
                    autofocus: false,
                    initialValue: _title ?? 'My Review',
                    onChanged: (value) {
                      setState(() {
                        _title = value;
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
                      hintText: 'Title',
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
                    'Review',
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
                        return 'Please enter your review';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    obscureText: false,
                    autofocus: false,
                    maxLines: 5,
                    onChanged: (value) {
                      setState(() {
                        _review = value;
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
                      hintText: 'Review',
                      fillColor: Colors.white,
                      errorStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                StarRating(
                  size: 25.0,
                  rating: newRating,
                  color: Colors.amber,
                  borderColor: Colors.grey,
                  starCount: 10,
                  onRatingChanged: (rating) {
                    setState(() {
                      newRating = rating;
                    });
                  },
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Container(
                          width: double.maxFinite,
                          child: FlatButton(
                            color: Colors.blueGrey[800],
                            hoverColor: Colors.blueGrey[900],
                            highlightColor: Colors.black,
                            disabledColor: Colors.blueGrey[800],
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (Provider.of<User>(context,
                                            listen: false)
                                        .isLoggedIn) {
                                      if (_formKey.currentState.validate()) {
                                        if ((_review == null ||
                                                _review.trim() == '') &&
                                            _title.trim() == '') {
                                          toast('Please fill all the fields');
                                        } else {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          try {
                                            // ignore: omit_local_variable_types
                                            NewReviews newReviews =
                                                await ReviewController
                                                    .addReviewToHotelController(
                                                        hotelId: widget.hotelId,
                                                        reviewBody: ReviewBody(
                                                            rating: newRating,
                                                            review: _review,
                                                            title: _title ??
                                                                'My Review'));
                                            if (newReviews == null) {
                                              logger.d('here lol');
                                              setState(() {
                                                isLoading = false;
                                              });
                                              showSimpleNotification(
                                                Text(
                                                  'An error occurred while adding review',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                background: Colors.red,
                                              );
                                            } else {
                                              logger.d('here');
                                              newReviews.reviews = newReviews
                                                  .reviews.reversed
                                                  .toList();
                                              widget.updateHotel(
                                                  newReviews: newReviews);
                                              showSimpleNotification(
                                                Text(
                                                    'Review added successfully'),
                                                background: Colors.green,
                                              );
                                              setState(() {
                                                isLoading = false;
                                              });
                                              Navigator.pop(context);
                                            }
                                          } catch (e) {
                                            logger.e(e);
                                            showSimpleNotification(
                                              Text(
                                                'An error occurred while adding review',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              background: Colors.red,
                                            );
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        }
                                      }
                                    } else {
                                      await showDialog(
                                        context: context,
                                        builder: (context) => AuthDialog(),
                                      );
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
                              child: isLoading
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
                                      'Add Review',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
