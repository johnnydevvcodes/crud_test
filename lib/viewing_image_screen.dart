import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudtest/constants.dart';
import 'package:crudtest/full_screen_carousel.dart';
import 'package:crudtest/like.dart';
import 'package:crudtest/main.dart';
import 'package:crudtest/photo.dart';
import 'package:crudtest/storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';

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
  List<Asset> images = List<Asset>();
  var storage = serviceLocator.get<StorageService>();
  FirebaseStorage _storageIns;
  var _imageList = List<String>();

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
//          Container(
//            decoration: BoxDecoration(
//              image: DecorationImage(
//                image: NetworkImage(widget.photo.photoUrl),
//                fit: BoxFit.fitHeight,
//              ),
//            ),
//          ),
          StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .document("$KEY_PHOTOS/${widget.photo.docId}")
                  .collection(widget.photo.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return FullscreenSliderDemo(
                        imgList: [widget.photo.photoUrl]);
                  default:
                    _imageList = List<String>();
                    _imageList.add(widget.photo.photoUrl);
                    snapshot.data.documents?.forEach((data) {
                      if (data['subphoto'] != null) {
                        _imageList.add(data['subphoto']);
                        print("subphotos: ${data['subphoto']}");
                      }
                    });
                    return FullscreenSliderDemo(imgList: _imageList);
                }
              }),

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
                        _showLikes();
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
                  GestureDetector(
                    onTap: () => _addPhotos(),
                    child: Container(
                        width: double.infinity,
                        height: 60,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("+ Add Photos",
                                style: TextStyle(fontSize: 16)))),
                  ),
                  GestureDetector(
                    onTap: () {
                      _backHome();
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
                    _deleteFromStorage().then((_){
                      _backHome();
                    });
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
    Firestore.instance
        .document("$KEY_PHOTOS/${photo.docId}")
        .updateData(Photo(
                uid: photo.uid,
                photoName: _labelController.text,
                photoUrl: photo.photoUrl,
                postedBy: photo.postedBy,
                likes: photo.likes)
            .toMap())
        .then((_) {
      _backHome();
    });
  }

  void _showLikes() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Container(
            height: 250,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .document("$KEY_PHOTOS/${widget.photo.docId}")
                      .collection(widget.photo.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return new Text('Loading...');
                      default:
                        var likes = List<Like>();
                        snapshot.data.documents?.forEach((data) {
                          if (data['subphoto'] == null) {
                            var l = data.data;
                            likes.add(Like.fromMap(l));
                            print("likes: ${likes}");
                          }
                        });

                        return CustomScrollView(
                          slivers: <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                print("index : $index");
                                var likeObj = likes[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(2, 4, 2, 0),
                                  child: ListTile(
                                    leading: FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image: likeObj.photoUrl,
                                    ),
                                    title: Text(likeObj.email),
                                  ),
                                );
                              }, childCount: likes?.length),
                            ),
                          ],
                        );
                    }
                  }),
            ),
          ));
        });
  }

  Future<void> _uploadFile(File image) async {
    if (_storageIns == null) _storageIns = await storage.storageInstance;
    final String uuid = Uuid().v1();
    final StorageReference ref = _storageIns
        .ref()
        .child('subphotos')
        .child(widget.photo.docId)
        .child('$uuid.jpg');
    final StorageUploadTask uploadTask = ref.putFile(image);
    await uploadTask.onComplete;

    print('File Uploaded subphotos');
    ref.getDownloadURL().then((fileURL) {
      setState(() {
        print('File Uploaded dl url: subphoto: $fileURL');
        //subcollection for added photos
        Firestore.instance
            .document(
                "$KEY_PHOTOS/${widget.photo.docId}") //inside this initial photo
            .collection(widget.photo.uid)
            .document() //auto generated
            .setData({'subphoto': fileURL});
      });
    });
  }

  Future<void> _addPhotos() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        enableCamera: true,
        maxImages: 10,
        selectedAssets: images,
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      images.forEach((image) async {
        print("images: ${image.name}");
        var bytes = await image.getByteData(quality: 100);
        if (bytes != null) _uploadFile(await writeToFile(bytes));
      });
      print("images: ${images.length}");
//      _error = error;
    });
  }

  Future<void> _deleteFromStorage() async {
    var ref = await FirebaseStorage.instance
        .getReferenceFromUrl(widget.photo.photoUrl);
    await ref.delete();
    _imageList.forEach((image) async {
      print("image to delete:  ${image}");
      var ref = await FirebaseStorage.instance.getReferenceFromUrl(image);
      await ref.delete();
    });
  }
}
