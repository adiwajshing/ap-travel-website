import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:frontend/components/custom_text_form_field.dart';
import 'package:frontend/controller/navigation_controller.dart';
import 'package:frontend/models/hotel_overview.dart';
import 'package:frontend/views/hotel_details_page.dart';
import 'package:frontend/views/search_results_page.dart';

import '../main.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  DateTime checkInDateTime;
  DateTime checkOutDateTime;
  String searchText;
  List<HotelOverview> fuzzySearchResults = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
          height: 75,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextFormField(
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (value) async {
                          await Navigator.pushNamed(
                              context, SearchResultsPage.id,
                              arguments: {
                                'q': value,
                                'checkIn': checkInDateTime == null
                                    ? null
                                    : printDate(checkInDateTime),
                                'checkOut': checkOutDateTime == null
                                    ? null
                                    : printDate(checkOutDateTime),
                                'useAdvanceSearch': false,
                              });
                        },
                        labelText: 'Search',
                        overrideLabel: true,
                        onChanged: (s) async {
                          searchText = s;
                          logger.d(s);
                          if (s != null || s.trim() != '' || s.isNotEmpty) {
                            fuzzySearchResults = (await NavigationController
                                    .fuzzySearchController(
                                  q: s,
                                )) ??
                                [];
                          } else {
                            fuzzySearchResults = [];
                          }
                          setState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('Check In'),
                        subtitle: Text(printDate(checkInDateTime)),
                        onTap: () async {
                          checkInDateTime = await showDatePickerDialog(context);
                          setState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('Check Out'),
                        subtitle: Text(printDate(checkOutDateTime)),
                        onTap: () async {
                          checkOutDateTime = await showDatePickerDialog(
                            context,
                            isCheckoutDate: true,
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                child: IconButton(
                  tooltip: 'Search',
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    if (searchText == null || searchText.trim().isEmpty) {
                      toast('Please enter some text');
                    } else {
                      await Navigator.pushNamed(context, SearchResultsPage.id,
                          arguments: {
                            'q': searchText,
                            'checkIn': checkInDateTime == null
                                ? null
                                : printDate(checkInDateTime),
                            'checkOut': checkOutDateTime == null
                                ? null
                                : printDate(checkOutDateTime),
                            'useAdvanceSearch': false
                          });
                    }
                  },
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              CircleAvatar(
                backgroundColor: Theme.of(context).hintColor,
                child: IconButton(
                  tooltip: 'Advance search through tag',
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    if (searchText == null || searchText.trim().isEmpty) {
                      toast('Please enter some text');
                    } else {
                      await Navigator.pushNamed(context, SearchResultsPage.id,
                          arguments: {
                            'q': searchText,
                            'checkIn': checkInDateTime == null
                                ? null
                                : printDate(checkInDateTime),
                            'checkOut': checkOutDateTime == null
                                ? null
                                : printDate(checkOutDateTime),
                            'useAdvanceSearch': true
                          });
                    }
                  },
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (fuzzySearchResults.isEmpty)
          SizedBox.shrink()
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(3),
            child: Wrap(
              spacing: 13,
              direction: Axis.vertical,
              children: fuzzySearchResults
                  .map((e) => GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          HotelDetailsPage.id,
                          arguments: e.id,
                        );
                      },
                      child: Row(
                        children: [
                          Text(e.starRating.toString()),
                          Icon(
                            Icons.star,
                            color: Colors.yellow[700],
                          ),
                          SizedBox(width: 10),
                          Text(e.title),
                          SizedBox(width: 10),
                        ],
                      )))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Future<DateTime> showDatePickerDialog(
    BuildContext context, {
    bool isCheckoutDate = false,
  }) async {
    var dateTime = await showDatePicker(
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
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime(2025),
    );
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
    } else if(isCheckoutDate && dateTime==checkInDateTime) {
      dateTime = checkOutDateTime;
      showSimpleNotification(
        Text(
          'The Check In Date can not be equal to Check out date.',
          style: TextStyle(color: Colors.white),
        ),
        background: Colors.deepOrange,
      );
    }else if(!isCheckoutDate && dateTime==checkOutDateTime) {
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
