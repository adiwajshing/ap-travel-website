import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/detailed_hotel.dart';
import 'package:frontend/models/get_cities.dart';
import 'package:frontend/models/hotel.dart';
import 'package:frontend/models/hotel_overview.dart';
import 'package:frontend/utils/Jwt.dart';
import 'package:frontend/utils/routes.dart';

import '../main.dart';

class NavigationController {
  static Future<GetHome> getCitiesController() async {
    try {
      // ignore: omit_local_variable_types
      Dio _dio = Dio(
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
                Get.find<Jwt>().setToken(null);
                final preferences = await SharedPreferences.getInstance();
                await preferences.remove('jwt');
                //TODO: push to login page
              }
            },
          ),
        ]);
      final res = await _dio.get(getHome);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return GetHome.fromJson(res.data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  static Future<List<Hotel>> getHotelsWithTagController(
      {String cityName, @required String tag}) async {
    try {
      // ignore: omit_local_variable_types
      Dio _dio = Dio(
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
                Get.find<Jwt>().setToken(null);
                final preferences = await SharedPreferences.getInstance();
                await preferences.remove('jwt');
                //TODO: push to login page
              }
            },
          ),
        ]);
      final res = await _dio.get(getHotelsWithTags + tag, queryParameters: {
        if (cityName != null) 'city': cityName,
      });
      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.statusCode == 204) {
          return [];
        }
        return (res.data as List<dynamic>)
            .map((e) => Hotel.fromJson(e as Map<String, dynamic>))
            .toList()
            .cast<Hotel>();
      } else {
        return [];
      }
    } catch (e) {
      logger.e(e);
      return [];
    }
  }

  static Future<List<Hotel>> searchHotelWithNameController({
    @required String q,
    String city,
    String checkIn,
    String checkOut,
  }) async {
    try {
      // ignore: omit_local_variable_types
      Dio _dio = Dio(
        BaseOptions(
          baseUrl: 'https://staysia.herokuapp.com/api/',
          headers: Get.find<Jwt>().token.value == null ||
                  Get.find<Jwt>().token.value == ''
              ? {}
              : {
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
                Get.find<Jwt>().setToken(null);
                final preferences = await SharedPreferences.getInstance();
                await preferences.remove('jwt');
                //TODO: push to login page
              }
            },
          ),
        ]);
      final res = await _dio.get(searchHotelsWithName, queryParameters: {
        'q': q,
        if (city != null) 'city': city,
        if (checkIn != null) 'check_In': checkIn,
        if (checkOut != null) 'check_Out': checkOut,
      });
      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.statusCode == 204) {
          return [];
        }
        return (res.data as List<dynamic>)
            .map((e) => Hotel.fromJson(e as Map<String, dynamic>))
            .toList()
            .cast<Hotel>();
      } else {
        return null;
      }
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  static Future<List<HotelOverview>> fuzzySearchController(
      {@required String q}) async {
    try {
      // ignore: omit_local_variable_types
      Dio _dio = Dio(
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
                Get.find<Jwt>().setToken(null);
                final preferences = await SharedPreferences.getInstance();
                await preferences.remove('jwt');
                //TODO: push to login page
              }
            },
          ),
        ]);
      final res = await _dio.get(fuzzySearch, queryParameters: {'q': q});
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return (res.data as List<dynamic>)
            .map((e) => HotelOverview.fromJson(e as Map<String, dynamic>))
            .toList()
            .cast<HotelOverview>();
      } else {
        return null;
      }
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  static Future<List<Hotel>> advanceSearchController(
      {@required String q}) async {
    try {
      // ignore: omit_local_variable_types
      Dio _dio = Dio(
        BaseOptions(
          baseUrl: 'https://staysia.herokuapp.com/api/',
          headers: Get.find<Jwt>().token.value == null ||
                  Get.find<Jwt>().token.value == ''
              ? {}
              : {
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
                Get.find<Jwt>().setToken(null);
                final preferences = await SharedPreferences.getInstance();
                await preferences.remove('jwt');
                //TODO: push to login page
              }
            },
          ),
        ]);
      final res = await _dio.get(advanceSearch, queryParameters: {
        'q': q,
      });
      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.statusCode == 204) {
          return [];
        }
        return (res.data as List<dynamic>)
            .map((e) => Hotel.fromJson(e as Map<String, dynamic>))
            .toList()
            .cast<Hotel>();
      } else {
        return null;
      }
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  static Future<DetailedHotel> getHotelByIdController(
      {@required String hotelId}) async {
    try {
      // ignore: omit_local_variable_types
      Dio _dio = Dio(
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
                Get.find<Jwt>().setToken(null);
                final preferences = await SharedPreferences.getInstance();
                await preferences.remove('jwt');
                //TODO: push to login page
              }
            },
          ),
        ]);
      final res = await _dio.get(getHotelById + hotelId);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return DetailedHotel.fromJson(res.data as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  static Future<List<Hotel>> getHotelRecommendationByIdController(
      {@required String hotelId}) async {
    try {
      // ignore: omit_local_variable_types
      Dio _dio = Dio(
        BaseOptions(
          baseUrl: 'https://staysia.herokuapp.com/api/',
          headers: Get.find<Jwt>().token.value == null ||
                  Get.find<Jwt>().token.value == ''
              ? {}
              : {
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
                Get.find<Jwt>().setToken(null);
                final preferences = await SharedPreferences.getInstance();
                await preferences.remove('jwt');
                //TODO: push to login page
              }
            },
          ),
        ]);
      final res = await _dio.get(
        getHotelRecommendationById.replaceAll('{hotelId}', hotelId),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return (res.data as List<dynamic>)
            .map((e) => Hotel.fromJson(e as Map<String, dynamic>))
            .toList()
            .cast<Hotel>();
      } else {
        return null;
      }
    } catch (e) {
      logger.e(e);
      return null;
    }
  }
  static Future<List<Hotel>> getHotelNetworkByIdController(
      {@required String hotelId}) async {
    try {
      // ignore: omit_local_variable_types
      Dio _dio = Dio(
        BaseOptions(
          baseUrl: 'https://staysia.herokuapp.com/api/',
          headers: Get.find<Jwt>().token.value == null ||
              Get.find<Jwt>().token.value == ''
              ? {}
              : {
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
              Get.find<Jwt>().setToken(null);
              final preferences = await SharedPreferences.getInstance();
              await preferences.remove('jwt');
              //TODO: push to login page
            }
          },
        ),
      ]);
      final res = await _dio.get(
        getHotelNetworkById.replaceAll('{hotelId}', hotelId),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return (res.data as List<dynamic>)
            .map((e) => Hotel.fromJson(e as Map<String, dynamic>))
            .toList()
            .cast<Hotel>();
      } else {
        return null;
      }
    } catch (e) {
      logger.e(e);
      return null;
    }
  }
}
