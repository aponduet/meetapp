import 'package:meetapp/client/controller/controller.dart';

class AudioVideo {
  //enable audio
  void enableAudio(Controller controller) async {
    controller.appStates.connections.value[0].renderer!.srcObject!
        .getAudioTracks()
        .forEach((track) {
      track.enabled = true;
    });
  }

  //disable audio
  void disableAudio(Controller controller) async {
    controller.appStates.connections.value[0].renderer!.srcObject!
        .getAudioTracks()
        .forEach((track) {
      track.enabled = false;
    });
  }

  void enableVideo(Controller controller) async {
    controller.appStates.connections.value[0].renderer!.srcObject!
        .getVideoTracks()
        .forEach((track) {
      track.enabled = true;
    });
  }

  //disable Video
  void disableVideo(Controller controller) async {
    controller.appStates.connections.value[0].renderer!.srcObject!
        .getVideoTracks()
        .forEach((track) {
      track.enabled = false;
    });
  }
}
