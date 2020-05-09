import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudtest/main.dart';
import 'package:crudtest/photo.dart';
import 'package:crudtest/photo_item_view.dart';
import 'package:crudtest/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'constants.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  final GoogleSignInAccount user;

  const HomeScreen({Key key, this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var storage = serviceLocator.get<StorageService>();
  List<Asset> images = List<Asset>();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];

  FirebaseStorage _storageIns;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton(
        icon: Icon(
          Icons.add_a_photo,
          size: 40,
        ),
        onPressed: () async {
          loadAssets();
        },
      ),
      appBar: AppBar(
        title: Text("HomeScreen"),
      ),
      body: Container(
        child:
        StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection(KEY_PHOTOS).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Text('Loading...');
                default:
                  return
                    CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                          print("index : $index");

                          var photo =
                              snapshot.data.documents?.elementAt(index)?.data;
                          var photoObj = Photo.fromMap(photo);
                          photoObj.docId = snapshot.data.documents
                              ?.elementAt(index)
                              ?.documentID;

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
                            child: PhotoItemView(
                                photo: photoObj, user: widget.user),
                          );
                        }, childCount: snapshot.data.documents?.length),
                      ),
                    ],
                  );
              }
            }),
      ),
    );
  }

  Future<void> _uploadFile(File image) async {
    if (_storageIns == null) _storageIns = await storage.storageInstance;
    final String uuid = Uuid().v1();
    print("user id loop : ${widget.user}");
    final StorageReference ref = _storageIns
        .ref()
        .child('photos')
        .child(widget.user.id)
        .child('$uuid.jpg');
    final StorageUploadTask uploadTask = ref.putFile(image);
    await uploadTask.onComplete;

    print('File Uploaded');
    ref.getDownloadURL().then((fileURL) {
      setState(() {
        print('File Uploaded dl url: $fileURL');
        print('posting by.. email ${widget.user.email}');
        Firestore.instance.collection(KEY_PHOTOS).document().setData(Photo(
              uid: widget.user.id,
              photoUrl: fileURL,
              postedBy: widget.user.email,
            ).toMap());
      });
    });
  }

  Future<void> loadAssets() async {
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
}
