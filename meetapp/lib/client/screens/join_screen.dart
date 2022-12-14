import 'package:flutter/material.dart';
import 'package:meetapp/client/screens/chat_screen.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({Key? key}) : super(key: key);

  @override
  JoinScreenState createState() => JoinScreenState();
}

class JoinScreenState extends State<JoinScreen> {
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Call App"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Join a room",
            style: TextStyle(fontSize: 28.0),
          ),
          const SizedBox(
            height: 20.0,
            width: double.infinity,
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            width: 500,
            child: TextField(
              controller: _roomController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Room Id",
                hintText: "Enter 4 digit room id (E.g.- 1234)",
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
            width: double.infinity,
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            width: 500,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Your Name",
                hintText: "Enter your name",
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
            width: double.infinity,
          ),
          SizedBox(
            width: 300,
            height: 50,
            child: ElevatedButton(
              child: const Text("Join"),
              onPressed: () async {
                if (_roomController.text.length == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          roomId: _roomController.text,
                          username: _nameController.text),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Error"),
                        content: const Text("Please enter a 4 digit room id"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Ok"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
