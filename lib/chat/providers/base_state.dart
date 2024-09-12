import 'package:mango/chat/model/model_base.dart';
import 'package:mango/chat/model/model_message.dart';

abstract class BaseState {
  final BaseModel model;
  final List<ModelMessage> messageList;

  const BaseState({
    required this.model,
    required this.messageList,
});
}