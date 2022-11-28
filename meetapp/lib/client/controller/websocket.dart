import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meetapp/client/controller/controller.dart';
import 'package:meetapp/client/models/connection.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocket {
  late IO.Socket socket;

  void initSocket(String roomId, String username, Controller controller) {
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
      Map<String, dynamic> userInfo = {
        //these information will go to server during first socket connection.
        'roomId': roomId,
      };
      //join a room and get serverId
      socket.emitWithAck("joinClient", userInfo, ack: (data) {
        // print("${data.serverId}");
        print(data['serverName']);
        //Register to connection list
        Connection newConnection = Connection(
          senderId: data['serverId'],
          senderName: data['serverName'],
          senderRole: data['serverRole'],
          senderSocketId: data['serverSocketId'],
        );

        controller.appStates.connections.value.add(newConnection);
        //Add socketId to connection list and states
        controller.appStates.receiverSocketId.value = socket.id!;
      });
    });
    //Reconnect with socket
    socket.onReconnect((data) => print('Server Re-connected with socket'));

    //Receive Answer from Server
    socket.on('answer', (response) async {
      if (response['responseType'] == 'answer') {
        print('Answer received from Server');
        //Add Remote description to PC
        int index = controller.appStates.connections.value.indexWhere(
            (element) =>
                element.connectionIdAtClient ==
                response['connectionIdAtClient']);

        //Add connectionIdAtServer using index value
        controller.appStates.connections.value[index].connectionIdAtServer =
            response['connectionIdAtServer'];
        print(
            'ConnectionIdAtServer is : ${controller.appStates.connections.value[index].connectionIdAtServer}');
        //Added for CallServer Javascript Only
        Map<String, dynamic> answerSession =
            parse(response["session"].toString());
        //Add Answer Sdp
        String sdp = write(answerSession, null);
        //print(sdp);

        RTCSessionDescription description =
            RTCSessionDescription(sdp, 'answer');
        await controller.appStates.connections.value[index].pc!
            .setRemoteDescription(description);
      }
    });

    //Receive ICE Candidates from Server
    socket.on('serverIceCandidate', (response) async {
      print(response);
      if (response['responseType'] == 'iceCandidate') {
        //Identify the index of responsible connection

        int index = controller.appStates.connections.value.indexWhere(
            (element) =>
                element.connectionIdAtClient ==
                response['connectionIdAtClient']);

        print("Candidate received from Server");
        RTCIceCandidate candidate = RTCIceCandidate(
            response['candidate']['candidate'],
            response['candidate']['sdpMid'],
            response['candidate']['sdpMlineIndex']);

        await controller.appStates.connections.value[index].pc!
            .addCandidate(candidate);
        controller.appStates.connections.value[index].pc!.onIceConnectionState =
            (state) {
          print('ICE connection State is : $state');
        };

        //refresh the video display
        controller.appStates.refresh.value =
            !controller.appStates.refresh.value;
      }
    });

    //Receive all Connected Clients list
    socket.on('allClients', (response) {
      // Add all clients to connection list
      if (response['responseType'] == 'clientList') {
        //List<Map<String, dynamic>> clientList = response['clientList'];
        List<dynamic> clientList = response['clientList'];
        //print(clientList);
        //Register to connection list
        for (var item in clientList) {
          if (item['clientId'] != controller.appStates.receiverId.value) {
            Connection newConnection = Connection(
              senderId: item['clientId'],
              senderName: item['clientName'],
              senderRole: item['clientRole'],
              connectionIdAtServer: item['connectionIdAtServer'],
            );
            controller.appStates.connections.value.add(newConnection);
          }
        }

        print(
            'Total Connections are : ${controller.appStates.connections.value.length}');

        //Generate Recursive Function for continuous connection making
        connectNewClient() {
          //Make Secondary Connection
          int currentIndex = controller.appStates.index.value;
          int newIndex = currentIndex + 1;
          if (newIndex < controller.appStates.connections.value.length) {
            controller.appStates.index.value = newIndex;
            print('New Secondary Connection is Creating');
            //Create new connection from existing clients
            controller.webRtcLocal.connectWebRtcServer(controller, newIndex);
            //continue creating connection with new client
            Timer(const Duration(milliseconds: 200), () => connectNewClient());
          }
        }

        //Make new connections
        connectNewClient();
      }
    });

    //New User Notification
    socket.on("newClient", (info) {
      //newUserInfo = {'userId' : '458745874455juelrony', 'username' : 'juel rony'}
      if (info['clientId'] != controller.appStates.receiverId.value) {
        print("New Client Added and Connection is creating...");
        Connection newConnectionInfo = Connection(
          senderId: info['clientId'],
          senderName: info['clientName'],
          senderRole: info['clientRole'],
          connectionIdAtServer: info['connectionIdAtServer'],
        );
        controller.appStates.connections.value.add(newConnectionInfo);
        //Make Secondary Connection
        int currentIndex = controller.appStates.index.value;
        int newIndex = currentIndex + 1;

        if (newIndex < controller.appStates.connections.value.length) {
          controller.appStates.index.value = newIndex;
          print('New Secondary Connection is Creating');
          //Create new connection from existing clients
          controller.webRtcLocal.connectWebRtcServer(controller, newIndex);
        }
      }
    });

    // //Remove disconnecte user
    socket.on("userDisconnected", (info) async {
      print("Disconnected User Info : $info");
      print("Disconnected Id at Server is : ${info['connectionIdAtServer']}");
      //disconnectedUserinfo = {'userId' : "54587488799juetrony"}
      //close all connection
      int index = controller.appStates.connections.value.indexWhere(
          (element) => element.senderId == info['disconnectedReceiverId']);
      print("Disconnected Index is: $index");
      await controller.appStates.connections.value[index].renderer!.dispose();
      await controller.appStates.connections.value[index].pc!.close();
      //Delete the disconnected item from connections list
      controller.appStates.connections.value.removeAt(index);
      //Re-arrange the connection Index at appStates
      controller.appStates.index.value = controller.appStates.index.value - 1;
      //Refresh the display
      controller.appStates.refresh.value = !controller.appStates.refresh.value;
    });

    socket.onConnectError((response) {
      print(response);
    });
  }
}
