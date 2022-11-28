import 'package:flutter_webrtc/flutter_webrtc.dart';

class ClientInfo {
  String? clientId;
  String? clientSocketId;
  String? clientName;
  String? clientRole;
  String?
      connectionIdAtServer; //indicate the position of client in connection list
  String?
      connectionIdAtClient; //indicate the position of client in connection list
  MediaStream? clientStream;

  ClientInfo({
    this.clientId,
    this.clientSocketId,
    this.clientName,
    this.clientRole,
    this.connectionIdAtServer,
    this.connectionIdAtClient,
    this.clientStream,
  });
}


//jsonDecode() : jsonString to Map<String,dynamic>
//jsonEncode() : Object to JsonString
//toJson() : Object to Map<String,dynamic>
//fromJson() : Map to Object
