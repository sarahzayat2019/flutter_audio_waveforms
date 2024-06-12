import 'package:audioplayers/audioplayers.dart';
import 'package:example/load_audio_data.dart';
import 'package:example/waveforms_dashboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Audio Waveforms',
      home: WaveformsDashboard(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Duration maxDuration;
  late Duration elapsedDuration;
  late AudioPlayer audioPlayer;
  late List<double> samples;
  late int totalSamples;

  late List<String> audioData;

  List<List<String>> audioDataList = [
    [
      'assets/dm.json',
      'dance_monkey.mp3',
    ],
    [
      'assets/soy.json',
      'shape_of_you.mp3',
    ],
    [
      'assets/sp.json',
      'surface_pressure.mp3',
    ],
  ];

  Future<void> parseData() async {
    final json = await rootBundle.loadString(audioData[0]);
    Map<String, dynamic> audioDataMap = {
      "json": json,
      "totalSamples": totalSamples,
    };
    final samplesData = await compute(loadparseJson, audioDataMap);
    await audioPlayer.audioCache.load(audioData[1]);
    // await audioPlayer.audioCache(audioData[1]);
    // maxDuration in milliseconds
    await Future.delayed(const Duration(milliseconds: 200));

        await audioPlayer.getDuration().then((value) =>
        maxDuration = value ?? Duration.zero);

    setState(() {
      samples = samplesData["samples"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Change this value to number of audio samples you want.
    // Values between 256 and 1024 are good for showing [RectangleWaveform] and [SquigglyWaveform]
    // While the values above them are good for showing [PolygonWaveform]
    totalSamples = 1000;
    audioData = audioDataList[0];
    audioPlayer = AudioPlayer();

    samples = [];
    maxDuration = const Duration(milliseconds: 1000);
    elapsedDuration = const Duration();
    parseData();
    audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        elapsedDuration = maxDuration;
      });
    });
    audioPlayer.onPositionChanged
        .listen((Duration timeElapsed) {
      setState(() {
        elapsedDuration = timeElapsed;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(
      height: 30,
      width: 30,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Flutter Audio Waveforms'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PolygonWaveform(
            maxDuration: maxDuration,
            elapsedDuration: elapsedDuration,
            samples: samples,
            height: 300,
            width: MediaQuery.of(context).size.width,
          ),
          sizedBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  audioPlayer.pause();
                },
                child: const Icon(
                  Icons.pause,
                ),
              ),
              sizedBox,
              ElevatedButton(
                onPressed: () {
                  audioPlayer.resume();
                },
                child: const Icon(Icons.play_arrow),
              ),
              sizedBox,
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    audioPlayer
                        .seek(const Duration(milliseconds: 0));
                  });
                },
                child: const Icon(Icons.replay_outlined),
              ),
            ],
          )
        ],
      ),
    );
  }
}
