import 'dart:typed_data';

class MessageConstructor {
  String id;
  String content;
  String date;
  String subject;
  List<Uint8List> attachmentpayload;
  String from;
  String threadId;
  String MsgID;
  
  MessageConstructor({this.id, this.content, this.date, this.subject, this.attachmentpayload,this.from,this.threadId,this.MsgID});
}