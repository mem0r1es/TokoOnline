class AuthService {
  static List<Map<String, String>> _users = [
    {
      'email': 'test@example.com',
      'username': 'testuser',
      'contact': '1234567890',
      'password': 'password123',
    },
  ];

  static bool signUp(String email, String username, String contact, String password) {
    // Check if user already exists
    bool userExists = _users.any((user) => user['email'] == email);
    
    if (userExists) {
      return false;
    }
    
    // Add new user
    _users.add({
      'email': email,
      'username': username,
      'contact': contact,
      'password': password,
    });
    
    return true;
  }

  static bool signIn(String email, String password) {
    // Find user with matching email and password
    return _users.any((user) => 
      user['email'] == email && user['password'] == password
    );
  }

  static void signOut() {
    // In a real app, you would clear tokens, etc.
    // For this demo, we don't need to do anything
  }

  static List<Map<String, String>> getUsers() {
    return _users;
  }
}