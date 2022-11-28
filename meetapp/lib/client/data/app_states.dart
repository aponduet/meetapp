import 'package:flutter/material.dart';
import 'package:meetapp/client/models/connection.dart';

class AppStates {
  final ValueNotifier<List<Connection>> connections =
      ValueNotifier<List<Connection>>([]);
  final ValueNotifier<String> receiverName = ValueNotifier<String>("");
  final ValueNotifier<String> receiverSocketId = ValueNotifier<String>("");
  final ValueNotifier<String> receiverId = ValueNotifier<String>("");
  final ValueNotifier<int> index = ValueNotifier<int>(0);
  final ValueNotifier<int> videoIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> refresh = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isServerConnected = ValueNotifier<bool>(false);
}
