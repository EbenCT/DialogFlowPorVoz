import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'productos.dart';
import 'ChatMessage.dart';
import 'tarjeta.dart';

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
  String productName = "";
  String productPrice = "";
  String carritoProd="";
  int cantProducto =0;
  int prePorCant=0;
TarjetaCredito miTarjeta = TarjetaCredito(
  nombrePropietario: 'Usuario1',
  numeroTarjeta: '1111-2222-3333-4444',
  fechaVencimiento: '99/9999',
  codigoSeguridad: '999',
);
Color _micButtonColor = Colors.red;


  
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
      // Cambiar el color del botón a verde cuando se active el micrófono
  setState(() {
    _micButtonColor =Colors.green;
  });
  }

void _stopListening() async {
  await _speechToText.stop();
  
  // Cambiar el color del botón a rojo cuando se desactive el micrófono
  setState(() {
    _micButtonColor = Colors.red;
  });
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
  _stopListening();
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
      if (responseText.toLowerCase().contains("addcarrito")) {
        _processAddToCart(responseText);
      } else if (responseText.toLowerCase().contains("dellcarrito")) {
        _processDeleteFromCart(responseText);
      } else if (responseText.toLowerCase().contains("veriftarjeta")) {
        if (miTarjeta.estaVacia()){
          String msg="tarjeta-no-en-sistema";
          _sendMessageToDialogFlow(msg);
        }else{
          String msg="Tarjeta-ya-registrada";
          _sendMessageToDialogFlow(msg);
        }
      } else if (responseText.toLowerCase().contains("vercarrito")) {
        _showCartContents(carritoProductos);
      } else {
        _speakMessage(responseText); // Reproduce el texto en voz
        setState(() {
          _messages.add(ChatMessage(responseText, ContentType.Text, false)); // Agrega la respuesta de DialogFlow como un nuevo mensaje
        });
      }
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
          productName = content[1]['title'];
          productPrice = content[1]['subtitle'];

          // Construye el mensaje combinando el nombre y el precio con un salto de línea
          String productMessage = '$productName\nPrecio: $productPrice Bs.\n\nPuede decir "añadir al carrito", o decir "siguiente" para ver mas productos';

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

void _processDeleteFromCart(String message) {
  // Encuentra el nombre del producto en el mensaje
  String productName = message.substring(message.indexOf("dellcarrito") + 12).trim();
  
  // Verifica si el producto está en el carrito antes de intentar eliminarlo
  bool productExistsInCart = carritoProductos.any((producto) => producto.nombre == productName);
  
  if (productExistsInCart) {
    // Elimina el producto del carrito
    Producto.eliminarDelCarritoPorNombre(productName);
    // Muestra el carrito actualizado
    _showCartContents(carritoProductos);
  } else {
    // Si el producto no se encuentra en el carrito, muestra un mensaje
    String errorMessage = 'No se encontró el producto "$productName" en el carrito.';
    print("no se elimino $productName");
    _speakMessage(errorMessage);
    setState(() {
      _messages.add(ChatMessage(errorMessage, ContentType.Text, false));
    });
  }
}



void _processAddToCart(String message) {
  // Encuentra la cantidad en el mensaje
  RegExp quantityRegex = RegExp(r'\b(\d+)\b');
  Match? match = quantityRegex.firstMatch(message);
  if (match != null) {
    String quantity = match.group(0)!;
    // Llama a la función para guardar la cantidad
    _saveQuantityToCart(quantity);
  }
}

void _saveQuantityToCart(String quantity) async {
  cantProducto=int.parse(quantity);
  prePorCant = cantProducto * int.parse(productPrice);
  print("Cantidad: $cantProducto, Precio: $productPrice, Precio por cantidad: $prePorCant");
      // Crea un nuevo objeto Producto con los detalles del producto
  Producto nuevoProducto = Producto(productName, int.parse(productPrice), cantProducto);
  // Añade el nuevo producto al carrito
  carritoProductos.add(nuevoProducto);

  carritoProd=productName+" "+productPrice+" "+quantity;
  
  print(carritoProd);
  DetectIntentResponse response = await _dialogFlowtter.detectIntent(
    queryInput: QueryInput(text: TextInput(text: carritoProd)),
  );
  if (response.message!.text != null) {
      String responseText = response.message!.text!.text!.first;
      if (responseText.toLowerCase().contains("vercarrito")) {
        _showCartContents(carritoProductos);
        return;
        }
    }
}

void _showCartContents(List<Producto> carritoProductos) {
  // Construye el mensaje inicial indicando que se mostrará el contenido del carrito
  String message = 'Contenido del carrito:\n\n';
  
  // Itera sobre los productos en el carrito y añade la información de cada producto al mensaje
  for (var producto in carritoProductos) {
    message +=
        'Producto: ${producto.nombre}\nPrecio: ${producto.precio} Bs.\nCantidad: ${producto.cantidad}\n\n';
  }

  // Agrega el total a pagar al mensaje
  int total = calcularTotal();
  message += 'TOTAL A PAGAR: $total Bs.\n\n';

  // Agrega el texto adicional al final del mensaje
  message += 'Puede decir "ver mas productos" para seguir navegando o puede decir "pagar" para realizar la compra.';
  
  // Reproduce el mensaje en voz
  _speakMessage(message);
  
  // Agrega el mensaje a la lista de mensajes para mostrarlo en la interfaz de usuario
  setState(() {
    _messages.add(ChatMessage(message, ContentType.Text, false));
  });
}




void _processDialogFlowResponse(String responseText) {
  setState(() {
    _messages.add(ChatMessage(responseText, ContentType.Text, false));
  });
  _speakMessage(responseText); // Espera a que se complete la reproducción del mensaje de voz
  
}


  void _speakMessage(String message) async {
    await _flutterTts.setLanguage("es-MX");
    await _flutterTts.speak(message);

      // Espera hasta que la reproducción de voz termine antes de activar el micrófono
  await _flutterTts.awaitSpeakCompletion(true);

  // Activa el reconocimiento de voz después de que la reproducción de voz haya terminado
  _startListening();

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
        backgroundColor: _micButtonColor,
      ),
    );
  }
}
