import 'package:meetapp/server/controller/webrtc.dart';
import 'package:meetapp/server/controller/websocket.dart';
import 'package:meetapp/server/data/app_states.dart';

class Controller {
  WebSocket webSocket = WebSocket();
  WebRtc webRtc = WebRtc();
  AppStates appStates = AppStates();
}
