import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudtest/constants.dart';
import 'package:crudtest/photo.dart';
import 'package:crudtest/viewing_likes.dart';
import 'package:flutter/material.dart';

class ViewingImageScreen extends StatefulWidget {
  final Photo photo;
  final String uid;

  const ViewingImageScreen({Key key, this.photo, this.uid}) : super(key: key);

  @override
  _ViewingImageScreenState createState() => _ViewingImageScreenState();
}

class _ViewingImageScreenState extends State<ViewingImageScreen> {
  PersistentBottomSheetController _bottomSheetController;
  var _labelController = TextEditingController();

  bool _isByYou;

  @override
  void initState() {
    _isByYou = widget.uid == widget.photo.uid;
    print("view image photo uid : ${widget.uid} ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Max Size
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.photo.photoUrl),
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Positioned(
            left: 40.0,
            bottom: 40.0,
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              height: 150.0,
              width: 150.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.photo.photoName ?? "Label",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  Text(
                    "Posted by ${_isByYou ? "You" : (widget.photo.postedBy ?? "unknown")}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                      },
                      child: Text(
                        "${widget.photo.likes ?? 0} likes",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          _isByYou
              ? Positioned(
                  right: 30.0,
                  top: 20.0,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.white,
                        onPressed: () {
                          _deleteDialog();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.white,
                        onPressed: () {
                          _bottomSheet();
                        },
                      ),
                    ],
                  ),
                )
              : Container(),
          Positioned(
            left: 30.0,
            top: 20.0,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed: () {
                _backHome();
              },
            ),
          ),
        ],
      ),
    );
  }

  _bottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      height: 60,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: TextField(
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            hintText: widget.photo.photoName ?? "Label",
                          ),
                          controller: _labelController,
                          style: TextStyle(fontSize: 16),
                        ),
                      )),
                  Container(
                      width: double.infinity,
                      height: 60,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("+ Add Photos",
                              style: TextStyle(fontSize: 16)))),
                  GestureDetector(
                    onTap: () {
                      _updatePhoto();
                    },
                    child: Card(
                      color: Colors.grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Container(
                        height: 60,
                        child: Center(
                          child: Text("Confirm",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
        });
  }

  void _deleteDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure to delete this photo?'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Yes'),
                onPressed: () {
                  //go back to previous page
                  Navigator.pop(context);
                  Firestore.instance
                      .document("$KEY_PHOTOS/${widget.photo.docId}")
                      .delete()
                      .then((_) {
                    _backHome();
                  });
                  //toast "changes not saved"
                },
              ),
              FlatButton(
                child: new Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }



  void _backHome() {
    Navigator.of(context).pop();
  }

  void _updatePhoto() {
    var photo = widget.photo;
    Firestore.instance.document("$KEY_PHOTOS/${photo.docId}").updateData(Photo(
            uid: photo.uid,
            photoName: _labelController.text,
            photoUrl: photo.photoUrl,
            postedBy: photo.postedBy,
            likes: photo.likes)
        .toMap());
  }
}
