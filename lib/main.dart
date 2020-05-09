import 'package:crudtest/crud_app.dart';
import 'package:crudtest/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'package:uuid/uuid.dart';

GetIt serviceLocator = GetIt.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  serviceLocator.registerSingleton(StorageService());
  runApp(CrudApp());
}
void toast(String msg) =>  Fluttertoast.showToast(
  msg: msg,
  toastLength: Toast.LENGTH_LONG,
);


Future<File> writeToFile(ByteData data) {
  final buffer = data.buffer;
  final String uuid = Uuid().v1();
  final Directory systemTempDir = Directory.systemTemp;
  return new File('${systemTempDir.path}/$uuid').writeAsBytes(
      buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}