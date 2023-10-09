import 'dart:io';
import 'package:args/args.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

Future<void> restoreFromBackup(String boxPath, [String? backupPath]) async {
  final defaultBackupPath = p.join(
      p.dirname(boxPath), "${p.basenameWithoutExtension(boxPath)}_backup.hive");
  final restorePath = backupPath ?? defaultBackupPath;

  if (!File(restorePath).existsSync()) {
    print('\n?:.');
    print('└─── Backup não encontrado em $restorePath.');
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
    print('└─── Backup restaurado com sucesso de $restorePath para $boxPath.');
  } catch (e) {
    print('\n?:.');
    print('└─── Erro ao restaurar o backup: $e');
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
    print('└─── Backup criado em: $backupFilePath');
    print('\n');
  } else {
    print('\n?:.');
    print('└─── Erro: Não foi possível encontrar a caixa.');
    print('\n');
  }
}

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

Future<void> updateData(String boxPath, String key, String newValue) async {
  final box = await Hive.openBox(p.basename(boxPath).split('.').first);

  if (box.containsKey(key)) {
    box.put(key, newValue);
    print('\n${box.name}:.');
    print('└─── Dado com a chave "$key" foi atualizado com sucesso.');
    print('\n');
  } else {
    print('\n${box.name}:.');
    print('└─── Não foi encontrada nenhuma entrada com a chave "$key".');
    print('\n');
  }
}

Future<void> addData(String boxPath, String key, String value) async {
  final box = await Hive.openBox(p.basename(boxPath).split('.').first);

  if (box.containsKey(key)) {
    print('\n${box.name}:.');
    print(
        '└─── Erro: A chave "$key" já existe. Use o comando de atualização se desejar modificar o valor.');
    print('\n');
  } else {
    box.put(key, value);
    print('\n${box.name}:.');
    print('└─── Dado adicionado com sucesso!');
    print('\n');
  }
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

  var updateCommand = cmdParser.addCommand('update');
  updateCommand.addOption('key',
      abbr: 'k', help: 'Chave do dado a ser atualizado.');
  updateCommand.addOption('value',
      abbr: 'v', help: 'Novo valor para a chave especificada.');

  var deleteCommand = cmdParser.addCommand('delete');
  deleteCommand.addOption('key',
      abbr: 'k', help: 'Chave do dado a ser removido.');

  var backupCommand = cmdParser.addCommand('backup');
  backupCommand.addOption('destination',
      abbr: 'd', help: 'Localização onde o backup será salvo.');

  var restoreCommand = cmdParser.addCommand('restore');
  restoreCommand.addOption('source',
      abbr: 's', help: 'Localização do arquivo de backup.');

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
    } else if (cmdResults.command?.name == 'update') {
      var key = cmdResults.command?['key'];
      var value = cmdResults.command?['value'];

      if (key != null && value != null) {
        await updateData(results['path'] as String, key, value);
      } else {
        print('Por favor, forneça uma chave e um novo valor para atualizar.');
      }
    } else if (cmdResults.command?.name == 'delete') {
      var key = cmdResults.command?['key'];

      if (key != null) {
        await deleteData(results['path'] as String, key);
      } else {
        print('Por favor, forneça uma chave para remover o dado.');
      }
    } else if (cmdResults.command?.name == 'backup') {
      var destDir = cmdResults.command?['destination'];
      await backupBox(results['path'] as String, destDir);
    } else if (cmdResults.command?.name == 'restore') {
      var backupLocation = cmdResults.command?['source'];
      await restoreFromBackup(results['path'] as String, backupLocation);
    } else {
      print('Comando desconhecido.');
    }
  }
}
