import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meetapp/client/controller/controller.dart';
import 'package:sdp_transform/sdp_transform.dart';

class WebRtcLocal {
  bool offer = true;

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

  Future<void> connectWebRtcServer(Controller controller, int index) async {
    //Generate a connectionIdAtClient side
    controller.appStates.connections.value[index].connectionIdAtClient =
        "CIC@@${DateTime.now().millisecondsSinceEpoch}";
    //print("Create connection");
    controller.appStates.connections.value[index].renderer = RTCVideoRenderer();
    await controller.appStates.connections.value[index].renderer!.initialize();
    //Refresh the
    controller.appStates.connections.value[index].pc =
        await createPeerConnection(configuration, offerSdpConstraints);
    if (index == 0) {
      //Showing local Video
      final Map<String, dynamic> constraints = {
        'audio': true,
        'video': false,
        // 'video': {
        //   'facingMode': 'user',
        //}, //If you want to make video calling app.
      };

      MediaStream stream =
          await navigator.mediaDevices.getUserMedia(constraints);
      controller.appStates.connections.value[index].renderer!.srcObject =
          stream;
      // localRenderer.mirror = true;
      //Refresh local Renderer display
      controller.appStates.refresh.value = !controller.appStates.refresh.value;

      stream.getTracks().forEach((track) async {
        await controller.appStates.connections.value[index].pc!
            .addTrack(track, stream);
        print('Local Track is : $track');
      });

      // await controller.appStates.connections.value[index].pc!
      //     .addStream(stream); //added for test
    } else {
      controller.appStates.connections.value[index].pc!.onTrack = (track) {
        print("Reveived Track is : ${track.streams[0].id}");
        controller.appStates.connections.value[index].renderer!.srcObject =
            track.streams[0];
      };
      //Added for Test
      // controller.appStates.connections.value[index].pc!.onAddStream = (stream) {
      //   controller.appStates.connections.value[index].renderer!.srcObject =
      //       stream;
      // };
    }

    //Send ICE Candidate to Server
    controller.appStates.connections.value[index].pc!.onIceCandidate = (e) {
      print("ICE Candidate is Finding");
      //Transmitting candidate data from Receiver to Sender
      if (e.candidate != null) {
        controller.webSocket.socket.emit("clientIceCandidate", {
          "candidate": {
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          },
          "connectionIdAtServer": controller
              .appStates.connections.value[index].connectionIdAtServer,
          "connectionIdAtClient": controller
              .appStates.connections.value[index].connectionIdAtClient,
          "responseType": 'iceCandidate'
        });
      }
    };

    //Show WebRtc ICE connection status
    controller.appStates.connections.value[index].pc!.onIceConnectionState =
        (state) {
      print(state);
    };

    //Show WebRtc ICE connection status
    controller.appStates.connections.value[index].pc!.onConnectionState =
        (state) {
      print(state);
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected &&
          index == 0) {
        //change connect button to connected
        controller.appStates.isServerConnected.value = true;
      }
    };

    //Create Offer for new connection
    RTCSessionDescription description =
        await controller.appStates.connections.value[index].pc!.createOffer({
      'offerToReceiveAudio': 1,
      'offerToReceiveVideo': 1,
      //'iceRestart': true,
    });
    var offersession = parse(
        description.sdp.toString()); //parse comes from sdp_transform package
    String session = write(offersession, null); //for Node WebRTC
    controller.appStates.connections.value[index].pc!
        .setLocalDescription(description);
    controller.webSocket.socket.emit(
      "offer",
      {
        // "offerSdp": offersession, // For Dart WebRTC
        "offerSdp": session, //will be used at server remoteSDp
        "receiverId": controller.appStates.receiverId
            .value, // UserId must be unique and will be used to identify the client
        "receiverSocketId": controller.webSocket.socket.id,
        "receiverName": controller.appStates.receiverName.value,
        "connectionType": index == 0 ? 'primary' : 'secondary',
        "connectionIdAtClient":
            controller.appStates.connections.value[index].connectionIdAtClient,
        "connectionIdAtServer":
            controller.appStates.connections.value[index].connectionIdAtServer,
        'receiverRole': 'user',
        "responseType": 'offer',
      },
    );
  }
}
