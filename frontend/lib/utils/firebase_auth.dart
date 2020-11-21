import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';

class FirebaseAuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseAuthService({FirebaseAuth firebaseAuth});

  static Future<Map> signInWithGoogle() async {
    try {
      final userCredentials =
          await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
      var jwt = await userCredentials.user.getIdToken();
      var displayName = userCredentials.user.displayName;
      var email = userCredentials.user.email;
      var phoneNumber = userCredentials.user.phoneNumber;
      logger.d(phoneNumber);
      return {'idToken':jwt,'name':displayName,'email':email,'phone_number':phoneNumber};
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
