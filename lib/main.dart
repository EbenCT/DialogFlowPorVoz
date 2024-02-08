import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  late DialogFlowtter _dialogFlowtter;

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  @override
  void initState() {
    super.initState();
    initSpeech();
    initDialogFlow();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void initDialogFlow() async {
    _dialogFlowtter = await DialogFlowtter.fromFile();
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

void _onSpeechResult(result) async {
  setState(() {
    _wordsSpoken = result.recognizedWords;
    _confidenceLevel = result.confidence;
  });

  if (_confidenceLevel > 0) {
    _sendMessageToDialogFlow(_wordsSpoken);
  }
}


  void _sendMessageToDialogFlow(String message) async {
    DetectIntentResponse response = await _dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: message)),
    );

    if (response.message != null) {
      String responseText = response.message!.text!.text!.first;
      _speakMessage(responseText);
    }
  }

  void _speakMessage(String message) async {
    await _flutterTts.speak(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reparaciones Domiciliarias'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                _speechToText.isListening
                    ? "Escuchando..."
                    : _speechEnabled
                        ? "Presiona el micrófono para hablar "
                        : "Speech not available",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _wordsSpoken,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            if (_speechToText.isNotListening && _confidenceLevel > 0)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 100,
                ),
                child: Text(
                  "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _startListening,
            child: const Icon(
              Icons.mic,
              color: Colors.white,
            ),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
