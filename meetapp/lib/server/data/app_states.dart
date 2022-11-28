import 'package:flutter/material.dart';
import 'package:meetapp/server/models/client_info.dart';
import 'package:meetapp/server/models/connection_info.dart';

class AppStates {
  final ValueNotifier<List<ConnectionInfo>> connections =
      ValueNotifier<List<ConnectionInfo>>([]);
  final ValueNotifier<List<ClientInfo>> clientList =
      ValueNotifier<List<ClientInfo>>([]);
  final ValueNotifier<String> serverid = ValueNotifier<String>("");
  final ValueNotifier<bool> refresh = ValueNotifier<bool>(true);
}
