import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage(this.text, this.isUserMessage);
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
            child: Text(
              messages[index].text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
