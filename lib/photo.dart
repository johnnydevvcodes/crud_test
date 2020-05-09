class Photo {
  final String uid;
  final String photoName;
  final String photoUrl;
  final String postedBy;
  final int likes;
  String docId;

  Photo({
    this.uid,
    this.photoName,
    this.photoUrl,
    this.postedBy,
    this.likes,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'photoName': photoName,
      'photoUrl': photoUrl,
      'postedBy': postedBy,
      'likes': likes,
    };
  }

  static Photo fromMap(Map<String, dynamic> map) {
    return Photo(
      uid: map['uid'],
      photoName: map['photoName'],
      photoUrl: map['photoUrl'],
      postedBy: map['postedBy'],
      likes: map['likes'],
    );
  }
}
