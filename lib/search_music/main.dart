import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_player_flutter/search_music/utils/convertToHexColor.dart';

import 'package:path_provider/path_provider.dart';

import 'utils/returnBuiltUrl.dart';
import 'utils/fetchSongs.dart';
import 'package:http/http.dart' as http;


var songsNamesList = [];
var songsArtistsList = [];
var songsLinksList = [];
var songImagesList = [];
var songsDurationsList = [];

var listTileTextStyle = TextStyle(
  color: Colors.green[200]
);

class SearchMusic extends StatefulWidget {
  @override
  _SearchMusicState createState() => _SearchMusicState();

  onTextChanged(String text) {}
}
class _SearchMusicState extends State<SearchMusic> {
  TextEditingController _searchMusicController = TextEditingController();
  final downloadSuccessfulSnackBar = SnackBar(
    content: Text('Сәтті! Жүктелді!'),
  );
  final downloadingSnackBar = SnackBar(
    content: Text('Жүктелуде...'),
  );

  // @source: https://stackoverflow.com/questions/53004218/flutter-save-a-network-mp3-file-to-local-directory
  Future<dynamic> downloadFile(String url, filename) async {
    File file = new File(filename);
    var request = await http.get(url,);
    var bytes = request.bodyBytes;//close();
    await file.writeAsBytes(bytes);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _searchMusicController.addListener(() => widget.onTextChanged != null ? widget.onTextChanged(_searchMusicController.text) : null);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#121212'),
      appBar: AppBar(
        title: Text(
          'WidgetX Музыка Ойнатқышы',
          style: TextStyle(
            color: Colors.white70
          ),
        ),
        backgroundColor: HexColor("#121212"),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _searchMusicController,
            decoration: InputDecoration(
              hintText: 'Іздеу',
              hintStyle: TextStyle(
                color: Colors.green[200]
              ),
              filled: true,
              fillColor: Colors.white10,
              suffix: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.purple[200],
                  ),
                  onPressed: () {
                    // clear query text
                    WidgetsBinding.instance.addPostFrameCallback((_) => _searchMusicController.clear());
                  }
              ),
              contentPadding: EdgeInsets.only(left: 30.0, right: 10.0),
            ),
            cursorColor: Colors.greenAccent,
            onSubmitted: (query) {
              String builtUrl = returnBuildUrl(query).toString();
              fetchSongs(builtUrl).then((val) => setState(() {
                if (val[1].length > 0) {
                  songsNamesList = val[1];
                  songsArtistsList = val[2];
                  songsLinksList = val[4];
                  songImagesList = val[0];
                  songsDurationsList = val[3];
                } else {
                  songsNamesList = ['Іздегеніңіз Табылмады'];
                  songsArtistsList = ['Басқаша іздеп көріңіз'];
                  songsLinksList = [''];
                  songsDurationsList = [''];
                  songImagesList = ['https://png.icons8.com/windows/1600/0063B1/nothing-found'];
                }
              }));
            },
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(songImagesList[index]),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        songsNamesList[index],
                        style: listTileTextStyle,
                      ),
                      Text(
                        songsDurationsList[index],
                        style: listTileTextStyle,
                      ),
                    ],
                  ),
                  subtitle: Text(
                    songsArtistsList[index],
                    style: TextStyle(
                      color: Colors.green[400]
                    ),
                  ),
                  trailing:
                  IconButton(
                    icon: Icon(
                      Icons.file_download,
                      color: Colors.white70,
                    ),
                    onPressed: () async {
                      // download pressed
                      if (songsLinksList[index] != '') {
                        Scaffold.of(context).showSnackBar(downloadingSnackBar);
                        String filename =
                          songsNamesList[index] +
                          " - " +
                          songsArtistsList[index] +
                          " - " +
                          songsDurationsList[index];
//                      downloadMp3FromUrl(songsLinksList[index], filename);
                        var dir = await getExternalStorageDirectory();
                        filename = dir.path + "/" + filename + ".mp3";
                        downloadFile(songsLinksList[index], filename)
                            .whenComplete(() {
                          Scaffold.of(context).showSnackBar(downloadSuccessfulSnackBar);
                        });
                      }
                    },
                  ),
                  onTap: () {},
                );
              },
              itemCount: songsNamesList.length,
            ),
          ),
        ],
      ),
    );
  }
}
