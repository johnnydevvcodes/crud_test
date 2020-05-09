import 'package:crudtest/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ViewingLikes extends StatelessWidget {
  final Photo photo;

  const ViewingLikes({Key key, this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ViewLikes"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(flex: 1, child: Text("SEARCH")),
            Expanded(
              flex: 4,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
//                    delegate: SliverChildBuilderDelegate(
//                        (BuildContext context, int index) {
//                      var photo = photos?.elementAt(index);
//                      return Padding(
//                        padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
//                        child: Text(photo.uid),
//                      );
//                    }, childCount: photos?.length),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
