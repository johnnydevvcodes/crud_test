
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class StorageService {

  Future<FirebaseStorage> get storageInstance async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: 'crudtest',
      options: FirebaseOptions(
        googleAppID: (Platform.isIOS || Platform.isMacOS)
            ? '1:982029422211:ios:8a0797fc3830b221d595b6'
            : '1:982029422211:android:91587fba88d5af4cd595b6',
        gcmSenderID: '982029422211',
        apiKey: 'AIzaSyBXP0vEazYovd47_dFML3J3SuSyB-Ybev4',
        projectID: 'crudtest-49f73',
      ),
    );
    final FirebaseStorage storage = FirebaseStorage(
        app: app, storageBucket: 'gs://crudtest-49f73.appspot.com');
    print("storage: $storage");
    return storage;
  }


}