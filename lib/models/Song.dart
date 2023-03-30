import 'package:flutter/material.dart';
import 'package:newtest/main.dart';

class Song {
  Genre genre;
  String title;
  Style style;
  double duration;
  Song(this.genre, this.title, this.style, this.duration);
}

enum Style {
  Bass,
  Music,
  Disco,
  DrumAndBass,
  Dubstep,
  EDM,
  Jungle,
  Hardcore,
  House
}
