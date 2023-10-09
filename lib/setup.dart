import 'dart:io';
import 'package:args/args.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

Future<void> listData(String boxPath) async {
  print('Listando dados para a box em: $boxPath');

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
    print('A box "${box.name}" está vazia.');
  }

  print('\n');
}

Future<void> listBoxes(String collectionName) async {
  print('Listando caixas para: $collectionName');
}

void setup(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'path',
      abbr: 'p',
      help: 'Caminho para o arquivo .hive.',
    );

  final results = parser.parse(args);

  if (results['path'] == null) {
    print(
        'Por favor, forneça um caminho para o arquivo .hive usando -p ou --path.');
    exit(1);
  }

  // ==========================================================

  final cmdParser = ArgParser();

  cmdParser.addCommand('datas');

  String path = results['path'] as String;

  Hive.init(p.dirname(path));

  while (true) {
    stdout.write('h-shell?> ');
    final line = stdin.readLineSync();

    if (line == null || line == 'exit') {
      print('Saindo...');
      exit(0);
    }

    final cmdResults = cmdParser.parse(line.split(' '));

    if (cmdResults.command?.name == 'datas') {
      await listData(results['path'] as String);
    } else {
      print('Comando desconhecido.');
    }
  }
}
