

class User {
  final String id;
  final String email;
  final String photoUrl;
  final double balance;
  final Future<Map<String, String>> headers;

  User({this.headers, this.photoUrl, this.balance, this.id, this.email});


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'balance': balance,
      'photoUrl': photoUrl,
    };
  }
}