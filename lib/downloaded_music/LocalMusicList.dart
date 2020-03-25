import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart' show ProgressValue, SectionTextModel, SeekBar;


// source: https://stackoverflow.com/questions/57004220/how-to-get-all-mp3-files-from-internal-as-well-as-external-storage-in-flutter
Future<List<List<String>>> getSongs() async {
  var dir = await getExternalStorageDirectory();
//  String mp3Path = dir.path + "/";
  List<FileSystemEntity> _files;
//  List<FileSystemEntity> _songs = [];
  List<String> songsPaths = [];
  List<String> songsNames = [];
  List<String> songsArtists = [];
  List<String> songDurations = [];
  _files = dir.listSync(recursive: true, followLinks: false);
  for(FileSystemEntity entity in _files) {
    String path = entity.path;
    if(path.endsWith('.mp3')) {
      songsPaths.add(path);
      var songName = path
          .split("/")
          .last;
      songName = songName.split(".mp3")[0];
      var songSplittedNames = songName.split("-");
      songsNames.add(songSplittedNames[0].trimRight().trimLeft());
      songsArtists.add(songSplittedNames[1].trimRight().trimLeft());
      songDurations.add(songSplittedNames[2].trimRight().trimLeft() + ":" + songSplittedNames[3].trimRight().trimLeft());
    }
  }
  return [songsPaths, songsNames, songsArtists, songDurations];
}

// global variables
List<String> localSongsPaths;
List<String> localSongsNames;
List<String> localSongsArtists;
List<String> localSongDurations;
int _currentIndex;

AudioPlayer audioPlayer;
Duration positionOffline;
Duration durationOffline;

String durationOfflineString;
String positionOfflineString;

double posInt;

StreamSubscription _positionSubscription;
StreamSubscription _durationSubscription;
int _maxIndex;
bool isPlaying;

playLocal(audioPlayer, localFilePath) async {
  await audioPlayer.play(localFilePath, isLocal: true);
  isPlaying = true;
}

pauseLocal(audioPlayer) async {
  await audioPlayer.pause();
  isPlaying = false;
}

stopLocal(audioPlayer) async {
  await audioPlayer.stop();
}

seekLocal(audioPlayer, milliseconds) async {
  await audioPlayer.seek(Duration(milliseconds: milliseconds));
}

String getDurString(Duration dur) {
  var splittedStrings = dur.toString().split(":");
  return splittedStrings[1] + ":" + splittedStrings[2].split(".")[0];
}

String getPosString(Duration pos) {
  var splittedStrings = pos.toString().split(":");
  return splittedStrings[1] + ":" + splittedStrings[2].split(".")[0];
}

double posToInt(String pos, dur) {
  var posSplitted = pos.split(":");
  int posInt = int.parse(posSplitted[0]) * 60 + int.parse(posSplitted[1]);
  var durSplitted = dur.split(":");
  int durInt = int.parse(durSplitted[0]) * 60 + int.parse(durSplitted[1]);
  return posInt / durInt;
}

int progressToMilliseconds(progress) {
  var durSplitted = durationOfflineString.split(":");
  int durSeconds = int.parse(durSplitted[0]) * 60 + int.parse(durSplitted[1]);
  int durMilliseconds = durSeconds * 1000;
  return (durMilliseconds * progress).round();
}

void localMusicListMain() {
  // global variables
  localSongsPaths = [];
  localSongsNames = [''];
  localSongsArtists = [''];
  localSongDurations = [''];
  _currentIndex = 0;

  positionOfflineString = '00:00';
  durationOfflineString = '1:1';
  posInt = 0.0;

  isPlaying = false;

  audioPlayer = AudioPlayer();


  getSongs().then((val) {
    localSongsPaths = val[0];
    localSongsNames = val[1];
    localSongsArtists = val[2];
    localSongDurations = val[3];
    durationOfflineString = localSongDurations[_currentIndex];
    _maxIndex = localSongsNames.length - 1;
  });

  Timer.periodic(
      Duration(seconds: 1),
          (timer) {
        posInt = posToInt(positionOfflineString, durationOfflineString);
      });
}

class LocalMusicList extends StatefulWidget {
  @override
  _LocalMusicListState createState() => _LocalMusicListState();
}

class _LocalMusicListState extends State<LocalMusicList> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    audioPlayer.onPlayerCompletion.listen((event) {
      // onComplete
      if (_currentIndex == _maxIndex) {
        setState(() {
          _currentIndex = 0;
        });
      } else {
        setState(() {
          _currentIndex++;
        });
      }
      stopLocal(audioPlayer);
      playLocal(audioPlayer, localSongsPaths[_currentIndex]);
    });

    _durationSubscription = audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        durationOffline = d;
        durationOfflineString = getDurString(durationOffline);
      });
    });

    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((Duration  p) {
      setState(() {
        positionOffline = p;
        positionOfflineString = getPosString(positionOffline);
      });
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "WidgetX Музыка Ойнатқышы"
        ),
        backgroundColor: Colors.green,
      ),
      body: localSongsNames.isNotEmpty
          ? Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  leading: _currentIndex == index
                      ? Icon(Icons.arrow_forward_ios)
                      : Text(''),
                  title: Text(
                      localSongsNames[index]
                  ),
                  subtitle: Text(
                      localSongsArtists[index]
                  ),
                    trailing: Text(
                      localSongDurations[index]
                    ),
                  onTap: () {
                    setState(() {
                      if (_currentIndex != index) {
                        stopLocal(audioPlayer);
                        isPlaying = false;
                      }
                      _currentIndex = index;
                    });
                    isPlaying ? pauseLocal(audioPlayer) : playLocal(audioPlayer, localSongsPaths[_currentIndex]);
                  },
                );
              },
              itemCount: localSongsNames.length,
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.orange[400],
                border: Border.all(
                    color: Colors.blueAccent
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35.0),
                  topRight: Radius.circular(35.0),
                )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(
                    Icons.music_note
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        localSongsNames[_currentIndex]
                    ),
                    Text(
                      localSongsArtists[_currentIndex],
                      style: TextStyle(
                          color: Colors.black54
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                          Icons.skip_previous
                      ),
                      onPressed: () {
                        if(_currentIndex == 0) {
                          setState(() {
                            _currentIndex = _maxIndex;
                          });
                        } else {
                          setState(() {
                            _currentIndex--;
                          });
                          playLocal(audioPlayer, localSongsPaths[_currentIndex]);
                        }
                      },
                    ),
                    IconButton(
                      icon: isPlaying
                          ? Icon(Icons.pause)
                          : Icon(Icons.play_arrow),
                      onPressed: () {
                        isPlaying
                            ? pauseLocal(audioPlayer)
                            : playLocal(audioPlayer, localSongsPaths[_currentIndex]);
                        setState(() {
                          isPlaying = !isPlaying;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: () {
                        if(_currentIndex == _maxIndex) {
                          setState(() {
                            _currentIndex = 0;
                          });
                        } else {
                          setState(() {
                            _currentIndex++;
                          });
                        }
                        playLocal(audioPlayer, localSongsPaths[_currentIndex]);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
          Column(
            children: <Widget>[
              SeekBar(
                progresseight: 10,
                value: posInt*100,
                onValueChanged: (progressValue) {
                  seekLocal(audioPlayer, progressToMilliseconds(progressValue.progress));
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                    positionOfflineString + "/" + durationOfflineString
                ),
              ),
            ],
          )
        ],
      )
          : Container(
        child: Center(
          child: Text(
            '0 songs',
            style: TextStyle(
                fontSize: 24
            ),
          ),
        ),
      ),
    );
  }
}
