import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'ChatMessage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TecnoExpress',
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
  List<ChatMessage> _messages = [];

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
    await _speechToText.listen(localeId: 'es_ES', onResult: _onSpeechResult);
  }

  void _onSpeechResult(result) async {
    setState(() {
      _wordsSpoken = result.recognizedWords;
    });

    if (_wordsSpoken.isNotEmpty) {
      _sendMessageToDialogFlow(_wordsSpoken);
    }
  }

  void _sendMessageToDialogFlow(String message) async {
    DetectIntentResponse response = await _dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: message)),
    );

    if (response.message != null) {
      String responseText = response.message!.text!.text!.first;
      setState(() {
        _messages.add(ChatMessage(responseText, false));
      });
      _speakMessage(responseText);
    }
  }

  void _speakMessage(String message) async {
    await _flutterTts.setLanguage("es-MX");
    await _flutterTts.speak(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TecnoExpress'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageScreen(messages: _messages),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startListening,
        child: const Icon(
          Icons.mic,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
