import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meetapp/server/controller/controller.dart';
import 'package:sdp_transform/sdp_transform.dart';

class WebRtc {
  bool offer = false;

  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
      {
        "url": 'turn:192.158.29.39:3478?transport=udp',
        "credential": 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
        "username": '28224511:1379330808'
      }
    ]
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true, //for video call
    },
    "optional": [],
  };

  Future<void> createWebRtcConnection(
    var response,
    // Map<String, dynamic> offersession,
    // String existingClientConnectionIdAtserver,
    Controller controller,
    String connectionIdAtServer, //for new client connection only
  ) async {
    int index = controller.appStates.connections.value.indexWhere(
        (element) => element.connectionIdAtServer == connectionIdAtServer);

    late String connectionType = response['connectionType'];

    controller.appStates.connections.value[index].pc =
        await createPeerConnection(configuration, offerSdpConstraints);
    Map<String, dynamic> session = response['offerSdp'];
    //print(session);
    //
    //Do something depending on connection type
    if (connectionType == 'secondary') {
      //set Remote description before addtrack is set if you want to send stream to others.
      String sdp = write(session, null);
      RTCSessionDescription description1 = RTCSessionDescription(sdp, 'offer');
      await controller.appStates.connections.value[index].pc!
          .setRemoteDescription(description1);
      //Find the required client index
      int clientIndex = controller.appStates.clientList.value.indexWhere(
          (element) =>
              element.connectionIdAtServer == response['connectionIdAtServer']);
      print('Secondary Connection creating at Sever');
      // controller.appStates.clientList.value[clientIndex].clientStream!
      //     .getTracks()
      //     .forEach((track) async {
      //   await controller.appStates.connections.value[index].pc!.addTrack(track,
      //       controller.appStates.clientList.value[clientIndex].clientStream!);
      // });

      //Added New for Test
      // await controller.appStates.connections.value[index].pc!.addStream(
      //     controller.appStates.clientList.value[clientIndex].clientStream!);
    } else {
      //If connection type primary, the following code will be executed
      // controller.appStates.connections.value[index].pc!.onTrack = (track) {
      //   print("Track is Received $track");
      //   //Add the sender stream to clientList
      //   int clientIndex = controller.appStates.clientList.value.indexWhere(
      //       (element) =>
      //           element.connectionIdAtServer ==
      //           controller
      //               .appStates.connections.value[index].connectionIdAtServer);

      //   controller.appStates.clientList.value[clientIndex].clientStream =
      //       track.streams[0];
      // };

      //Aded New for TEST
      // controller.appStates.connections.value[index].pc!.onAddStream = (stream) {
      //   print("Track is Received $stream");
      //   //Add the sender stream to clientList
      //   int clientIndex = controller.appStates.clientList.value.indexWhere(
      //       (element) =>
      //           element.connectionIdAtServer ==
      //           controller
      //               .appStates.connections.value[index].connectionIdAtServer);

      //   controller.appStates.clientList.value[clientIndex].clientStream =
      //       stream;
      // };

      //set Remote description after onTrack is set, if you want to get stream from others
      String sdp = write(session, null);
      RTCSessionDescription description1 = RTCSessionDescription(sdp, 'offer');
      await controller.appStates.connections.value[index].pc!
          .setRemoteDescription(description1);
    }
    //Add track to list
    // controller.appStates.connections.value[index].pc!.onTrack = (track) {
    //   print("Track is Received From Client by Ontrack event");
    //   //Add the sender stream to clientList
    //   int clientIndex = controller.appStates.clientList.value.indexWhere(
    //       (element) =>
    //           element.connectionIdAtServer ==
    //           controller
    //               .appStates.connections.value[index].connectionIdAtServer);

    //   controller.appStates.clientList.value[clientIndex].clientStream =
    //       track.streams[0];
    // };

    //create answer
    RTCSessionDescription description2 =
        await controller.appStates.connections.value[index].pc!.createAnswer({
      'offerToReceiveAudio':
          1, //May be unneccessary in this case, server not sending own stream
      'offerToReceiveVideo': 1
    });

    //set Local Description and send answerSdp to Receiver
    Map<String, dynamic> answerSession = parse(description2.sdp.toString());
    controller.appStates.connections.value[index].pc!
        .setLocalDescription(description2);
    controller.webSocket.socket.emit(
      "answer",
      {
        "session": answerSession,
        "receiverId": controller.appStates.connections.value[index].receiverId,
        "receiverSocketId":
            controller.appStates.connections.value[index].receiverSocketId,
        "connectionIdAtServer":
            controller.appStates.connections.value[index].connectionIdAtServer,
        "connectionIdAtClient":
            controller.appStates.connections.value[index].connectionIdAtClient,
        "responseType": 'answer',
        "connectionType":
            controller.appStates.connections.value[index].connectionType,
      },
    );

    //send Ice Candidate to Receiver
    controller.appStates.connections.value[index].pc!.onIceCandidate = (e) {
      print("ICE Candidate is Finding");
      //Transmitting candidate data from answerer to caller
      if (e.candidate != null) {
        controller.webSocket.socket.emit("serverIceCandidate", {
          "candidate": {
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          },
          "receiverId":
              controller.appStates.connections.value[index].receiverId,
          "receiverSocketId":
              controller.appStates.connections.value[index].receiverSocketId,
          "connectionIdAtServer": controller
              .appStates.connections.value[index].connectionIdAtServer,
          "connectionIdAtClient": controller
              .appStates.connections.value[index].connectionIdAtClient,
          "responseType": 'iceCandidate',
        });
      }
    };

    //Show ICE Connection State
    controller.appStates.connections.value[index].pc!.onIceConnectionState =
        (state) {
      print(state);
    };

    //Send all clients to the new client
    controller.appStates.connections.value[index].pc!.onConnectionState =
        (state) {
      //Show WebRTC connection Status
      print(state);
      //print the received stream
      // print(
      //     "Received Stream is ${controller.appStates.clientList.value[0].clientStream!.id}");
      //Remember: OnConnectionState must be placed first then other condition
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected &&
          connectionType == 'primary') {
        //
        //Show all streams in console
        try {
          for (var i = 0;
              i < controller.appStates.clientList.value.length;
              i++) {
            print(
                "Index $i : Track Id is : ${controller.appStates.clientList.value[i].clientStream!.id}");
            //print("here is error point may be");
          }
        } catch (e) {
          print(e);
        }
        //
        //
        //Send all clients to the new client
        int clientIndex = controller.appStates.clientList.value.indexWhere(
            (element) =>
                element.connectionIdAtServer ==
                controller
                    .appStates.connections.value[index].connectionIdAtServer);
        List<Map<String, dynamic>> clientList = [];
        for (var element in controller.appStates.clientList.value) {
          clientList.add({
            'connectionIdAtServer': element.connectionIdAtServer,
            'clientId': element.clientId,
            'clientName': element.clientName,
            'clientRole': element.clientRole,
          });
        }

        print('All Client is Sending');

        controller.webSocket.socket.emit("allClients", {
          'clientList': clientList,
          'responseType': 'clientList',
          'receiverId': controller.appStates.clientList.value[clientIndex]
              .clientId, //the Id will receive the list
          'receiverSocketId': controller.appStates.clientList.value[clientIndex]
              .clientSocketId, //the Id will receive the list
        });

        //send new client info to all
        controller.webSocket.socket.emit("newClient", {
          "connectionIdAtServer": controller
              .appStates.clientList.value[clientIndex].connectionIdAtServer,
          "clientId":
              controller.appStates.clientList.value[clientIndex].clientId,
          "clientName":
              controller.appStates.clientList.value[clientIndex].clientName,
          "clientRole":
              controller.appStates.clientList.value[clientIndex].clientRole,
        });

        //Refresh Client View in Dashboard
        controller.appStates.refresh.value =
            !controller.appStates.refresh.value;
        print("Refreshing client view list");
      }

      //find and Remove disconnected receiver
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected &&
          connectionType == 'primary') {
        String disconnectedClientId =
            controller.appStates.connections.value[index].receiverId!;
        for (var element in controller.appStates.connections.value) {
          if (element.receiverId ==
                  disconnectedClientId || // প্রতিটি ক্লায়েন্ট একবার রিসিভার এর ভূমিকায় এবং অসংখ্য বার সেন্ডার এর ভূমিকায় থাকে।
              element.senderId == disconnectedClientId) {
            //close all server side connections for disconnected receiverId
            element.pc!.close();
            //remove resources from connectionlist
            controller.appStates.connections.value.remove(element);
            //Remove resources from client List
            for (var item in controller.appStates.clientList.value) {
              if (item.clientId == element.receiverId) {
                controller.appStates.clientList.value.remove(item);
                //refresh server list view
                controller.appStates.refresh.value =
                    !controller.appStates.refresh.value;
              }
            }
          }
        }

        //Notify all existing clients to close and remove the disconnected receiver from their connection list
        controller.webSocket.socket.emit("userDisconnected", {
          'disconnectedReceiverId': disconnectedClientId,
        });
      }
    };

    //Notify all client if a client disconnected from WebRTC server

    // controller.appStates.connections.value[index].pc!.onConnectionState =
    //     (state) {
    //   if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected &&
    //       connectionType == 'primary') {
    //     //find disconnected receiverId
    //     String disconnectedClientId =
    //         controller.appStates.connections.value[index].receiverId!;
    //     for (var element in controller.appStates.connections.value) {
    //       if (element.receiverId == disconnectedClientId ||
    //           element.senderId == disconnectedClientId) {
    //         //close all server side connections for disconnected receiverId
    //         element.pc!.close();
    //         //remove resources from connectionlist
    //         controller.appStates.connections.value.remove(element);
    //         //Remove resources from client List
    //         for (var item in controller.appStates.clientList.value) {
    //           if (item.clientId == element.receiverId) {
    //             controller.appStates.clientList.value.remove(item);
    //             //refresh server list view
    //             controller.appStates.refresh.value =
    //                 !controller.appStates.refresh.value;
    //           }
    //         }
    //       }
    //     }
    //     //Notify all existing clients to close and remove the disconnected receiver from their connection list
    //     controller.webSocket.socket.emit("userDisconnected", {
    //       'disconnectedReceiverId': disconnectedClientId,
    //     });
    //   }
    // };
  }
}
