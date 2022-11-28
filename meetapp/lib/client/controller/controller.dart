import 'package:meetapp/client/controller/audio_video.dart';
import 'package:meetapp/client/controller/webrtc.dart';
import 'package:meetapp/client/controller/websocket.dart';
import 'package:meetapp/client/data/app_states.dart';

class Controller {
  WebSocket webSocket = WebSocket();
  WebRtcLocal webRtcLocal = WebRtcLocal();
  AudioVideo audioVideo = AudioVideo();
  AppStates appStates = AppStates();
}
