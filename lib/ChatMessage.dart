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

class MessageScreen extends StatefulWidget {
  final List<ChatMessage> messages;

  const MessageScreen({Key? key, required this.messages}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didUpdateWidget(MessageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(10),
          alignment: widget.messages[index].isUserMessage
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: widget.messages[index].isUserMessage
                  ? Colors.grey.shade800
                  : Colors.grey.shade900,
            ),
            constraints: BoxConstraints(maxWidth: w * 2 / 3),
            child: _buildContent(widget.messages[index]),
          ),
        );
      },
    );
  }

  Widget _buildContent(ChatMessage message) {
    if (message.contentType == ContentType.Image) {
      return Image.network(
        message.content,
        fit: BoxFit.cover,
      );
    } else {
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
