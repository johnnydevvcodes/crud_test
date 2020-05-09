import 'package:crudtest/home_screen.dart';
import 'package:crudtest/login_screen.dart';
import 'package:flutter/material.dart';

class CrudApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      home: LoginScreen(), /**[WorkoutListView] as home page**/
    );
  }
}
