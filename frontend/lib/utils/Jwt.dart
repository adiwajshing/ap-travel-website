
import 'package:get/get.dart';
import 'package:frontend/main.dart';

class Jwt extends GetxController {
  RxString token = ''.obs;
  void setToken(String jwt) {
    token.value = jwt;
    logger.d('jwt: $jwt');

  }
}
