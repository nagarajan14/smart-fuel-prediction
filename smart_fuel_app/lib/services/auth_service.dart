import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  // Stream of Auth State
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get current User ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Login
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Error in login: \$e");
      return null;
    }
  }

  // Register
  Future<User?> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      
      User? user = result.user;
      if (user != null) {
        // Create a new document for the user in Firestore
        UserModel newUser = UserModel(
          id: user.uid,
          email: email,
          name: name,
        );
        await _db.createUser(newUser);
      }
      return user;
    } catch (e) {
      print("Error in registration: \$e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
