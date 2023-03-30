import 'dart:html';
import 'package:flutter/material.dart';
import 'package:newtest/models/SongData.dart';
import 'package:newtest/widgets/custom_button.dart';
import 'package:newtest/widgets/feeling_textfield.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:math';
import 'dart:ui';
import 'models/Song.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

enum Genre { Pressure, Sleep, Anxiety, Productivity }

void main() {
  runApp(const MyApp());
}

class SineCurve extends Curve {
  const SineCurve({this.count = 3});

  final double count;

  // t = x
  @override
  double transformInternal(double t) {
    var val = sin(count * 2 * pi * t) * 0.5 + 0.5;
    // var val = sin(2 * pi * t);
    return val; //f(x)
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final linearTween = Tween<double>(begin: 0, end: 1);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyMusicApp(
        duration: Duration(seconds: 6),
        mainCurve: linearTween.chain(CurveTween(curve: const SineCurve())),
        size: 200,
        kindOfAnim: KindOfAnimation.repeat,
      ),
    );
  }
}

class MyMusicApp extends StatefulWidget {
  MyMusicApp(
      {required this.duration,
      required this.mainCurve,
      required this.size,
      this.compareCurve,
      required this.kindOfAnim});

  final Duration duration;
  final Animatable<double> mainCurve;
  final Animatable<double>? compareCurve;
  final double size;
  final KindOfAnimation kindOfAnim;

  @override
  State<MyMusicApp> createState() => _MyMusicAppState();
}

class _MyMusicAppState extends State<MyMusicApp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Duration get _duration => widget.duration;
  Animatable<double>? get _compareCurve => widget.compareCurve;
  KindOfAnimation get _kindOfAnim => widget.kindOfAnim;

  Animatable<double> get _mainCurve => widget.mainCurve;
  double get _size => widget.size;
  late Path _shadowPath;
  Path? _comparePath;

  TextEditingController feelingController = TextEditingController();

  late AssetsAudioPlayer _assetsAudioPlayer;
  final List<Audio> myAudio = [
    Audio.network('assets/assets/sounds/puddle.mp3')
  ];

  List<String> get genres {
    return Genre.values.map((e) => e.name).toList();
  }

  @override
  void initState() {
    super.initState();
    _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
    _assetsAudioPlayer.open(Playlist(audios: myAudio, startIndex: 0),
        autoStart: false);

    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    );

    _shadowPath = _buildGraph(_mainCurve);
    if (_compareCurve != null) {
      _comparePath = _buildGraph(_compareCurve!);
    }
  }

  Path _buildGraph(Animatable<double> animatable) {
    var val = 0.0;
    var path = Path();
    for (var t = 0.0; t <= 1; t += 0.01) {
      val = -animatable.transform(t) * _size;
      path.lineTo(t * _size, val);
    }
    return path;
  }

  void _playAnimation() {
    _controller.reset();
    if (_kindOfAnim == KindOfAnimation.forward) {
      _controller.forward();
    } else if (_kindOfAnim == KindOfAnimation.repeat) {
      _controller.repeat();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    var intervalValue = 0.0;
    var followPath = Path();

    _playAnimation();

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Stack(children: [
        singleScrollVC(context, intervalValue, followPath),
        myBanner(),
        Center(
          child: SizedBox(
            width: 300,
            child: DefaultTextStyle(
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 35,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 7.0,
                    color: Colors.white,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: AnimatedTextKit(
                repeatForever: true,
                animatedTexts: [
                  FlickerAnimatedText('Knowing what is happening',
                      speed: Duration(milliseconds: 4400)),
                  FlickerAnimatedText('while it is happening',
                      speed: Duration(milliseconds: 4400)),
                  FlickerAnimatedText("without preference",
                      speed: Duration(milliseconds: 4400)),
                  FlickerAnimatedText("is mindfulness!",
                      speed: Duration(milliseconds: 4400)),
                ],
                onTap: () {
                  print("Tap Event");
                },
              ),
            ),
          ),
        ),
        Positioned(
            left: (MediaQuery.of(context).size.width - 300) / 2,
            bottom: 25,
            child: Column(
              children: [
                controlPanel(),
                FeelingTextField(),
              ],
            ))
      ]),
    );
  }

  Container myBanner() {
    Song dropdownValue = pressureSongs.first;

    String? selectedValue;
    return Container(
      height: 50,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomDropdownButton2(
                hint: pressureSongs.first.genre.name,
                value: selectedValue,
                dropdownItems: pressureSongs.map((e) => e.title).toList(),
                onChanged: (value) {
                  selectedValue = value;
                }),
            SizedBox(
              width: 20,
            ),
            CustomDropdownButton2(
                hint: sleepSongs.first.genre.name,
                value: selectedValue,
                dropdownItems: sleepSongs.map((e) => e.title).toList(),
                onChanged: (value) {
                  selectedValue = value;
                }),
            SizedBox(
              width: 20,
            ),
            CustomDropdownButton2(
                hint: anxietySongs.first.genre.name,
                value: selectedValue,
                dropdownItems: anxietySongs.map((e) => e.title).toList(),
                onChanged: (value) {
                  selectedValue = value;
                }),
            SizedBox(
              width: 20,
            ),
            CustomDropdownButton2(
                hint: productivitySongs.first.genre.name,
                value: selectedValue,
                dropdownItems: productivitySongs.map((e) => e.title).toList(),
                onChanged: (value) {
                  selectedValue = value;
                }),
          ].toList()),
    );
  }

  DropdownButton<Song> myDropDownButton(Song dropdownValue) {
    return DropdownButton<Song>(
      value: dropdownValue,
      elevation: 16,
      style: const TextStyle(color: Colors.lightBlue),
      underline: null,
      hint: bannerText(dropdownValue.genre.name),
      onChanged: (Song? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: pressureSongs.map<DropdownMenuItem<Song>>((Song value) {
        return DropdownMenuItem<Song>(
          value: value,
          child: Text(value.title),
        );
      }).toList(),
    );
  }

  ClipRRect bannerText(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Colors.white24, Colors.white12],
                ),
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.lightBlue,
              padding: const EdgeInsets.all(16.0),
              textStyle: const TextStyle(fontSize: 15),
            ),
            onPressed: () {},
            child: Text(text),
          ),
        ],
      ),
    );
  }

  //tempSingleVc(context, intervalValue, followPath)

  LayoutBuilder singleScrollVC(
      BuildContext context, double intervalValue, Path followPath) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return ListView(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 300,
                    ),
                    Expanded(
                        // A flexible child that will grow to fit the viewport but
                        // still be at least as big as necessary to fit its contents.
                        child: Text(
                      '',
                      style: TextStyle(color: Colors.white),
                    )),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
  /*

Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: topBanners),
                    // const SizedBox(
                    //   height: 50,
                    // ),
                    Stack(alignment: Alignment.center, children: [
                      Container(
                        width: 100,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                            ),
                            Image.asset(
                              'assets/images/musicwave.png',
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white24,
                            ),
                            height: 190,
                            width: 190,
                            child: const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                'Disover',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ]),
            ),
          ),
          controlPanel(),
          Positioned(
              left: (MediaQuery.of(context).size.width - 300) / 2,
              bottom: 25,
              child: FeelingTextField()),
        ],
      ),
  */

  AnimatedBuilder animation(
      double intervalValue, Path followPath, BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        // rest the follow path when the controller is finished
        if (intervalValue >= _controller.value) {
          followPath.reset();
        }
        intervalValue = _controller.value;

        final val = _mainCurve.evaluate(_controller);
        followPath.lineTo(_controller.value * _size, -val * _size);

        return CustomPaint(
          painter: GraphPainter(
              shadowPath: _shadowPath,
              followPath: followPath,
              comparePath: _comparePath,
              currentPoint: Offset(
                _controller.value * _size,
                val * _size,
              ),
              graphSize: _size,
              screenSize: MediaQuery.of(context).size),
          child: Container(),
        );
      },
    );
  }

  Row controlPanel() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      PlayerBuilder.isPlaying(
          player: _assetsAudioPlayer,
          builder: (ctx, isPlaying) {
            return IconButton(
                iconSize: 50,
                onPressed: () {
                  _assetsAudioPlayer.playOrPause();
                },
                icon: isPlaying
                    ? Icon(
                        Icons.pause_circle_filled,
                        color: Colors.blue,
                      )
                    : Icon(
                        Icons.play_circle_fill,
                        color: Colors.blue,
                      ));
          }),
      SizedBox(
        width: 20,
      ),
      IconButton(
          iconSize: 50,
          onPressed: () => _assetsAudioPlayer.stop(),
          icon: Icon(
            Icons.stop_circle,
            color: Colors.blue,
          )),
    ]);
  }
}

class GraphPainter extends CustomPainter {
  const GraphPainter(
      {required this.currentPoint,
      required this.shadowPath,
      required this.followPath,
      this.comparePath,
      required this.graphSize,
      required this.screenSize});

  final Offset currentPoint;
  final Path shadowPath;
  final Path followPath;
  final Path? comparePath;
  final double graphSize;
  final Size screenSize;

  static final backgroundPaint = Paint()..color = Colors.transparent;
  static final currentPointPaint = Paint()..color = Colors.white;
  static final shadowPaint = Paint()
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  static final comparePaint = Paint()
    ..color = Colors.grey.shade500
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  static final followPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  static final borderPaint = Paint()
    ..color = Colors.transparent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    // _drawBackground(canvas, size);
    // canvas.translate(
    //     size.width / 2 - graphSize / 2, size.height / 2 - graphSize / 2);
    _drawBorder(canvas, size);
    canvas.translate(
        screenSize.width / 2 - graphSize / 2, screenSize.height / 2);
    if (comparePath != null) {
      canvas.drawPath(comparePath!, comparePaint);
    }
    canvas
      ..drawPath(shadowPath, shadowPaint)
      ..drawPath(followPath, followPaint)
      ..drawCircle(
          Offset(currentPoint.dx, -currentPoint.dy), 4, currentPointPaint);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
  }

  void _drawBorder(Canvas canvas, Size size) {
    canvas
      ..drawLine(const Offset(0, 0), Offset(0, graphSize), borderPaint)
      ..drawLine(
          Offset(0, graphSize), Offset(graphSize, graphSize), borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum KindOfAnimation {
  forward,
  repeat,
  repeatAndreverse,
}
