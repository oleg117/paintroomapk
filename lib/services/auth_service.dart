import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  Future<void> initialize() async {
    // Слушаем изменения состояния авторизации Firebase
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _saveUserData(user);
      }
    });
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Сначала выходим из предыдущей сессии
      await _googleSignIn.signOut();
      
      // Вход через Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Google Sign In: User cancelled');
        return null; // Пользователь отменил вход
      }

      print('✅ Google Sign In: User selected - ${googleUser.email}');

      // Получаем токены аутентификации
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      print('✅ Google Auth: Tokens received');

      // Создаём credential для Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('✅ Firebase: Credential created');

      // Входим в Firebase с помощью credential
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      print('✅ Firebase: Sign in successful - ${userCredential.user?.email}');

      return userCredential.user;
    } catch (error) {
      print('❌ Sign In Error: $error');
      rethrow; // Пробрасываем ошибку выше для отображения
    }
  }

  // Временное решение: Anonymous Authentication
  Future<User?> signInAnonymously() async {
    try {
      print('🔄 Attempting anonymous sign in...');
      final UserCredential userCredential = 
          await _auth.signInAnonymously();
      
      print('✅ Anonymous sign in successful');
      
      // Создаём фейковые данные для анонимного пользователя
      final user = userCredential.user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', 'anonymous@paintroom.app');
        await prefs.setString('user_name', 'Гость');
        await prefs.setString('user_photo', '');
      }
      
      return user;
    } catch (error) {
      print('❌ Anonymous Sign In Error: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_photo');
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', user.email ?? '');
    await prefs.setString('user_name', user.displayName ?? '');
    await prefs.setString('user_photo', user.photoURL ?? '');
  }

  Future<Map<String, String>> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email') ?? '',
      'name': prefs.getString('user_name') ?? '',
      'photo': prefs.getString('user_photo') ?? '',
    };
  }
}
