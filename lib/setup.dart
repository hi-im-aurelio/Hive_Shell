import 'dart:io';
import 'package:args/args.dart';
import 'package:hive/hive.dart';

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

  final cmdParser = ArgParser();

  var boxesCommand = cmdParser.addCommand('boxes');
  boxesCommand.addOption(
    'collection',
    abbr: 'c',
    help: 'Nome da BoxCollection para listar as caixas.',
  );

  final results = parser.parse(args);

  if (results['path'] == null) {
    print(
        'Por favor, forneça um caminho para o arquivo .hive usando -p ou --path.');
    exit(1);
  }

  Hive.init(results['path'] as String);

  while (true) {
    stdout.write('h-shell?> ');
    final line = stdin.readLineSync();

    if (line == null || line == 'exit') {
      print('Saindo...');
      exit(0);
    }

    final cmdResults = cmdParser.parse(line.split(' '));

    if (cmdResults.command?.name == 'boxes') {
      final collectionName = cmdResults.command?['collection'];
      if (collectionName != null) {
        await listBoxes(collectionName as String);
      } else {
        print(
            'Por favor, forneça o nome da BoxCollection usando -c ou --collection.');
      }
    } else {
      print('Comando desconhecido.');
    }
  }
}
