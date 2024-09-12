import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mango/chat/message_enum.dart';
import 'package:mango/chat/model/model_chat.dart';
import 'package:mango/chat/providers/chat_provider.dart';

class MessageInputFieldWidget extends StatefulWidget {
  final Chatmodel chatModel;  // chatModel 추가

  const MessageInputFieldWidget({Key? key, required this.chatModel}) : super(key: key);  // 생성자 수정

  @override
  _MessageInputFieldWidgetState createState() =>
      _MessageInputFieldWidgetState();
}

class _MessageInputFieldWidgetState extends State<MessageInputFieldWidget> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isExpanded = false; // 더보기 버튼이 눌렸는지 여부를 확인

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _sendTextMessage() async {
    try {
      final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);

      // 빈 메시지를 보내지 않도록 체크
      if (_textEditingController.text.isNotEmpty) {
        await chatNotifier.sendMessage(
          text: _textEditingController.text,
          messageType: MessageEnum.text,
          chatModel: widget.chatModel,  // chatModel을 사용하여 메시지 전송
        );
        _textEditingController.clear();
      } else {
        // 메시지가 없을 경우 경고
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메시지를 입력하세요.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
      await chatNotifier.sendMessage(
        file: File(image.path),
        messageType: MessageEnum.image,
        chatModel: widget.chatModel,  // 이미지 전송 시에도 chatModel 사용
      );
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: _toggleExpanded,
                child: Image.asset(
                  'assets/images/add.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: '채팅을 입력하세요.',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(5),
                ),
              ),
            ),
            Container(
              height: 55,
              width: 55,
              color: Colors.white,
              child: GestureDetector(
                onTap: _sendTextMessage,
                child: const Icon(
                  Icons.send,
                  color: Color(0xffffe396),
                ),
              ),
            ),
          ],
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isExpanded ? 100 : 0,
          child: Visibility(
            visible: _isExpanded,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Column(
                    children: [
                      Icon(Icons.camera_alt, color: Color(0xffF9C63D), size: 30),
                      Text('카메라', style: TextStyle(color: Color(0xffF9C63D))),
                    ],
                  ),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                IconButton(
                  icon: Column(
                    children: [
                      Icon(Icons.photo, color: Color(0xffF9C63D), size: 30),
                      Text('앨범', style: TextStyle(color: Color(0xffF9C63D))),
                    ],
                  ),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
