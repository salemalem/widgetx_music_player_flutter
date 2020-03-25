import 'package:flutter/material.dart';

// for curved navigation bar
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// search_music
import 'search_music/main.dart';

void main() {
  runApp(
    MaterialApp(
      home: CurvedBottomNavigationBar(),
    )
  );
}

class CurvedBottomNavigationBar extends StatefulWidget {
  @override
  _CurvedBottomNavigationBarState createState() => _CurvedBottomNavigationBarState();
}

class _CurvedBottomNavigationBarState extends State<CurvedBottomNavigationBar> {
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 50.0,
        items: <Widget>[
          Icon(
            Icons.search,
            size: 30,
            color: Colors.white70,
          ),
          Icon(
            Icons.library_music,
            size: 30,
            color: Colors.white70,
          ),
          Icon(
            Icons.free_breakfast,
            size: 30,
            color: Colors.white70,
          )
        ],
        color: Colors.black,
        buttonBackgroundColor: Colors.green[500],
        backgroundColor: Colors.grey[900],
        animationCurve: Curves.easeOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
      body: swapBodyWidget(_page),
    );
  }
}

swapBodyWidget(page) {
  var widget;
  if (page == 0) {
    widget = SearchMusic();
  } else {
//    return Page2();
  }
  return widget;
}