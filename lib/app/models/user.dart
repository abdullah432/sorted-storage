class User {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final double balance;
  final Map<String, String> headers;

  User(
      {this.displayName,
      this.headers,
      this.photoUrl,
      this.balance,
      this.id,
      this.email});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': displayName,
      'email': email,
      'balance': balance,
      'photoUrl': photoUrl,
    };
  }
}
