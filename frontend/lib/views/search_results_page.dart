import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/components/NoData.dart';
import 'package:frontend/components/custom_error_widget.dart';
import 'package:frontend/components/explore_drawer.dart';

import 'package:frontend/components/TopBarContents.dart';
import 'package:frontend/components/hotel_card.dart';

import 'package:frontend/components/responsive_widget.dart';
import 'package:frontend/controller/navigation_controller.dart';
import 'package:frontend/models/hotel.dart';

import 'home_page.dart';

class SearchResultsPage extends StatefulWidget {
  static const id = '/searchResults';

  final Map<String, dynamic> queryParamsAndType;

  const SearchResultsPage({@required this.queryParamsAndType});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  Future<List<Hotel>> getResults;
  List<Hotel> results = [];

  @override
  void initState() {
    getResults = (widget.queryParamsAndType['useAdvanceSearch'] as bool)
        ? NavigationController.getHotelsWithTagController(
            tag: widget.queryParamsAndType['q'] as String,
          )
        : NavigationController.searchHotelWithNameController(
            q: widget.queryParamsAndType['q'] as String,
            checkIn: widget.queryParamsAndType['checkIn'] as String,
            checkOut: widget.queryParamsAndType['checkOut'] as String,
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1,
                  vertical: 20),
              child: ResponsiveWidget.isSemiMediumScreen(context) ||
                      ResponsiveWidget.isSmallScreen(context)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\nShowing results for ${widget.queryParamsAndType['q'] as String}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          "${widget.queryParamsAndType['checkIn'] == null ? '' : 'Check-In date: ${widget.queryParamsAndType['checkIn'] as String}\n'}${widget.queryParamsAndType['checkOut'] == null ? '' : 'Check-Out date: ${widget.queryParamsAndType['checkOut'] as String}\n'}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1,
                          ),
                        ),
                        _sortingWidgets(),
                      ],
                    )
                  : Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              "\nShowing results for ${widget.queryParamsAndType['q'] as String}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              "${widget.queryParamsAndType['checkIn'] == null ? '' : 'Check-In date: ${widget.queryParamsAndType['checkIn'] as String}\n'}${widget.queryParamsAndType['checkOut'] == null ? '' : 'Check-Out date: ${widget.queryParamsAndType['checkOut'] as String}'}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        _sortingWidgets(),
                      ],
                    ),
            ),
            FutureBuilder<List<Hotel>>(
                future: getResults,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    // ignore: omit_local_variable_types
                    results = snapshot.data;
                    if (results.isEmpty) {
                      return NoData(message: 'No results found');
                    } else {
                      return Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.1,
                              vertical: 20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      ResponsiveWidget.isSmallScreen(context)
                                          ? 1
                                          : ResponsiveWidget.isSemiMediumScreen(
                                                  context)
                                              ? 2
                                              : ResponsiveWidget.isMediumScreen(
                                                      context)
                                                  ? 3
                                                  : 4),
                          itemBuilder: (context, index) {
                            return HotelCard(results[index]);
                          },
                          itemCount: results.length,
                        ),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return CustomErrorWidget(
                      message: 'Error in fetching search result....',
                    );
                  } else {
                    return Center(
                      child: SpinKitCircle(
                        color: Theme.of(context).accentColor,
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget _sortingWidgets() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(15, 5, 5, 5),
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
          ),
          child: Row(
            children: [
              Text(
                'Rating',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_upward_rounded),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  results.sort(
                    (a, b) => a.rating.compareTo(b.rating),
                  );
                  setState(() {});
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_downward_rounded),
                color: Theme.of(context).hintColor,
                onPressed: () {
                  results.sort(
                    (a, b) => b.rating.compareTo(a.rating),
                  );
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(15, 5, 5, 5),
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
          ),
          child: Row(
            children: [
              Text(
                'Price',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_upward_rounded),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  results.sort(
                    (a, b) =>
                        a.price.currentPrice.compareTo(b.price.currentPrice),
                  );
                  setState(() {});
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_downward_rounded),
                color: Theme.of(context).hintColor,
                onPressed: () {
                  results.sort(
                    (a, b) =>
                        b.price.currentPrice.compareTo(a.price.currentPrice),
                  );
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
