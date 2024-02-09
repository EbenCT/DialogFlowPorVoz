import 'package:flutter/material.dart';

// Enum para los diferentes tipos de contenido
enum ContentType {
  Text,
  Image,
}

class ChatMessage {
  final dynamic content;
  final ContentType contentType;
  final bool isUserMessage;

  ChatMessage(this.content, this.contentType, this.isUserMessage);
}

class MessageScreen extends StatelessWidget {
  final List<ChatMessage> messages;

  const MessageScreen({Key? key, required this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(10),
          alignment: messages[index].isUserMessage
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: messages[index].isUserMessage
                  ? Colors.grey.shade800
                  : Colors.grey.shade900,
            ),
            constraints: BoxConstraints(maxWidth: w * 2 / 3),
            child: _buildContent(messages[index]),
          ),
        );
      },
    );
  }

  // Método para construir el contenido del mensaje
  Widget _buildContent(ChatMessage message) {
    if (message.contentType == ContentType.Image) {
      // Si el contenido es una imagen, mostrarla
      return Image.network(
        message.content,
        fit: BoxFit.cover, // Ajusta la imagen al contenedor
      );
    } else {
      // Si el contenido es texto, mostrarlo
      return Text(
        message.content,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
    }
  }
}
