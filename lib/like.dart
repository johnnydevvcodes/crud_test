class Like {
  final String email;
  final String photoUrl;

  Like({
    this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return{
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  static Like fromMap(Map<String, dynamic> map) {
    return Like(
      email: map['email'],
      photoUrl: map['photoUrl'],
    );
  }
}
