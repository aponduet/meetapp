import 'package:flutter/material.dart';
import 'package:meetapp/server/controller/controller.dart';

class ClientsList extends StatelessWidget {
  final Controller controller;

  const ClientsList({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            height: 60,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
            ),
            child: const Text("All Clients"),
          ),
          Expanded(
              child: Container(
            child: ListView.builder(
                itemCount: controller.appStates.clientList.value.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.green),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      color: Colors.greenAccent,
                    ),
                    width: double.infinity,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(controller
                            .appStates.clientList.value[index].clientName!),
                        Text(controller
                            .appStates.clientList.value[index].clientId!),
                        Text(controller.appStates.clientList.value[index]
                            .connectionIdAtServer!),
                      ],
                    ),
                  );
                }),
          ))
        ],
      ),
    );
  }
}
