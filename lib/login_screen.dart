import 'package:crudtest/home_screen.dart';
import 'package:crudtest/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if (account != null) {
        print("user id : ${account.id}");
        _currentUser = account;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(user: _currentUser),
          ),
        );
        toast("Signin success!");
      } else {
        toast("No user signed in.");
      }
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text("CrudTest",style: TextStyle(fontSize: 38),),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Center(
                child: RaisedButton(
                  child: Text("GOOGLE SIGNIN"),
                  onPressed: () {
                    _handleSignIn().then((FirebaseUser user) {
                      print("user $user");
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen(user: _currentUser),
                          ),
                        );
                      }
                    }).catchError((e) => print(e));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }
}
