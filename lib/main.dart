import 'package:flutter/material.dart';
import 'package:newtest/widgets/feeling_textfield.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:math';
import 'dart:ui';

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

  List<Widget> topBanners = [
    Text(
      'Pressure',
      style: TextStyle(color: Colors.white70, fontSize: 18),
    ),
    SizedBox(
      width: 40,
    ),
    Text(
      'Sleep',
      style: TextStyle(color: Colors.white70, fontSize: 18),
    ),
    SizedBox(
      width: 40,
    ),
    Text(
      'Anxiety',
      style: TextStyle(color: Colors.white70, fontSize: 18),
    ),
    SizedBox(
      width: 40,
    ),
    Text(
      'Productivity',
      style: TextStyle(color: Colors.white70, fontSize: 18),
    ),
  ].toList();
  TextEditingController feelingController = TextEditingController();

  Widget backgroundColorContainer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Theme.of(context).primaryColorDark, Colors.black])),
    );
  }

  late AssetsAudioPlayer _assetsAudioPlayer;
  final List<Audio> myAudio = [
    Audio.network('assets/assets/sounds/puddle.mp3')
  ];

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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            backgroundColorContainer(context),
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
                        Column(
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PlayerBuilder.isPlaying(
                                player: _assetsAudioPlayer,
                                builder: (ctx, isPlaying) {
                                  return IconButton(
                                      onPressed: () {
                                        _assetsAudioPlayer.playOrPause();
                                      },
                                      icon: isPlaying
                                          ? Icon(
                                              Icons.pause_circle_filled,
                                            )
                                          : Icon(
                                              Icons.play_circle_fill,
                                              size: 50,
                                            ));
                                }),
                            SizedBox(
                              width: 20,
                            ),
                            IconButton(
                                onPressed: () => _playAnimation(),
                                icon: Icon(
                                  Icons.stop_circle,
                                  size: 50,
                                )),
                          ]),
                    ]),
              ),
            ),
            AnimatedBuilder(
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
            ),
            Positioned(
                left: (MediaQuery.of(context).size.width - 300) / 2,
                bottom: 25,
                child: FeelingTextField()),
          ],
        ),
      ),
    );
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
