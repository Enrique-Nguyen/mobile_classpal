class User {
  final String id;
  final String email;

  User({required this.id, required this.email});
  const User.empty() : id = '', email = '';
  const User.init({required this.id, required this.email});
}
