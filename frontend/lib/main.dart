import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import 'package:frontend/models/user.dart';
import 'package:frontend/utils/constants.dart';
import 'package:frontend/utils/route_generator.dart';
import 'package:frontend/views/splash_page.dart';

void main() {
  runApp(MyApp());
}

final GlobalKey<NavigatorState> nav = GlobalKey<NavigatorState>();
var logger = Logger(
  printer: PrettyPrinter(
      methodCount: 0, colors: true, printEmojis: true, printTime: false),
);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey[800],
    ));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<User>(
          create: (_) => User(phone_number: '', email: '', name: ''),
        ),
      ],
      child: OverlaySupport(
        child: MaterialApp(
          navigatorKey: nav,
          theme: kDefaultTheme,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: RouteGenerator.generateRoute,
          initialRoute: SplashPage.id,
        ),
      ),
    );
  }
}