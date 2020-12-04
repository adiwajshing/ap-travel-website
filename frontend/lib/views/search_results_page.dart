import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/components/NoData.dart';
import 'package:frontend/components/custom_error_widget.dart';
import 'package:frontend/components/explore_drawer.dart';

import 'package:frontend/components/TopBarContents.dart';
import 'package:frontend/components/hotel_card.dart';
import 'package:frontend/components/multi_select.dart';

import 'package:frontend/components/responsive_widget.dart';
import 'package:frontend/controller/navigation_controller.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/utils/constants.dart';

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
  List<Hotel> fixedResults = [];
  String selectedCity;
  List allTags;
  List selectedTags = [];
  String sortType = '';
  Set selectedTagIndex = {};

  @override
  void initState() {
    getResults = (widget.queryParamsAndType['useAdvanceSearch'] as bool)
        ? NavigationController.advanceSearchController(
            q: widget.queryParamsAndType['q'] as String,
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
                        SizedBox(
                          height: 5,
                        ),
                        _filterByCities(),
                        SizedBox(
                          height: 5,
                        ),
                        _selectTags(),
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
                        // Spacer(),
                        _selectTags(),
                        _filterByCities(),
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
                    fixedResults = snapshot.data;
                    if (selectedCity != null) {
                      results = results
                          .where((element) => element.city == selectedCity)
                          .toList();
                    }
                    if (selectedTags != null && selectedTags.isNotEmpty) {
                      results = results.where((hotel) {
                        // ignore: omit_local_variable_types
                        bool containTag = false;
                        for (var tag in selectedTags) {
                          if (hotel.tags.contains(tag)) {
                            containTag = true;
                            break;
                          }
                        }
                        if (containTag) {
                          return true;
                        } else {
                          return false;
                        }
                      }).toList();
                    }
                    if (sortType.isNotEmpty) {
                      // ignore: omit_local_variable_types
                      String mainType = sortType.split(' ')[0];
                      // ignore: omit_local_variable_types
                      String resultType = sortType.split(' ')[1];
                      if (mainType == 'Price') {
                        if (resultType == 'up') {
                          results.sort(
                            (a, b) => a.price.currentPrice
                                .compareTo(b.price.currentPrice),
                          );
                        } else {
                          results.sort(
                            (a, b) => b.price.currentPrice
                                .compareTo(a.price.currentPrice),
                          );
                        }
                      } else {
                        if (resultType == 'up') {
                          results.sort(
                            (a, b) => a.rating.compareTo(b.rating),
                          );
                        } else {
                          results.sort(
                            (a, b) => b.rating.compareTo(a.rating),
                          );
                        }
                      }
                      print('type: $sortType');
                    }
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

  Widget _selectTags() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
      ),
      child: FlatButton(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 22),
        splashColor: Colors.transparent,
        onPressed: () {
          _showMultiSelect();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tags  ',
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
            ),
            Icon(Icons.tag),
          ],
        ),
      ),
    );
  }

  void _showMultiSelect() async {
    // ignore: omit_local_variable_types
    List tags = [];
    fixedResults.forEach((element) {
      tags.addAll(element.tags);
    });
    // ignore: omit_local_variable_types
    tags = Set<String>.from(tags).toList();
    // ignore: omit_local_variable_types
    List<MultiSelectDialogItem> items = [];
    // ignore: omit_local_variable_types
    for (int i = 0; i < tags.length; i++) {
      items.add(MultiSelectDialogItem(i, tags[i] as String));
    }
    final selected = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: items,
          initialSelectedLabels: selectedTags,
          initialSelectedValues: selectedTagIndex,
        );
      },
    );
    print('selected: $selected');
    setState(() {
      selectedTags =
          selected == null ? selectedTags : selected['values'] as List;
      selectedTagIndex =
          selected == null ? selectedTagIndex : selected['index'] as Set;
    });
    print(selectedTags);
  }

  Widget _filterByCities() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
      ),
      child: DropdownButton(
        hint: Text(
          'City',
          style: TextStyle(color: Colors.grey[800], fontSize: 14),
        ),
        icon: Icon(Icons.location_on),
        underline: SizedBox.shrink(),
        value: selectedCity,
        items: cities
            .map((e) => DropdownMenuItem(
                  child: Text(e),
                  value: e,
                ))
            .toList(),
        onChanged: (String value) {
          selectedCity = value;
          setState(() {});
        },
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
                  setState(() {
                    sortType = 'Rating up';
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_downward_rounded),
                color: Theme.of(context).hintColor,
                onPressed: () {
                  results.sort(
                    (a, b) => b.rating.compareTo(a.rating),
                  );
                  setState(() {
                    sortType = 'Rating down';
                  });
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
                  setState(() {
                    sortType = 'Price up';
                  });
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
                  setState(() {
                    sortType = 'Price down';
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
