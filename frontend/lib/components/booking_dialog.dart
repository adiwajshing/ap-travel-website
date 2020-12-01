import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:frontend/components/add_button.dart';
import 'package:frontend/components/auth_dialog.dart';
import 'package:frontend/components/my_slider.dart';
import 'package:frontend/controller/booking_controller.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/models/detailed_hotel.dart';
import 'package:frontend/models/user.dart';

import '../main.dart';

class BookingDialog extends StatefulWidget {
  final DetailedHotel hotel;

  BookingDialog({Key key, this.hotel}) : super(key: key);

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  bool isLoading = false;
  int noOfGuests = 0;

  // ignore: omit_local_variable_types
  String bookingName;
  String status = 'reserved';
  bool statusBool = false;
  Map<String, dynamic> roomsData = {};

  Future<Booking> addBooking() async {
    // ignore: omit_local_variable_types
    return await BookingController.addNewBookingController(
        hotelId: widget.hotel.id.toString(),
        bookingData: {
          'status': status,
          'bookingDetails': {
            'bookingName': bookingName,
            'guests': noOfGuests,
            'room': roomsData,
            'check_In': printDate(checkInDateTime),
            'check_Out': printDate(checkOutDateTime),
          }
        });
  }

  List<String> getRoomsBookedOn(Map<String, dynamic> roomsData) {
    // ignore: omit_local_variable_types
    List<String> roomsBookedOn = [];
    roomsData.keys.forEach((roomName) {
      widget.hotel.rooms.forEach((hotelRoom) {
        if (roomName == hotelRoom.name) {
          hotelRoom.roomsBookedOn.forEach((element) {
            roomsBookedOn.add(element);
          });
        }
      });
    });

    return roomsBookedOn;
  }

  DateTime checkOutDateTime;
  DateTime checkInDateTime;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          width: 400,
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  widget.hotel.title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headline1.color,
                    fontSize: 24,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'RESERVED',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            !statusBool ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Switch(
                    value: statusBool,
                    onChanged: (bool value) {
                      if (value) {
                        status = 'booked';
                      } else {
                        status = 'reserved';
                      }
                      statusBool = value;
                      setState(() {});
                    },
                  ),
                  Expanded(
                    child: Text(
                      'BOOKED',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            statusBool ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    bottom: 8,
                  ),
                  child: Column(
                      children: widget.hotel.rooms
                          .map((room) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        room.name,
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    AddButton(
                                      width: 100,
                                      height: 30,
                                      maxValue: room.roomsAvailable,
                                      onChanged: (int v) {
                                        if (v == 0) {
                                          roomsData.remove(room.name);
                                        } else {
                                          roomsData[room.name] = v;
                                        }
                                        if (noOfGuests > getRoomsMaxValue()) {
                                          noOfGuests = getRoomsMaxValue();
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ))
                          .toList())),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Number of Guests',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.subtitle2.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '$noOfGuests / ${getRoomsMaxValue()}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        // letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
              MySlider(
                value: noOfGuests,
                maxValue: getRoomsMaxValue(),
                minValue: 0,
                onChanged: (double num) {
                  setState(() {
                    noOfGuests = num.toInt();
                  });
                },
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text(
                  'Check In Date',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  printDate(checkInDateTime),
                  style: TextStyle(fontSize: 15),
                ),
                leading: Icon(
                  Icons.login,
                  color: Colors.green,
                  size: 25,
                ),
                onTap: roomsData.isEmpty
                    ? () {
                        toast('Please select a room');
                      }
                    : () async {
                        checkInDateTime = await showDatePickerDialog(context,
                            isCheckoutDate: false,
                            roomsBookedOn: getRoomsBookedOn(roomsData));
                        setState(() {});
                        logger.d(
                            'after selection in checkIn\ncheckIn: ${printDate(checkInDateTime)}\ncheckOut: ${printDate(checkOutDateTime)}');
                      },
              ),
              ListTile(
                title: Text(
                  'Check Out Date',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  printDate(checkOutDateTime),
                  style: TextStyle(fontSize: 15),
                ),
                leading: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 25,
                ),
                onTap: roomsData.isEmpty
                    ? () {
                        toast('Please select a room');
                      }
                    : () async {
                        checkOutDateTime = await showDatePickerDialog(context,
                            isCheckoutDate: true,
                            roomsBookedOn: getRoomsBookedOn(roomsData));
                        setState(() {});
                        logger.d(
                            'after selection in checkOut\ncheckIn: ${printDate(checkInDateTime)}\ncheckOut: ${printDate(checkOutDateTime)}');
                      },
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  bottom: 8,
                ),
                child: Text(
                  'Booked Under',
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
                      return 'Please enter booking name';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  obscureText: false,
                  autofocus: false,
                  onChanged: (value) {
                    setState(() {
                      bookingName = value;
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
                    hintText: 'Name',
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
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (Provider.of<User>(context, listen: false)
                                      .isLoggedIn) {
                                    if (roomsData.isEmpty) {
                                      toast('Please select at least one room');
                                    } else if (noOfGuests == 0) {
                                      toast('Please select at least one guest');
                                    } else if (checkInDateTime == null) {
                                      toast('Please select check in date');
                                    } else if (checkOutDateTime == null) {
                                      toast('Please select check out date');
                                    } else if (bookingName == null) {
                                      toast('Please enter booking name');
                                    } else {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      try {
                                        // ignore: omit_local_variable_types
                                        // Booking booking = widget.bookingId != null
                                        //     ? await addBooking()
                                        //     : await editBooking();

                                        var booking = await addBooking();

                                        if (booking == null) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          showSimpleNotification(
                                            Text(
                                              'An error occurred while booking hotel',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            background: Colors.red,
                                          );
                                        } else {
                                          logger.d('here');
                                          showSimpleNotification(
                                            Text('Hotel booked successfully'),
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
                                            'An error occurred while booking hotel',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          background: Colors.red,
                                        );
                                        setState(() {
                                          isLoading = false;
                                        });
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Book Hotel',
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
    );
  }

  int getRoomsMaxValue() {
    if (roomsData.isEmpty) {
      return 0;
    } else {
      var sum = 0;
      for (var roomName in roomsData.keys) {
        sum += (widget.hotel.rooms
                    .firstWhere((element) => element.name == roomName)
                    .maxOccupants *
                (roomsData[roomName] as int))
            .toInt();
      }
      return sum;
    }
  }

  DateTime getInitialDate(List<String> roomsBookedOn) {
    // ignore: omit_local_variable_types
    DateTime day = DateTime.now().add(Duration(days: 1));
    while (roomsBookedOn.contains(printDate(day))) {
      day = day.add(Duration(days: 1));
    }
    return day;
  }

  Future<DateTime> showDatePickerDialog(
    BuildContext context, {
    @required bool isCheckoutDate,
    List<String> roomsBookedOn,
  }) async {
    // ignore: omit_local_variable_types
    DateTime dateTime = await showDatePicker(
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light().copyWith(
                primary: Theme.of(context).accentColor,
              ),
            ),
            child: child,
          );
        },
        context: context,
        initialDate: getInitialDate(roomsBookedOn),
        firstDate: DateTime.now().add(Duration(days: 1)),
        lastDate: DateTime(2025),
        selectableDayPredicate: (DateTime date) {
          return !roomsBookedOn
              .contains('${date.day}/${date.month}/${date.year}');
        });
    if (dateTime == null) {
      return isCheckoutDate ? checkOutDateTime : checkInDateTime;
    } else if (isCheckoutDate && checkInDateTime == null) {
      return dateTime;
    } else if (isCheckoutDate && dateTime.isBefore(checkInDateTime)) {
      dateTime = checkOutDateTime;
      showSimpleNotification(
        Text(
          'The Checkout Date should be after Check In Date.',
          style: TextStyle(color: Colors.white),
        ),
        background: Colors.deepOrange,
      );
    } else if (!isCheckoutDate && checkOutDateTime == null) {
      return dateTime;
    } else if (!isCheckoutDate && dateTime.isAfter(checkOutDateTime)) {
      dateTime = checkInDateTime;
      showSimpleNotification(
        Text(
          'The Check In Date should be before Check Out Date.',
          style: TextStyle(color: Colors.white),
        ),
        background: Colors.deepOrange,
      );
    } else if (isCheckoutDate && dateTime == checkInDateTime) {
      dateTime = checkOutDateTime;
      showSimpleNotification(
        Text(
          'The Check In Date can not be equal to Check out date.',
          style: TextStyle(color: Colors.white),
        ),
        background: Colors.deepOrange,
      );
    } else if (!isCheckoutDate && dateTime == checkOutDateTime) {
      dateTime = checkInDateTime;
      showSimpleNotification(
        Text(
          'The Check In Date can not be equal to Check out date.',
          style: TextStyle(color: Colors.white),
        ),
        background: Colors.deepOrange,
      );
    }
    return dateTime;
  }

  String printDate(DateTime dateTime) {
    if (dateTime == null) {
      return 'Add Date';
    } else {
      return '$dateTime'.split(' ').first.split('-').reversed.join('/');
    }
  }
}
