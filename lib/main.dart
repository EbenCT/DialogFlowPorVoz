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

  if (!result.finalResult) {
    // Si no es el resultado final, aún se está hablando, espera un poco más.
    return;
  }

  // Espera un breve período de tiempo antes de enviar el mensaje
  //await Future.delayed(Duration(milliseconds: 200)); // Ajusta la duración según tus necesidades

  // Envía el mensaje a Dialogflow después de la pausa
  if (_wordsSpoken.isNotEmpty) {
    _sendMessageToDialogFlow(_wordsSpoken);
  }
}


void _sendMessageToDialogFlow(String message) async {
  setState(() {
    _messages.add(ChatMessage(message, ContentType.Text, true)); // Agrega el mensaje hablado como un mensaje del usuario
  });

  DetectIntentResponse response = await _dialogFlowtter.detectIntent(
    queryInput: QueryInput(text: TextInput(text: message)),
  );

  // Imprimir la respuesta JSON recibida de Dialogflow
  print(response.message?.payload);

  if (response.message != null) {
    // Si la respuesta contiene un mensaje de texto, habla el mensaje
    if (response.message!.text != null) {
      String responseText = response.message!.text!.text!.first;
      _speakMessage(responseText); // Reproduce el texto en voz
      setState(() {
        _messages.add(ChatMessage(responseText, ContentType.Text, false)); // Agrega la respuesta de DialogFlow como un nuevo mensaje
      });
    }

    // Si la respuesta contiene un payload (por ejemplo, un mensaje rico), muestra el contenido
    if (response.message!.payload != null) {
      List<dynamic> richContent = response.message!.payload!['richContent'];

      // Itera sobre el contenido rico para mostrar los productos
      richContent.forEach((content) {
        // Verifica si el contenido contiene una imagen, un título y un precio
        if (content is List<dynamic> && content.length >= 3) {
          // Obtén la URL de la imagen
          String imageUrl = content[0]['rawUrl'];
          // Obtén el título y el precio del producto
          String productName = content[1]['title'];
          String productPrice = content[1]['subtitle'];

          // Construye el mensaje combinando el nombre y el precio con un salto de línea
          String productMessage = '$productName\n$productPrice.\n\nPuede decir "comprar" para añadir al carrito, o decir "siguiente/anterior" para ver mas productos';

          // Muestra la imagen y el mensaje combinado en un solo mensaje
          setState(() {
            _messages.add(ChatMessage(imageUrl, ContentType.Image, false)); // Muestra la imagen
            //_messages.add(ChatMessage(productMessage, ContentType.Text, false)); // Muestra el nombre y el precio del producto
          });

          // Procesa el mensaje combinado
          _processDialogFlowResponse(productMessage);
        }
      });
    }
  }
}



void _processDialogFlowResponse(String responseText) {
  setState(() {
    _messages.add(ChatMessage(responseText, ContentType.Text, false));
  });
  _speakMessage(responseText);
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
