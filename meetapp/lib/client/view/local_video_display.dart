import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meetapp/client/controller/controller.dart';

class LocalVideoDisplay extends StatelessWidget {
  final Controller controller;
  //final RTCVideoRenderer localRenderer;
  const LocalVideoDisplay({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: ValueListenableBuilder<int>(
          valueListenable: controller.appStates.videoIndex,
          builder: (context, videoIndex, child) {
            return videoIndex == 0
                ? RTCVideoView(
                    controller.appStates.connections.value[0].renderer!)
                : RTCVideoView(controller
                    .appStates.connections.value[videoIndex].renderer!);
            // return const Center(
            //   child: Text("I am local video"),
            // );
          }),
    );
  }
}
