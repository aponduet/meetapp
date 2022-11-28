import 'package:flutter/material.dart';
import 'package:meetapp/server/controller/controller.dart';
import 'package:meetapp/server/view/clients_list.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ServerHome extends StatefulWidget {
  final String roomId;
  final String username = 'server';
  const ServerHome({Key? key, required this.roomId}) : super(key: key);
  @override
  ServerHomeState createState() => ServerHomeState();
}

class ServerHomeState extends State<ServerHome> {
  Controller controller = Controller();

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
    //print(widget.roomId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Server"),
        actions: [
          ElevatedButton(
            onPressed: (() {}),
            child: const Text('Connect'),
          ),
          const SizedBox(width: 20),
          //
          ElevatedButton(
            onPressed: () async {
              //Do something to show list of all connection
            },
            child: const Text('All Connections'),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        width: double.infinity,
        height: double.infinity,
        child: ValueListenableBuilder<bool>(
          valueListenable: controller.appStates.refresh,
          builder: (context, value, child) {
            return ClientsList(controller: controller);
          },
        ),
      ),
    );
    //);
  }
}
