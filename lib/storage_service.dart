
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class StorageService {

  Future<FirebaseStorage> get storageInstance async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: 'FriendlyChat',
      options: FirebaseOptions(
        googleAppID: (Platform.isIOS || Platform.isMacOS)
            ? '1:192987369777:ios:34623f0bc223a85ff0a010'
            : '1:192987369777:android:eff3267713a04500f0a010',
        gcmSenderID: '192987369777',
        apiKey: 'AIzaSyBH2ZQ_gAkh3oyeAD18z_GDqBzq6nN3Ysw',
        projectID: 'friendlychat-3e6e7',
      ),
    );
    final FirebaseStorage storage = FirebaseStorage(
        app: app, storageBucket: 'gs://friendlychat-3e6e7.appspot.com');
    print("storage: $storage");
    return storage;
  }


}