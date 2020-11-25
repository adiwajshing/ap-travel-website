import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/components/NoData.dart';
import 'package:frontend/components/TopBarContents.dart';
import 'package:frontend/components/booking_card.dart';
import 'package:frontend/components/custom_error_widget.dart';
import 'package:frontend/components/explore_drawer.dart';
import 'package:frontend/components/responsive_widget.dart';
import 'package:frontend/controller/booking_controller.dart';
import 'package:frontend/models/booking.dart';
import 'package:frontend/views/home_page.dart';

class MyBookingPage extends StatefulWidget {
  static const id = '/booking';

  MyBookingPage({Key key}) : super(key: key);

  @override
  _MyBookingPageState createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  Future<List<Booking>> myBookings;

  List<Booking> bookings;

  void editBooking(String bookingId) {
    var newBookings = <Booking>[];
    for (var booking in bookings) {
      if (booking.bookingId == bookingId) {
        booking.status = 'booked';
        newBookings.add(booking);
      } else {
        newBookings.add(booking);
      }
    }
    setState(() {
      bookings = newBookings;
    });
  }

  void deleteBooking(String bookingId) {
    var newBookings = <Booking>[];
    for (var booking in bookings) {
      if (booking.bookingId != bookingId) {
        newBookings.add(booking);
      }
    }
    setState(() {
      bookings = newBookings;
    });
  }

  @override
  void initState() {
    myBookings = BookingController.getBookingsController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: ResponsiveWidget.isLargeScreen(context) ||
                ResponsiveWidget.isMediumScreen(context)
            ? PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 1000),
                child: TopBarContents(),
              )
            : AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                automaticallyImplyLeading: true,
                elevation: 0,
                title: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, HomePage.id, (route) => false);
                      },
                      child: Text(
                        'STAYSIA',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        drawer: ExploreDrawer(),
        body: bookings != null && bookings.isEmpty
            ? NoData(message: "You don't have any bookings")
            : FutureBuilder<List<Booking>>(
                future: myBookings,
                builder: (context, snapshot) {
                  bookings ??= snapshot.data;
                  if (snapshot.hasData) {
                    if (snapshot.data.isEmpty || bookings == null) {
                      return NoData(message: "You don't have any bookings");
                    } else {
                      return SingleChildScrollView(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: bookings
                              .map((e) => BookingCard(
                                    booking: e,
                                    deleteCallback: deleteBooking,
                                    editCallback: editBooking,
                                  ))
                              .toList(),
                        ),
                      );
                    }
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: SpinKitCircle(
                        color: Theme.of(context).accentColor,
                      ),
                    );
                  } else {
                    return CustomErrorWidget(
                      message: 'Failed to fetch bookings....',
                    );
                  }
                }),
      ),
    );
  }
}
