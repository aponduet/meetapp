import 'package:flutter_webrtc/flutter_webrtc.dart';

class ConnectionInfo {
  String? receiverName;
  String? senderName;
  String? receiverId;
  String? receiverSocketId;
  String? senderId;
  String? receiverRole;
  String? senderRole;
  String? connectionIdAtServer;
  String? connectionIdAtClient;
  String? connectionType;
  RTCPeerConnection? pc;
  MediaStream? receiverStream;
  MediaStream? senderStream;

  ConnectionInfo({
    this.receiverName,
    this.senderName,
    this.receiverId,
    this.receiverSocketId,
    this.senderId,
    this.receiverRole,
    this.senderRole,
    this.connectionIdAtServer,
    this.connectionIdAtClient,
    this.connectionType,
    this.pc,
    this.receiverStream,
    this.senderStream,
  });
}
