import 'dart:io';

Future<void> executeDirectlyOnDevice(
    String devicePath, Future<void> Function(String) action) async {
  String localTempPath = './temp_hive_file.hive';

  try {
    await pullFileFromDevice(devicePath, localTempPath);
  } catch (e) {
    print('Error pulling file from device: $e');
    return;
  }

  try {
    await action(localTempPath);
  } catch (e) {
    print('Error handling local file: $e');
    return;
  }

  try {
    await pushFileToDevice(localTempPath, devicePath);
  } catch (e) {
    print('Error sending updated file to device: $e');
    return;
  }

  try {
    File(localTempPath).deleteSync();
  } catch (e) {
    print('Error when deleting temporary file: $e');
  }
}

Future<String> getDeviceFilePath(String packageName, String boxName) async {
  return "/data/data/$packageName/app_flutter/$boxName.hive";
}

Future<void> pullFileFromDevice(String devicePath, String localPath) async {
  try {
    var result = await Process.run('adb', ['pull', devicePath, localPath]);

    if (result.exitCode == 0) {
      print('\n?:.');
      print('└─── File successfully pulled from the device.');
      print('\n');
    } else {
      print('\n?:.');
      print('└─── Error pulling file from device.');
      print('\n');
    }
  } catch (e) {
    print('Erro: $e');
  }
}

Future<void> pushFileToDevice(String localPath, String devicePath) async {
  try {
    var result = await Process.run('adb', ['push', localPath, devicePath]);

    if (result.exitCode == 0) {
      print('\n?:.');
      print('└─── File successfully sent to the device.');
      print('\n');
    } else {
      print('\n?:.');
      print('└─── Error sending file to device.');
      print('\n');
    }
  } catch (e) {
    print('Erro: $e');
  }
}

Future<bool> isAdbAvailable() async {
  try {
    var result = await Process.run('adb', ['version']);
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}
