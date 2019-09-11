import 'package:flutter/material.dart';
import 'package:flutterkaraoke/model_song.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './model_song.dart';
import './appbar_menu.dart';
import './menu_search.dart';
import './menu_album.dart';
import './play.dart';
import './play_control.dart';
import './play_karaoke.dart';
import './score_board.dart';
import './score_replay.dart';
import './score_goToOther.dart';

class Manager extends StatefulWidget {
  final String startingMenu;

  Manager({this.startingMenu = 'Default Value'});

  @override
  State<StatefulWidget> createState() {
    return _Manager();
  }
}

class _Manager extends State<Manager> {
  List<String> _play = [];
  List<ModelSong> _allSongs = [];
  ModelSong _selectedSong = ModelSong();
  bool _isUpload = false;
  bool _isMenu = false;
  bool _isPlay = false;
  bool _isScore = false;

  @override
  void initState() {
    super.initState();
    _isMenu = true;
    _getAllSongs();
  }

  Future<void> _getAllSongs() async {
    const url = 'https://flutterkaraoke.firebaseio.com/songs.json';
    http.get(url).then((response) {
      Map<String, dynamic> mappedBody = json.decode(response.body);
      List<dynamic> dynamicList = mappedBody.values.toList();
      List<ModelSong> modelSongList = [];
      for (int i = 0; i < dynamicList.length; i++) {
        modelSongList.add(ModelSong(
            title: dynamicList[i]["title"],
            artist: dynamicList[i]["artist"],
            downloadURL: dynamicList[i]["downloadURL"],
            image: dynamicList[i]["image"],
            score: dynamicList[i]["score"],
            lyrics: dynamicList[i]["lyrics"],
            isFavorite: dynamicList[i]["isFavorite"]));
      }
      setState(() {
        _allSongs = modelSongList;
      });
    });
  }

  void _addPlay(String play) {
    setState(() {
      _play.add(play);
    });
  }

  void _changeUpload(bool isUpload) {
    setState(() {
      _isUpload = isUpload;
    });
  }

  void _changeMenu(bool isMenu) {
    setState(() {
      _isMenu = isMenu;
    });
  }

  void _changePlay(bool isPlay) {
    setState(() {
      _isPlay = isPlay;
    });
  }

  void _changeScore(bool isScore) {
    setState(() {
      _isScore = isScore;
    });
  }

  void _setSelectedSong(ModelSong song) {
    setState(() {
      _selectedSong = song;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(title: Text('Karaoke Mania'), actions: [
          AppBarMenu(_changeUpload, _changeMenu),
        ]),
        Visibility(
          visible: _isMenu,
          child: Column(children: [
            MenuSearch(),
            MenuAlbum(_changeMenu, _changePlay, _allSongs, _setSelectedSong),
          ]),
        ),
        Visibility(
          visible: _isPlay,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                child: PlayControl(_addPlay, _changePlay, _changeScore),
              ),
              Play(_play),
              PlayKaraoke(_selectedSong),
            ],
          ),
        ),
        Visibility(
          visible: _isScore,
          child: Column(
            children: [
              ScoreBoard(),
              ScoreReplay(),
              ScoreGoToOther(_changeMenu, _changePlay, _changeScore),
            ],
          ),
        ),
      ],
    );
  }
}
