import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/utils/Jwt.dart';
import 'package:frontend/utils/routes.dart';

import '../main.dart';

class UserController {
  static Future<String> signupController(
      {@required String name,
      @required String email,
      @required String password,
      @required String phone_number}) async {
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
      final res = await _dio.post(signup, data: {
        'name': name,
        'email': email,
        'password': password,
        'phone_number': phone_number
      });
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return (res.data['idToken'] as String);
      } else {
        return '';
      }
    } catch (e) {
      logger.e(e);
      return '';
    }
  }

  static Future<bool> googleSignupController(
      {@required String idToken}) async {
    try {
      // ignore: omit_local_variable_types
      Dio _dio = Dio(
        BaseOptions(
          baseUrl: 'https://staysia.herokuapp.com/api/',
          headers: {
            'Authorization': 'Bearer $idToken',
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
      final res = await _dio.put(googleSignup);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  static Future<String> loginController({
    @required String email,
    @required String password,
  }) async {
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
      final res =
          await _dio.post(login, data: {'password': password, 'email': email});
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return (res.data['idToken'] as String);
      } else {
        logger.w(res);
        return '';
      }
    } catch (e) {
      logger.e(e);
      return '';
    }
  }

  static Future<bool> logoutController() async {
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
      final res = await _dio.get(logout);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  static Future<User> getProfileController() async {
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
      final res = await _dio.get(getProfile);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return User(
            name: res.data['name'] as String,
            email: res.data['email'] as String,
            phone_number: res.data['phone_number'] as String);
      } else {
        return null;
      }
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  static Future<User> patchProfileController(
      {@required String name, @required String phone_number}) async {
    try {
      // ignore: omit_local_variable_types
      Dio _dio = Dio(
        BaseOptions(
          baseUrl: 'https://staysia.herokuapp.com/api/',
          headers: {
            'Authorization': 'Bearer ${Get.find<Jwt>().token.value}',
          },
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
      final res = await _dio.patch(patchProfile,
          data: {'name': name, 'phone_number': phone_number});
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return User(
            name: res.data['name'] as String,
            email: res.data['email'] as String,
            phone_number: res.data['phone_number'] as String);
      } else {
        return null;
      }
    } catch (e) {
      logger.e(e);
      return null;
    }
  }
}
