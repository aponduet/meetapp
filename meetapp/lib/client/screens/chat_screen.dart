import 'package:flutter/material.dart';
import 'package:meetapp/client/controller/controller.dart';
import 'package:meetapp/client/view/control_button_bar.dart';
import 'package:meetapp/client/view/local_video_display.dart';
import 'package:meetapp/client/view/remote_video_grid.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String username;
  const ChatScreen({Key? key, required this.roomId, required this.username})
      : super(key: key);
  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  Controller controller = Controller();
  //bool refresshVideoList = true;
  bool isAudioEnabled = true;

  //final String socketId = "1011";

  //These are for manual testing without a heroku server

  @override
  dispose() {
    IO.Socket socket = controller.webSocket.socket;
    //To stop multiple calling websocket, use the following code.
    if (socket.disconnected) {
      socket.disconnect();
    }
    //socket.disconnect();
    super.dispose();
  }

  @override
  void initState() {
    controller.webSocket.initSocket(widget.roomId, widget.username, controller);
    setClientInfo();
    //print(widget.roomId);
    super.initState();
  }

  void setClientInfo() {
    String userId =
        "${DateTime.now().millisecondsSinceEpoch}_${(widget.username).replaceAll(" ", "")}";
    controller.appStates.receiverId.value = userId;
    controller.appStates.receiverName.value = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("groupchat"),
        actions: [
          ElevatedButton(
            onPressed: (() {
              if (!controller.appStates.isServerConnected.value) {
                //server will be connected when list is empty
                controller.webRtcLocal.connectWebRtcServer(controller, 0);
              }
            }),
            child: ValueListenableBuilder<bool>(
                valueListenable: controller.appStates.isServerConnected,
                builder: (context, isServerConnected, child) {
                  return isServerConnected
                      ? const Text('Connected')
                      : const Text('Connect');
                }),
          ),
          const SizedBox(width: 20),
          //
          ElevatedButton(
            onPressed: () async {},
            child: Text('Mic is ${isAudioEnabled == true ? "on" : "off"}'),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        width: double.infinity,
        height: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ValueListenableBuilder<int>(
                  valueListenable: controller.appStates.index,
                  builder: (context, index, child) {
                    return Stack(
                      children: [
                        LocalVideoDisplay(controller: controller),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: ControlButtonBar(controller: controller),
                          ),
                        )
                      ],
                    );
                  }),
            ),
            SizedBox(
              height: double.infinity,
              width: 300,
              child: ValueListenableBuilder<bool>(
                  valueListenable: controller.appStates.refresh,
                  builder: (context, value, child) {
                    return RemoteVideoGrid(
                      connections: controller.appStates.connections.value,
                      controller: controller,
                    );
                  }),
            ),
          ],
        ),
      ),
    );
    //);
  }
}
