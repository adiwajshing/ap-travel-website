import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/components/TopBarContents.dart';
import 'package:frontend/components/add_review.dart';
import 'package:frontend/components/booking_dialog.dart';
import 'package:frontend/components/custom_error_widget.dart';
import 'package:frontend/components/explore_drawer.dart';
import 'package:frontend/components/hotel_card.dart';
import 'package:frontend/components/responsive_widget.dart';
import 'package:frontend/controller/navigation_controller.dart';
import 'package:frontend/models/detailed_hotel.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/models/review.dart';

import 'home_page.dart';

class HotelDetailsPage extends StatefulWidget {
  static const id = 'hotel_details_page';
  final int hotelId;

  const HotelDetailsPage({this.hotelId});

  @override
  _HotelDetailsPageState createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends State<HotelDetailsPage> {
  DetailedHotel hotel;

  void updateHotel({@required NewReviews newReviews}) {
    setState(() {
      hotel.rating = newReviews.rating;
      hotel.review = newReviews.reviews;
    });
  }

  Future<DetailedHotel> getHotel;
  Future<List<Hotel>> getRecommendations;
  Future<List<Hotel>> getNetwork;

  @override
  void initState() {
    // TODO: implement initState
    getHotel = NavigationController.getHotelByIdController(
      hotelId: widget.hotelId.toString(),
    );
    getRecommendations =
        NavigationController.getHotelRecommendationByIdController(
      hotelId: widget.hotelId.toString(),
    );
    getNetwork =NavigationController.getHotelNetworkByIdController(
      hotelId: widget.hotelId.toString(),
    );
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
        body: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveWidget.isSmallScreen(context)
                  ? 20
                  : MediaQuery.of(context).size.width * 0.15,
              vertical: 20),
          children: [
            FutureBuilder<DetailedHotel>(
              future: getHotel,
              builder: (context, snapshot) {
                hotel = snapshot.data;
                if (snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (ResponsiveWidget.isSemiMediumScreen(context) ||
                              ResponsiveWidget.isSmallScreen(context))
                          ? Column(
                              children: [
                                Container(
                                  width: 350,
                                  height: 300,
                                  margin: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            hotel.mainImage,
                                          ))),
                                ),
                                SizedBox(height: 30),
                                _getHotelDetails()
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  width: 400,
                                  height: 350,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                            hotel.mainImage,
                                          ))),
                                ),
                                SizedBox(width: 30),
                                Expanded(child: _getHotelDetails())
                              ],
                            ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveWidget.isSmallScreen(context)
                                ? MediaQuery.of(context).size.width * 0.14
                                : MediaQuery.of(context).size.width * 0.24),
                        child: GestureDetector(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: Theme.of(context).primaryColor,
                                ),
                                Text(
                                  '  Book Hotel',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 20,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 3,
                                  ),
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) => BookingDialog(
                                      hotel: hotel,
                                    ));
                          },
                        ),
                      ),
                      Text(
                        'Rooms',
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        children: hotel.rooms
                            .map((e) => Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 5,
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 150,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Price : ${hotel.price.currency} ${e.price}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      Text(
                                        'Max Occupants : ${e.maxOccupants}',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Rooms Available : ${e.roomsAvailable}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Main Amenities',
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: hotel.featureBullets.mainAmenities
                            .map(
                              (e) => Chip(
                                label: Text(
                                  e,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'What is around',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: hotel.featureBullets.whatIsAround
                            .map(
                              (e) => Chip(
                                label: Text(
                                  e,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 15),
                      Row(children: [
                        Text(
                          'Reviews',
                          style: TextStyle(
                            fontSize: 25,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AddReview(
                                    hotelId: hotel.id,
                                    updateHotel: updateHotel));
                          },
                        )
                      ]),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...hotel.review
                              .map(
                                (e) => Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 5,
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: 250,
                                  child: Stack(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          ListTile(
                                            title: Text(
                                              e.title,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline1
                                                    .color,
                                                fontSize: 20,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 3,
                                              ),
                                            ),
                                            subtitle: Text(
                                              '${e.review}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '~${e.name}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.end,
                                              ),
                                            ],
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Row(
                                          children: [
                                            Text(
                                              '${e.rating}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color:
                                                  Theme.of(context).accentColor,
                                              size: 25,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList()
                              .reversed,
                        ],
                      ),
                      SizedBox(height: 15),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return CustomErrorWidget(
                    message: 'Error in fetching Reviews....',
                  );
                } else {
                  return Center(
                      child: SpinKitCircle(
                    color: Theme.of(context).accentColor,
                  ));
                }
              },
            ),
            _recommendedHotels(),
            SizedBox(height: 20,),
            _networkHotels()
          ],
        ),
      ),
    );
  }

  Widget _recommendedHotels() {
    return FutureBuilder<List<Hotel>>(
      future: getRecommendations,
      builder: (context, snapshot) {
        final hotels = snapshot.data;
        if (snapshot.hasData) {
          return SizedBox(
            height: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended',
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return HotelCard(hotels[index]);
                    },
                    itemCount: hotels.length,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return CustomErrorWidget(
            message: 'Failed to fetch recommendations....',
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
  Widget _networkHotels() {
    return FutureBuilder<List<Hotel>>(
      future: getNetwork,
      builder: (context, snapshot) {
        final hotels = snapshot.data;
        if (snapshot.hasData && hotels.isNotEmpty) {
          return SizedBox(
            height: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'People who stayed here also visited',
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return HotelCard(hotels[index]);
                    },
                    itemCount: hotels.length,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return CustomErrorWidget(
            message: 'Failed to fetch network....',
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
  Widget _getHotelDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        ListTile(
          title: Text(
            hotel.title,
            style: TextStyle(
              color: Theme.of(context).textTheme.headline1.color,
              fontSize: 25,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          subtitle: Text(
            hotel.description,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Montserrat',
            ),
          ),
          isThreeLine: true,
          leading: Icon(
            Icons.location_city,
            color: Theme.of(context).accentColor,
            size: 25,
          ),
        ),
        SizedBox(height: 10),
        ListTile(
          title: Text(
            'Address',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            hotel.address,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Montserrat',
            ),
          ),
          leading: Icon(
            Icons.location_on_rounded,
            color: Theme.of(context).accentColor,
            size: 25,
          ),
          isThreeLine: true,
        ),
        ListTile(
          title: Text(
            'Check In Time',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            hotel.checkIn,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Montserrat',
            ),
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
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            hotel.checkOut,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Montserrat',
            ),
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
          subtitle: hotel.price.discounted
              ? Row(
                  children: [
                    Text(
                      '${hotel.price.currency} ${hotel.price.beforePrice}',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '${hotel.price.currency} ${hotel.price.currentPrice}',
                    ),
                  ],
                )
              : Text(
                  '${hotel.price.currency} ${hotel.price.currentPrice}',
                ),
          leading: Icon(
            Icons.money,
            color: Colors.green,
            size: 25,
          ),
        ),
        ListTile(
          title: Text(
            'Rating : ${hotel.rating}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          leading: Icon(
            Icons.star,
            color: Theme.of(context).accentColor,
            size: 25,
          ),
        ),
      ],
    );
  }
}
