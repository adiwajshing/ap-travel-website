import 'package:flutter/material.dart';
import 'package:frontend/components/TopBarContents.dart';
import 'package:frontend/components/explore_drawer.dart';
import 'package:frontend/components/responsive_widget.dart';

import 'home_page.dart';

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(),
    );
  }
}
