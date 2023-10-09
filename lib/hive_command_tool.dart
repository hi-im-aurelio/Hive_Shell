import 'package:hive/hive.dart';

int calculate() {
  return 6 * 7;
}

void hiveInit() async {
  var path = "C:/Users/Farioso/Desktop/hive_command_tool";

  Hive.init(path);
  var box = await Hive.openBox('name_of_the_box');
  print(box);
}
