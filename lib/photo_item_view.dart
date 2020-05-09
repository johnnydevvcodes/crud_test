import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudtest/like.dart';
import 'package:crudtest/photo.dart';
import 'package:crudtest/viewing_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:transparent_image/transparent_image.dart';

import 'constants.dart';

class PhotoItemView extends StatefulWidget {
  final Photo photo;
  final GoogleSignInAccount user;

  const PhotoItemView({Key key, this.photo, this.user}) : super(key: key);

  @override
  _PhotoItemViewState createState() => _PhotoItemViewState();
}

class _PhotoItemViewState extends State<PhotoItemView> {
  bool _isByYou;

  @override
  Widget build(BuildContext context) {
    _isByYou = widget.user.id == widget.photo.uid;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewingImageScreen(
                    photo: widget.photo,
                    uid: widget.user.id,
                  )),
        );
      },
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
            height: 69,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    width: 50,
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: widget.photo.photoUrl,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.photo.photoName ?? "Label",
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                          "Posted by ${_isByYou ? "You" : (widget.photo.postedBy ?? "unknown")}")
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.star_border),
                          onPressed: () {
                            _updateLikes(widget.photo);
                          }),
                      Text("${widget.photo.likes ?? ""}")
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }

  Future<void> _updateLikes(Photo photo) async {
    var likes = 0;
    if (photo.likes == null) {
      likes = 1;
    } else {
      likes = photo.likes + 1;
    }

    Firestore.instance
        .document("$KEY_PHOTOS/${photo.docId}")
        .updateData(Photo(
                uid: photo.uid,
                photoName: photo.photoName,
                photoUrl: photo.photoUrl,
                postedBy: photo.postedBy,
                likes: likes)
            .toMap())
        .then((_) {
      //subcollection for likes data
      Firestore.instance
          .document("$KEY_PHOTOS/${photo.docId}")
          .collection(widget.photo.uid)
          .document()
          .setData(Like(
            email: widget.user.email,
            photoUrl: widget.user.photoUrl,
          ).toMap());
    });
  }
}
