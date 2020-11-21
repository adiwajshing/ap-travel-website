import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:frontend/views/error_page.dart';
import 'package:frontend/views/home_page.dart';
import 'package:frontend/views/hotel_details_page.dart';
import 'package:frontend/views/my_booking_page.dart';
import 'package:frontend/views/search_results_page.dart';
import 'package:frontend/views/splash_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
// Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      // case ResourcesPage.id:
      //   return PageTransition(
      //     child: ResourcesPage(
      //       course: args,
      //     ),
      //     type: PageTransitionType.bottomToTop,
      //   );
      case HotelDetailsPage.id:
        return PageTransition(
            child: HotelDetailsPage(hotelId: args as int),
            type: PageTransitionType.leftToRightWithFade);
      case SearchResultsPage.id:
        return PageTransition(
            child: SearchResultsPage(queryParamsAndType: args as Map<String, dynamic>),
            type: PageTransitionType.leftToRightWithFade);
      case MyBookingPage.id:
        return PageTransition(
            child: MyBookingPage(),
            type: PageTransitionType.leftToRightWithFade);
      case HomePage.id:
        return PageTransition(
            child: HomePage(), type: PageTransitionType.leftToRightWithFade);
      case SplashPage.id:
        return PageTransition(
            child: SplashPage(), type: PageTransitionType.leftToRightWithFade);
      default:
        return PageTransition(
            child: ErrorPage(), type: PageTransitionType.leftToRightWithFade);
    }
  }
}
