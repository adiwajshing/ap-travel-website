import 'package:flutter/cupertino.dart';

class User extends ChangeNotifier {
  String name;
  String email;
  String phone_number;
  bool _isLoggedIn;

  bool get isLoggedIn => _isLoggedIn;

  void setLoggedInStatus(bool loggedIn) {
    _isLoggedIn = loggedIn;
    notifyListeners();
  }

  User({
    @required this.name,
    @required this.email,
    @required this.phone_number,
  });

  factory User.fromJson(Map json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      phone_number: json['phone_number'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // ignore: unnecessary_this
      'name': this.name,
      // ignore: unnecessary_this
      'email': this.email,
      // ignore: unnecessary_this
      'phone_number': this.phone_number,
    };
  }

  @override
  String toString() {
    return 'User{name: $name, email: $email, phone_number: $phone_number}';
  }

  void updateUserInProvider(User user) {
    // ignore: unnecessary_this
    this.name = user.name;
    // ignore: unnecessary_this
    this.email = user.email;
    // ignore: unnecessary_this
    this.phone_number = user.phone_number;

    notifyListeners();
  }
}
