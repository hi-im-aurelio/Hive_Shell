import 'dart:io';
import 'package:args/args.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

import 'source/local_interaction.dart';
import 'source/device_interaction.dart';

void setup(List<String> args) async {
  bool testHiveFileThatIsOnTheAndroidDevice = false;

  final parser = ArgParser();

  parser.addOption('path', abbr: 'p', help: 'Path to the .hive file.');
  parser.addOption('org', abbr: 'o', help: 'App package name (organization).');
  parser.addOption('boxname',
      abbr: 'b', help: 'Name of the box to be managed.');

  final results = parser.parse(args);

  String? path = results['path'] as String?;
  String? org = results['org'] as String?;
  String? boxName = results['boxname'] as String?;

  if (path == null) {
    testHiveFileThatIsOnTheAndroidDevice =
        true; // o --path só poderá ser ignorado por um motivo.
    if (org != null && boxName != null) {
      path = await getDeviceFilePath(org, boxName);
    } else {
      print('Please provide a --path or use --org with --boxName.');
      exit(1);
    }
  }

  final cmdParser = ArgParser();

  cmdParser.addCommand('datas');

  var addCommand = cmdParser.addCommand('add');
  addCommand.addOption('key', abbr: 'k', help: 'Key for the new data.');
  addCommand.addOption('value',
      abbr: 'v', help: 'Value associated with the key.');

  var updateCommand = cmdParser.addCommand('update');
  updateCommand.addOption('key',
      abbr: 'k', help: 'Key of the data to be updated.');
  updateCommand.addOption('value',
      abbr: 'v', help: 'New value for the specified key.');

  var deleteCommand = cmdParser.addCommand('delete');
  deleteCommand.addOption('key',
      abbr: 'k', help: 'Key of the data to be removed.');

  var backupCommand = cmdParser.addCommand('backup');
  backupCommand.addOption('destination',
      abbr: 'd', help: 'Location where the backup will be saved.');

  var restoreCommand = cmdParser.addCommand('restore');
  restoreCommand.addOption('source', abbr: 's', help: 'Backup file location.');

  Hive.init(p.dirname(path));

  if (testHiveFileThatIsOnTheAndroidDevice) {
    print('No implementation yet...');
    return;
  }

  while (true) {
    stdout.write('h-shell?> ');
    final line = stdin.readLineSync();

    if (line == null || line == 'exit') {
      print('Exit...');
      exit(0);
    }

    final cmdResults = cmdParser.parse(line.split(' '));

    if (cmdResults.command?.name == 'datas') {
      await listData(results['path'] as String);
    } else if (cmdResults.command?.name == 'add') {
      var key = cmdResults.command?['key'];
      var value = cmdResults.command?['value'];

      if (key != null && value != null) {
        await addData(results['path'] as String, key, value);
      } else {
        print('Please provide a key and value to add.');
      }
    } else if (cmdResults.command?.name == 'update') {
      var key = cmdResults.command?['key'];
      var value = cmdResults.command?['value'];

      if (key != null && value != null) {
        await updateData(results['path'] as String, key, value);
      } else {
        print('Please provide a key and new value to update.');
      }
    } else if (cmdResults.command?.name == 'delete') {
      var key = cmdResults.command?['key'];

      if (key != null) {
        await deleteData(results['path'] as String, key);
      } else {
        print('Please provide a key to remove the data.');
      }
    } else if (cmdResults.command?.name == 'backup') {
      var destDir = cmdResults.command?['destination'];
      await backupBox(results['path'] as String, destDir);
    } else if (cmdResults.command?.name == 'restore') {
      var backupLocation = cmdResults.command?['source'];
      await restoreFromBackup(results['path'] as String, backupLocation);
    } else {
      print('Unknown command.');
    }
  }
}
