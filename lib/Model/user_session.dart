class UserSession {
  static final UserSession _instance = UserSession._internal();

  String? email; // Store logged-in email

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();
}
