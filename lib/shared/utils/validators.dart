import 'package:flutter/scheduler.dart';

bool isValidUsername(String string) {
  if(string.trim().isEmpty || string.startsWith(RegExp(r"[0-9]"))){
    return false;
  }
  return RegExp(r"^[A-z0-9]+$").hasMatch(string);
}

void afterBuild({required void Function() callback}) => SchedulerBinding.instance.addPostFrameCallback((_) => callback());