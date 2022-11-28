import 'package:flutter/material.dart';
import 'package:meetapp/client/controller/controller.dart';

class ControlButtonBar extends StatefulWidget {
  final Controller controller;
  const ControlButtonBar({Key? key, required this.controller})
      : super(key: key);

  @override
  _ControlButtonBarState createState() => _ControlButtonBarState();
}

class _ControlButtonBarState extends State<ControlButtonBar> {
  bool isMicActive = true;
  bool isCameraActive = true;
  bool isVolumeActive = true;
  bool isConnectionActive = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.white38),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white38,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              isMicActive
                  ? widget.controller.audioVideo.disableAudio(widget.controller)
                  : widget.controller.audioVideo.enableAudio(widget.controller);
              setState(() {
                isMicActive = !isMicActive;
              });
            },
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                    width: 1, color: isMicActive ? Colors.red : Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                color: isMicActive ? Colors.red : Colors.white,
              ),
              child: Center(
                child: isMicActive
                    ? const Icon(Icons.video_call)
                    : const Icon(Icons.mic),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          IconButton(
            onPressed: () {
              isCameraActive
                  ? widget.controller.audioVideo.disableVideo(widget.controller)
                  : widget.controller.audioVideo.enableVideo(widget.controller);
              setState(() {
                isCameraActive = !isCameraActive;
              });
            },
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: isCameraActive ? Colors.red : Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                color: isCameraActive ? Colors.red : Colors.white,
              ),
              child: Center(
                child: isCameraActive
                    ? const Icon(Icons.videocam_off)
                    : const Icon(Icons.videocam),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isVolumeActive = true;
              });
            },
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: isVolumeActive ? Colors.red : Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                color: isVolumeActive ? Colors.red : Colors.white,
              ),
              child: Center(
                  child: isCameraActive
                      ? const Icon(Icons.volume_up)
                      : const Icon(
                          Icons.volume_off,
                        )),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isConnectionActive = true;
              });
            },
            icon: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                    width: 1,
                    color: isConnectionActive ? Colors.white : Colors.red),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                color: isConnectionActive ? Colors.white : Colors.red,
              ),
              child: Center(
                  child: isConnectionActive
                      ? const Icon(Icons.volume_up)
                      : const Icon(
                          Icons.volume_off,
                        )),
            ),
          ),
        ],
      ),
    );
  }
}
