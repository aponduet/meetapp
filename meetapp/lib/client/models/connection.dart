import 'package:flutter_webrtc/flutter_webrtc.dart';

//jsonDecode() : jsonString to Map<String,dynamic>
//jsonEncode() : Object to JsonString
//toJson() : Object to Map<String,dynamic>
//fromJson() : Map to Object
class Connection {
  String? senderId;
  String? senderSocketId;
  String? senderName;
  String? senderRole;
  String? connectionIdAtServer;
  String? connectionIdAtClient;
  RTCPeerConnection? pc;
  RTCVideoRenderer? renderer;
  Connection({
    this.senderId,
    this.senderSocketId,
    this.senderName,
    this.senderRole,
    this.connectionIdAtServer,
    this.connectionIdAtClient,
    this.pc,
    this.renderer,
  });
}
