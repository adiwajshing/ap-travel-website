import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:frontend/controller/booking_controller.dart';
import 'package:frontend/models/booking.dart';
import 'dart:js' as js;

import '../main.dart';

class BookingCard extends StatefulWidget {
  final Booking booking;
  final Function(String) deleteCallback;
  final Function(String) editCallback;

  BookingCard({@required this.booking, this.deleteCallback, this.editCallback});

  @override
  _BookingCardState createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
        color: Colors.white,
      ),
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(10),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.booking.title,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    widget.booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.booking.status.toUpperCase() == 'BOOKED'
                          ? Colors.green
                          : Colors.orangeAccent,
                    ),
                  ),
                  Text(
                    '  on ${widget.booking.timestamp}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 15),
              ListTile(
                title: Text(
                  'Booked Under',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  widget.booking.bookingDetails.bookingName,
                  style: TextStyle(fontSize: 15),
                ),
                leading: Icon(
                  Icons.person,
                  color: Theme.of(context).accentColor,
                  size: 25,
                ),
              ),
              ListTile(
                title: Text(
                  'Number of Guests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  widget.booking.bookingDetails.guests.toString(),
                  style: TextStyle(fontSize: 15),
                ),
                leading: Icon(
                  Icons.group,
                  color: Theme.of(context).accentColor,
                  size: 25,
                ),
              ),
              ListTile(
                title: Text(
                  'Check In Time',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  widget.booking.bookingDetails.checkIn,
                  style: TextStyle(fontSize: 15),
                ),
                leading: Icon(
                  Icons.login,
                  color: Colors.green,
                  size: 25,
                ),
              ),
              ListTile(
                title: Text(
                  'Check Out Time',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  widget.booking.bookingDetails.checkOut,
                  style: TextStyle(fontSize: 15),
                ),
                leading: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 25,
                ),
              ),
              ListTile(
                title: Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text('Rs ${widget.booking.price}'),
                leading: Icon(
                  Icons.money,
                  color: Colors.green,
                  size: 25,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: ShapeDecoration(
                color: Theme.of(context).accentColor,
                shape: StadiumBorder(),
              ),
              child: Row(
                children: [
                  widget.booking.status == 'booked'
                      ? IconButton(
                          icon: Icon(
                            Icons.print,
                            color: Colors.white,
                          ),
                          tooltip: 'Print Booking',
                          onPressed: () async {
                            try {
                              setState(() {
                                isLoading = true;
                              });
                              // ignore: omit_local_variable_types
                              String pdfUrl = await BookingController
                                  .printBookingPdfController(
                                      bookingId: widget.booking.bookingId);
                              if (pdfUrl != null) {
                                setState(() {
                                  isLoading = false;
                                });
                                showSimpleNotification(
                                  Text(
                                    'Successfully printed booking!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  background: Colors.green,
                                );
                                js.context.callMethod('open', [pdfUrl]);
                              } else {
                                showSimpleNotification(
                                  Text(
                                    'An error occurred while printing booking.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  background: Colors.red,
                                );
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            } catch (e) {
                              logger.e(e);
                              showSimpleNotification(
                                Text(
                                  'An error occurred while printing booking.',
                                  style: TextStyle(color: Colors.white),
                                ),
                                background: Colors.red,
                              );
                              setState(() {
                                isLoading = false;
                              });
                            }
                          })
                      : IconButton(
                          icon: Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                          tooltip: 'Confirm Booking',
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: Container(
                                      width: 400,
                                      height: 130,
                                      child: Column(
                                        children: [
                                          Text(
                                            'Confirm booking?',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline1
                                                  .color,
                                              fontSize: 24,
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 3,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                width: 200,
                                                child: FlatButton(
                                                  color: Colors.blueGrey[800],
                                                  hoverColor:
                                                      Colors.blueGrey[900],
                                                  highlightColor: Colors.black,
                                                  disabledColor:
                                                      Colors.blueGrey[800],
                                                  onPressed: isLoading
                                                      ? null
                                                      : () async {
                                                          try {
                                                            setState(() {
                                                              isLoading = true;
                                                            });
                                                            // ignore: omit_local_variable_types
                                                            Booking booked = await BookingController
                                                                .editBookingController(
                                                                    bookingId: widget
                                                                        .booking
                                                                        .bookingId);
                                                            if (booked !=
                                                                null) {
                                                              widget.editCallback(
                                                                  widget.booking
                                                                      .bookingId);
                                                              setState(() {
                                                                isLoading =
                                                                    false;
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                              showSimpleNotification(
                                                                Text(
                                                                  'Successfully confirmed booking!',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                background:
                                                                    Colors
                                                                        .green,
                                                              );
                                                            } else {
                                                              showSimpleNotification(
                                                                Text(
                                                                  'An error occurred while confirming booking.',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                                background:
                                                                    Colors.red,
                                                              );
                                                              setState(() {
                                                                isLoading =
                                                                    false;
                                                              });
                                                            }
                                                          } catch (e) {
                                                            logger.e(e);
                                                            showSimpleNotification(
                                                              Text(
                                                                'An error occurred while confirming booking.',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              background:
                                                                  Colors.red,
                                                            );
                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                          }
                                                        },
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
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
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                      Color>(
                                                                Colors.white,
                                                              ),
                                                            ),
                                                          )
                                                        : Text(
                                                            'Yes',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                width: 200,
                                                child: FlatButton(
                                                  color: Colors.blueGrey[800],
                                                  hoverColor:
                                                      Colors.blueGrey[900],
                                                  highlightColor: Colors.black,
                                                  disabledColor:
                                                      Colors.blueGrey[800],
                                                  onPressed: isLoading
                                                      ? null
                                                      : () async {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
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
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                      Color>(
                                                                Colors.white,
                                                              ),
                                                            ),
                                                          )
                                                        : Text(
                                                            'No',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                        ),
                  SizedBox(
                    width: 10,
                  ),
                  widget.booking.status == 'booked'
                      ? IconButton(
                          icon: Icon(
                            Icons.email_outlined,
                            color: Colors.white,
                          ),
                          tooltip: 'Send Confirmation',
                          onPressed: () async {
                            try {
                              setState(() {
                                isLoading = true;
                              });
                              // ignore: omit_local_variable_types
                              bool mailSent = await BookingController
                                  .sendBookingConfirmationController(
                                      bookingId: widget.booking.bookingId);
                              if (mailSent) {
                                setState(() {
                                  isLoading = false;
                                });
                                showSimpleNotification(
                                  Text(
                                    'Successfully sent confirmation mail!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  background: Colors.green,
                                );
                              } else {
                                showSimpleNotification(
                                  Text(
                                    'An error occurred while sending mail.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  background: Colors.red,
                                );
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            } catch (e) {
                              logger.e(e);
                              showSimpleNotification(
                                Text(
                                  'An error occurred while sending mail.',
                                  style: TextStyle(color: Colors.white),
                                ),
                                background: Colors.red,
                              );
                              setState(() {
                                isLoading = false;
                              });
                            }
                          })
                      : SizedBox.shrink(),
                  widget.booking.status == 'booked'
                      ? SizedBox(
                          width: 10,
                        )
                      : SizedBox.shrink(),
                  IconButton(
                    tooltip: 'Delete booking',
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Container(
                                width: 400,
                                height: 130,
                                child: Column(
                                  children: [
                                    Text(
                                      'Are you sure?',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline1
                                            .color,
                                        fontSize: 24,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20.0),
                                          width: 200,
                                          child: FlatButton(
                                            color: Colors.blueGrey[800],
                                            hoverColor: Colors.blueGrey[900],
                                            highlightColor: Colors.black,
                                            disabledColor: Colors.blueGrey[800],
                                            onPressed: isLoading
                                                ? null
                                                : () async {
                                                    try {
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      // ignore: omit_local_variable_types
                                                      bool deleted =
                                                          await BookingController
                                                              .deleteBookingController(
                                                                  bookingId: widget
                                                                      .booking
                                                                      .bookingId);
                                                      if (deleted) {
                                                        widget.deleteCallback(
                                                            widget.booking
                                                                .bookingId);
                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                        Navigator.pop(context);
                                                        showSimpleNotification(
                                                          Text(
                                                            'Successfully deleted booking!',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          background:
                                                              Colors.green,
                                                        );
                                                      } else {
                                                        showSimpleNotification(
                                                          Text(
                                                            'An error occurred while deleting booking.',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          background:
                                                              Colors.red,
                                                        );
                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                      }
                                                    } catch (e) {
                                                      logger.e(e);
                                                      showSimpleNotification(
                                                        Text(
                                                          'An error occurred while deleting booking.',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        background: Colors.red,
                                                      );
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    }
                                                  },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
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
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(
                                                          Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(20.0),
                                          width: 200,
                                          child: FlatButton(
                                            color: Colors.blueGrey[800],
                                            hoverColor: Colors.blueGrey[900],
                                            highlightColor: Colors.black,
                                            disabledColor: Colors.blueGrey[800],
                                            onPressed: isLoading
                                                ? null
                                                : () async {
                                                    Navigator.pop(context);
                                                  },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
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
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(
                                                          Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      'No',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                  ),
                ],
              ),
            ),
          ),
          isLoading
              ? Center(
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    child: SpinKitCircle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }
}
