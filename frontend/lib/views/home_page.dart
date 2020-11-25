import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/components/TopBarContents.dart';
import 'package:frontend/components/bottom_bar.dart';
import 'package:frontend/components/city_carousel.dart';
import 'package:frontend/components/custom_error_widget.dart';
import 'package:frontend/components/city_heading.dart';
import 'package:frontend/components/explore_drawer.dart';
import 'package:frontend/components/responsive_widget.dart';
import 'package:frontend/components/search_bar.dart';
import 'package:frontend/components/tag_carousel.dart';
import 'package:frontend/components/web_scrollbar.dart';
import 'package:frontend/controller/navigation_controller.dart';
import 'package:frontend/models/get_cities.dart';
import 'package:frontend/views/search_results_page.dart';

class HomePage extends StatefulWidget {
  static const id = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController;
  double _scrollPosition = 0;
  double _opacity = 0;
  Future<GetHome> getHome;

  void _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    getHome = NavigationController.getCitiesController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    _opacity = _scrollPosition < screenSize.height * 0.40
        ? _scrollPosition / (screenSize.height * 0.40)
        : 1;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      extendBodyBehindAppBar: true,
      appBar: ResponsiveWidget.isLargeScreen(context) ||
              ResponsiveWidget.isMediumScreen(context)
          ? PreferredSize(
              preferredSize: Size(screenSize.width, 1000),
              child: TopBarContents(
                opacity: _opacity,
                showLeading: false,
              ),
            )
          : AppBar(
              backgroundColor:
                  Theme.of(context).primaryColor.withOpacity(_opacity),
              elevation: 0,
              title: Text(
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
      drawer: ExploreDrawer(),
      body: WebScrollbar(
        color: Theme.of(context).accentColor,
        backgroundColor: Colors.blueGrey.withOpacity(0.3),
        width: 10,
        heightFraction: 0.3,
        controller: _scrollController,
        child: ListView(
          physics: ClampingScrollPhysics(),
          controller: _scrollController,
          children: [
            Stack(
              children: [
                Container(
                  child: SizedBox(
                    height: screenSize.height * 0.85,
                    width: screenSize.width,
                    child: Image.asset(
                      'images/cover.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  margin: !(ResponsiveWidget.isSmallScreen(context) ||
                          ResponsiveWidget.isSemiMediumScreen(context))
                      ? EdgeInsets.symmetric(horizontal: screenSize.width * 0.3)
                      : EdgeInsets.all(20),
                  child: SearchBar(),
                )
              ],
            ),
            DestinationHeading(screenSize: screenSize),
            FutureBuilder<GetHome>(
              future: getHome,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CityCarousel(
                        cities: snapshot.data.cities,
                      ),
                      SizedBox(height: 20),
                      TagCarousel(tags: snapshot.data.tags),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.1,
                            vertical: 20),
                        child: Column(
                            children: snapshot.data.stars.reversed
                                .map((e) => GestureDetector(
                                      onTap: () async {
                                        await Navigator.pushNamed(
                                            context, SearchResultsPage.id,
                                            arguments: {
                                              'q': e.tag,
                                              'useAdvanceSearch': true
                                            });
                                      },
                                      child: Image.network(
                                        e.thumbnail,
                                        height: 75,
                                      ),
                                    ))
                                .toList()),
                      )
                    ],
                  );
                } else if (snapshot.hasError) {
                  return CustomErrorWidget(
                    message: 'Error in fetching Cities....',
                  );
                } else {
                  return Center(
                      child: SpinKitCircle(
                    color: Theme.of(context).accentColor,
                  ));
                }
              },
            ),
            SizedBox(
              height: 30,
            ),
            BottomBar()
          ],
        ),
      ),
    );
  }
}
