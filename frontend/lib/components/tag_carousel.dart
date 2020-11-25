import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/responsive_widget.dart';
import 'package:frontend/models/get_cities.dart';
import 'package:frontend/views/search_results_page.dart';

class TagCarousel extends StatefulWidget {
  final List<Data> tags;

  TagCarousel({@required this.tags});

  @override
  _TagCarouselState createState() => _TagCarouselState();
}

class _TagCarouselState extends State<TagCarousel> {
  final CarouselController _controller = CarouselController();

  void setData() {
    widget.tags.forEach((element) {
      _isHovering.add(false);
      _isSelected.add(false);
      images.add(element.thumbnail);
      displayName.add(element.displayName);
      tags.add(element.tag);
    });
  }

  // ignore: prefer_final_fields
  List<bool> _isHovering = [];

  // ignore: prefer_final_fields
  List<bool> _isSelected = [];
  int _current = 0;

  final List<String> images = [];
  final List<String> displayName = [];
  final List<String> tags = [];

  List<Widget> generateImageTiles(screenSize) {
    return images
        .map(
          (element) => GestureDetector(
        onTap: () async {
          await Navigator.pushNamed(context, SearchResultsPage.id,
              arguments: {
                'q': tags[images.indexOf(element)],
                'useAdvanceSearch': true
              });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: FadeInImage(
            placeholder: AssetImage('images/shimmer.gif'),
            image: NetworkImage(element),
            fit: BoxFit.cover,
          ),
        ),
      ),
    )
        .toList();
  }

  @override
  void initState() {
    setData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var imageSliders = generateImageTiles(screenSize);

    return Stack(
      children: [
        CarouselSlider(
          items: imageSliders,
          options: CarouselOptions(
              scrollPhysics: NeverScrollableScrollPhysics(),
              enlargeCenterPage: true,
              aspectRatio: 4 / 2,
              autoPlay: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                  for (var i = 0; i < imageSliders.length; i++) {
                    if (i == index) {
                      _isSelected[i] = true;
                    } else {
                      _isSelected[i] = false;
                    }
                  }
                });
              }),
          carouselController: _controller,
        ),
        AspectRatio(
          aspectRatio: 4 / 2,
          child: Center(
            child: Text(
              displayName[_current],
              style: TextStyle(
                letterSpacing: 8,
                fontFamily: 'Electrolize',
                fontSize: screenSize.width / 25,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (ResponsiveWidget.isSmallScreen(context))
          Container()
        else
          AspectRatio(
            aspectRatio: 4 / 2,
            child: Center(
              heightFactor: 1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width / 8,
                  ),
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: screenSize.height / 100,
                        bottom: screenSize.height / 100,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int i = 0; i < displayName.length; i++)
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    onHover: (value) {
                                      setState(() {
                                        value
                                            ? _isHovering[i] = true
                                            : _isHovering[i] = false;
                                      });
                                    },
                                    onTap: () {
                                      _controller.animateToPage(i);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: screenSize.height / 80,
                                          bottom: screenSize.height / 90),
                                      child: Text(
                                        displayName[i],
                                        style: TextStyle(
                                          color: _isHovering[i] != null
                                              ? Theme.of(context)
                                              .primaryTextTheme
                                              .button
                                              .decorationColor
                                              : Theme.of(context)
                                              .primaryTextTheme
                                              .button
                                              .color,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    maintainSize: true,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    visible: _isSelected[i],
                                    child: AnimatedOpacity(
                                      duration: Duration(milliseconds: 400),
                                      opacity: _isSelected[i] != null ? 1 : 0,
                                      child: Container(
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).accentColor,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        width: screenSize.width / 10,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
