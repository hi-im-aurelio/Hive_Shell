import 'dart:io';
import 'package:args/args.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

Future<void> deleteData(String boxPath, String key) async {
  final box = await Hive.openBox(p.basename(boxPath).split('.').first);

  if (box.containsKey(key)) {
    await box.delete(key);

    print('\n${box.name}:.');
    print('└─── Dado com a chave "$key" foi removido com sucesso.');
    print('\n');
  } else {
    print('\n${box.name}:.');
    print('└─── Não foi encontrada nenhuma entrada com a chave "$key".');
    print('\n');
  }
}

Future<void> addData(String boxPath, String key, String value) async {
  final box = await Hive.openBox(p.basename(boxPath).split('.').first);

  box.put(key, value);

  print('\n${box.name}:.');
  print('└─── Dado adicionado com sucesso!');
  print('\n');
}

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

  var addCommand = cmdParser.addCommand('add');
  addCommand.addOption('key', abbr: 'k', help: 'Chave para o novo dado.');
  addCommand.addOption('value', abbr: 'v', help: 'Valor associado à chave.');

  var deleteCommand = cmdParser.addCommand('delete');
  deleteCommand.addOption('key',
      abbr: 'k', help: 'Chave do dado a ser removido.');

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
    } else if (cmdResults.command?.name == 'add') {
      var key = cmdResults.command?['key'];
      var value = cmdResults.command?['value'];

      if (key != null && value != null) {
        await addData(results['path'] as String, key, value);
      } else {
        print('Por favor, forneça uma chave e um valor para adicionar.');
      }
    } else if (cmdResults.command?.name == 'delete') {
      var key = cmdResults.command?['key'];

      if (key != null) {
        await deleteData(results['path'] as String, key);
      } else {
        print('Por favor, forneça uma chave para remover o dado.');
      }
    } else {
      print('Comando desconhecido.');
    }
  }
}
