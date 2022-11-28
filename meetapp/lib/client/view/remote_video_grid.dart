import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meetapp/client/controller/controller.dart';
import 'package:meetapp/client/models/connection.dart';

class RemoteVideoGrid extends StatelessWidget {
  final Controller controller;
  final List<Connection> connections;
  const RemoteVideoGrid(
      {Key? key, required this.connections, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   child: ListView.builder(
    //     scrollDirection: Axis.vertical,
    //     shrinkWrap: true,
    //     //itemCount: renderStreamsGrid().length,
    //     itemCount: renderStreamsGrid().length,
    //     itemBuilder: (context, index) {
    //       return renderStreamsGrid()[index];
    //     },
    //   ),
    // );

    return Container(
      child: ListView.builder(
        itemCount: controller.appStates.connections.value.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // controller.appStates.videoIndex.value = index;
              // print(
              //     'VideoIndex Value is : ${controller.appStates.videoIndex.value}');
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              width: 250,
              height: 200,
              color: Colors.yellow,
              child: Stack(
                children: [
                  RTCVideoView(
                    controller.appStates.connections.value[index].renderer!,
                    // objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    // mirror: true,
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: IconButton(
                      onPressed: () {
                        //Do something for controlling mic
                        controller.appStates.videoIndex.value = index;
                        print(
                            'VideoIndex Value is : ${controller.appStates.videoIndex.value}');
                      },
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.red),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: const Center(child: Icon(Icons.mic_off)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
