import 'dart:async';

import 'package:flutter/material.dart';

// for curved navigation bar
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// search_music
import 'downloaded_music/LocalMusicList.dart';
import 'search_music/main.dart';
import 'package:music_player_flutter/search_music/utils/convertToHexColor.dart';
import 'package:audioplayers/audioplayers.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();

  localMusicListMain();

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
        backgroundColor: HexColor('#121212'),
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

SearchMusic searchMusic = SearchMusic();
LocalMusicList localMusicList = LocalMusicList();

swapBodyWidget(page) {
  var widget;
  if (page == 0) {
    widget = searchMusic;
  } else if (page == 1) {
    widget = localMusicList;
  }
  return widget;
}