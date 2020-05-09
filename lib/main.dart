import 'package:crudtest/crud_app.dart';
import 'package:crudtest/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

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