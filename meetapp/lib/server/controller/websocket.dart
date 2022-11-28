import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meetapp/server/controller/controller.dart';
import 'package:meetapp/server/models/client_info.dart';
import 'package:meetapp/server/models/connection_info.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocket {
  late IO.Socket socket;
  void initSocket(String roomId, String username, Controller controller) {
    String serverId = "$roomId@@server";
    controller.appStates.serverid.value = serverId;
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    socket.on('connect', (_) {
      print('Connected id : ${socket.id}');
    });

    socket.onConnect((response) async {
      print('Socket Server Successfully connected');
      print("socket id is : ${socket.id}");

      //the Map data will be converted to Object data automaticaly in socket server
      Map<String, dynamic> serverInfo = {
        //these information will Send to Socket Server and Receiver End during first socket connection.
        'roomId': roomId,
        'name': 'Home Server',
        'serverId': serverId,
        'serverSocketId': socket.id,
        'role': 'server',
      };
      print("Room id is : $roomId");
      //join a room as server
      socket.emit("joinServer", serverInfo);
    });

    //Receive Offer from Client
    socket.on('offer', (response) {
      if (response['responseType'] == 'offer') {
        print("Offer Received From Client");
        //Generate New Connection ID
        String newConnectionId =
            "CIS@@${DateTime.now().millisecondsSinceEpoch}";

        if (response['connectionType'] == 'primary') {
          //Primary connection will receive answer sdp and list of connected other clients with server
          ClientInfo client = ClientInfo(
            clientId: response['receiverId'],
            clientSocketId: response['receiverSocketId'],
            clientName: response['receiverName'],
            clientRole: response['receiverRole'],
            connectionIdAtClient: response['connectionIdAtClient'],
            connectionIdAtServer: newConnectionId,
            // must be Same for Client list and Connection list.
          );
          //add client info to Client List
          controller.appStates.clientList.value.add(client);
          //Refresh Client View in Dashboard
          // controller.appStates.refresh.value =
          //     !controller.appStates.refresh.value;

          print(
              "Client List Item: ${controller.appStates.clientList.value.length}");
        }

        //Generate connectionList
        ConnectionInfo newConnectionInfo = ConnectionInfo(
          receiverName: response['receiverName'],
          senderName: response['senderName'],
          receiverId: response['receiverId'],
          receiverSocketId: response['receiverSocketId'],
          senderId: response['senderId'],
          connectionIdAtClient: response['connectionIdAtClient'],
          connectionIdAtServer: newConnectionId,
          connectionType: response['connectionType'],
        );
        //add new connection to ConnectionsList
        controller.appStates.connections.value.add(newConnectionInfo);

        //Create WebRTC connection with receiver
        controller.webRtc
            .createWebRtcConnection(response, controller, newConnectionId);
      }
    });

    //Receive ICE Candidate from Client
    //ice candidate needed only one end
    socket.on('clientIceCandidate', (response) async {
      if (response['responseType'] == 'iceCandidate') {
        print("ICE Candidate Received From Client");
        //Find the responsibele connection index

        int index = controller.appStates.connections.value.indexWhere(
            (element) =>
                element.connectionIdAtClient ==
                response['connectionIdAtClient']);

        dynamic candidate = RTCIceCandidate(
            response['candidate']['candidate'],
            response['candidate']['sdpMid'],
            response['candidate']['sdpMlineIndex']);
        //ice candidate needed only one end
        // await controller.appStates.connections.value[index].pc!
        //     .addCandidate(candidate);
      }
    });

    socket.onConnectError((response) {
      print(response);
    });
  }
}
