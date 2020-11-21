import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Jwt.dart';

Dio getDioInstance({bool removeBaseHeaders = false}) {
  if (removeBaseHeaders) {
    return Dio(
      BaseOptions(
        baseUrl: 'https://staysia.herokuapp.com/api/',
        headers: {
          'Authorization': 'Bearer ${Get.find<Jwt>().token.value}',
        },
      ),
    )..interceptors.addAll([
        PrettyDioLogger(requestBody: true),
        InterceptorsWrapper(
          onError: (DioError error) async {
            if (error.response == null) {
              // ignore: avoid_print
              print(error);
            } else if (error.response.statusCode == 401) {
              Get.find<Jwt>()
.setToken(null);
              final preferences = await SharedPreferences.getInstance();
              await preferences.remove('jwt');
              //TODO: push to login page
            }
          },
        ),
      ]);
  }
  return Dio(
    BaseOptions(
      baseUrl: 'https://staysia.herokuapp.com/api/',
      headers: {
        'Authorization': 'Bearer ${Get.find<Jwt>().token.value}',
        // 'X-Requested-With': 'XMLHttpRequest',
      },
      contentType: Headers.formUrlEncodedContentType,
    ),
  )..interceptors.addAll([
      PrettyDioLogger(requestBody: true, requestHeader: true),
      InterceptorsWrapper(
        onError: (DioError error) async {
          if (error.response == null) {
            // ignore: avoid_print
            print(error);
          } else if (error.response.statusCode == 401) {
            Get.find<Jwt>()
.setToken(null);
            final preferences = await SharedPreferences.getInstance();
            await preferences.remove('jwt');
            //TODO: push to login page
          }
        },
      ),
    ]);
}
