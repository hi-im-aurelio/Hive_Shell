import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

Future<void> restoreFromBackup(String boxPath, [String? backupPath]) async {
  final defaultBackupPath = p.join(
      p.dirname(boxPath), "${p.basenameWithoutExtension(boxPath)}_backup.hive");
  final restorePath = backupPath ?? defaultBackupPath;

  if (!File(restorePath).existsSync()) {
    print('\n?:.');
    print('└─── Backup not found in $restorePath.');
    print('\n');
    return;
  }

  try {
    // TODO: Atualmente, a restauração do backup substitui completamente o arquivo original.
    // Posso implementar uma abordagem de "mesclagem" em vez de substituição direta.

    // nota: Isso exigiria uma lógica definida para determinar como os dados devem ser mesclados.

    // Por exemplo, em caso de conflitos entre os dados do backup e os originais,
    // preciso decidir qual conjunto de dados teria prioridade.

    final originalFile = File(boxPath);
    if (originalFile.existsSync()) {
      originalFile.deleteSync();
    }

    File(restorePath).copySync(boxPath);
    print('\n?:.');
    print('└─── Backup successfully restored from $restorePath para $boxPath.');
  } catch (e) {
    print('\n?:.');
    print('└─── Error restoring backup: $e');
    print('\n');
  }
}

Future<void> backupBox(String boxPath, [String? destDir]) async {
  final backupLocation = destDir ?? p.dirname(boxPath);
  final backupFileName = "${p.basenameWithoutExtension(boxPath)}_backup.hive";
  final backupFilePath = p.join(backupLocation, backupFileName);

  final boxFile = File(boxPath);
  if (await boxFile.exists()) {
    await boxFile.copy(backupFilePath);
    print('\n?:.');
    print('└─── Backup created in: $backupFilePath');
    print('\n');
  } else {
    print('\n?:.');
    print('└─── Error: Unable to find box.');
    print('\n');
  }
}

Future<void> deleteData(String boxPath, String key) async {
  final box = await Hive.openBox(p.basename(boxPath).split('.').first);

  if (box.containsKey(key)) {
    await box.delete(key);

    print('\n${box.name}:.');
    print('└─── Data with key "$key" was successfully removed.');
    print('\n');
  } else {
    print('\n${box.name}:.');
    print('└─── No entry found with the key "$key".');
    print('\n');
  }
}

Future<void> updateData(String boxPath, String key, String newValue) async {
  final box = await Hive.openBox(p.basename(boxPath).split('.').first);

  if (box.containsKey(key)) {
    box.put(key, newValue);
    print('\n${box.name}:.');
    print('└─── Data with key "$key" was updated successfully.');
    print('\n');
  } else {
    print('\n${box.name}:.');
    print('└─── No entry found with the key "$key".');
    print('\n');
  }
}

Future<void> addData(String boxPath, String key, String value) async {
  final box = await Hive.openBox(p.basename(boxPath).split('.').first);

  if (box.containsKey(key)) {
    print('\n${box.name}:.');
    print(
        '└─── Error: The key "$key" already exists. Use the update command if you want to modify the value.');
    print('\n');
  } else {
    box.put(key, value);
    print('\n${box.name}:.');
    print('└─── Data added successfully!');
    print('\n');
  }
}

Future<void> listData(String boxPath) async {
  print('Listing data for the box in: $boxPath');

  final box = await Hive.openBox(p.basename(boxPath).split('.').first);

  if (box.isNotEmpty) {
    print('\n${box.name}:.');

    var keysList = box.keys.toList();
    for (var i = 0; i < keysList.length; i++) {
      var key = keysList[i];
      var lastItemSymbol = i == keysList.length - 1 ? '└───' : '├───';
      print('$lastItemSymbol $key = ${box.get(key)}');
    }
  } else {
    print('The box "${box.name}" is empty.');
  }

  print('\n');
}
