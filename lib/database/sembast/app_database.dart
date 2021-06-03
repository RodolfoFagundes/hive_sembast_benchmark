import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class AppDatabase {
  // Única instância (Singleton)
  static final AppDatabase _singleton = AppDatabase._();

  static AppDatabase get instance => _singleton;

  // "Completer" é usado para transformar o código síncrono em código assíncrono.
  Completer<Database> _dbOpenCompleter;

  // Construtor privado. Nos permite criar instâncias de AppDatabase apenas de dentro da própria classe.
  AppDatabase._();

  Future<Database> get database async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      _openDatabase();
    }

    return _dbOpenCompleter.future;
  }

  Future _openDatabase() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocumentDir.path, 'sembast_rodolfo_poc.db');
    final database = await databaseFactoryIo.openDatabase(dbPath);
    _dbOpenCompleter.complete(database);
  }
}
