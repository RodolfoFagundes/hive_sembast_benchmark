import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'database/executor.dart';
import 'database/hive/hive_executor.dart' as hive;
import 'database/hive/hive_lazy_executor.dart' as hive_lazy;
import 'database/sembast/sembast_executor.dart' as sembast;
import 'database/time_tracker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Benchmark - Hive X Sembast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Benchmark - Hive X Sembast'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _db = 1;
  final _countController = TextEditingController(text: '10000');
  final _runsController = TextEditingController(text: '10');
  var _result = 'Not executed';
  TimeTracker _tracker;
  hive.HiveExecutor _hiveExecutor;
  hive_lazy.HiveLazyExecutor _hiveLazyExecutor;
  sembast.SembastExecutor _sembastExecutor;

  void _print(String str) {
    setState(() {
      _result += "\n$str";
    });
  }

  @override
  void initState() {
    super.initState();
    _createDataBase();
  }

  Future _createDataBase() async {
    await getApplicationDocumentsDirectory().then((Directory dir) async {
      _tracker = TimeTracker(outputFn: _print);
      if (await dir.exists()) await dir.delete(recursive: true);
      await dir.create();
      Hive.init(dir.path);
    });
  }

  @override
  void dispose() {
    _hiveExecutor?.close();
    _hiveLazyExecutor?.close();
    _sembastExecutor?.close();
    super.dispose();
  }

  void _runBenchmark() async {
    setState(() {
      _result = 'Starting...';
    });

    switch (_db) {
      case 1:
        await getApplicationDocumentsDirectory().then((Directory dir) async {
          _hiveExecutor = await hive.HiveExecutor.create(
              Directory(path.join(dir.path, 'hive')), _tracker);
        });
        return _runBenchmarkOn(_hiveExecutor);
      case 2:
        await getApplicationDocumentsDirectory().then((Directory dir) async {
          _hiveLazyExecutor = await hive_lazy.HiveLazyExecutor.create(
              Directory(path.join(dir.path, 'hive_lazy')), _tracker);
        });
        return _runBenchmarkOn(_hiveLazyExecutor);
      case 3:
        _sembastExecutor = await sembast.SembastExecutor.create(_tracker);
        return _runBenchmarkOn(_sembastExecutor);
      case 4:
        return _exportJson(_hiveExecutor);
      default:
        throw Exception('Unknown executor');
    }
  }

  void _exportJson(ExecutorBase executor) async {
    _tracker.clear();
    getApplicationDocumentsDirectory().then((Directory dir) async {
      String path =
          '${dir.path}${DateTime.now().toString().replaceAll(new RegExp(r'[^0-9]'), '')}.json';
      File backupFile = File(path);
      await backupFile.writeAsString(await executor.json());
    });
    setState(() {
      _result = 'Export finished';
    });
  }

  void _runBenchmarkOn(ExecutorBase executor) async {
    _tracker.clear();
    final inserts =
        executor.prepareData(int.parse(_countController.value.text));
    final runs = int.parse(_runsController.value.text);

    for (var i = 0; i < runs; i++) {
      if (i == 0) {
        await executor.insertMany(inserts);
      }

      final ids = inserts.map((e) => e.id).toList(growable: false);
      final items = await executor.readMany(ids);
      executor.changeValues(items);
      await executor.updateMany(items);

      setState(() {
        _result = '${i + 1}/$runs finished';
      });
      await Future.delayed(Duration(seconds: 0));
    }

    _result = '';
    _tracker.printTimes(avgOnly: true, functions: [
      'insertMany',
      'readMany',
      'updateMany',
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Spacer(),
              DropdownButton(
                  value: _db,
                  items: [
                    DropdownMenuItem(
                      child: Text("Hive"),
                      value: 1,
                    ),
                    DropdownMenuItem(
                      child: Text("Hive Lazy"),
                      value: 2,
                    ),
                    DropdownMenuItem(
                      child: Text("Sembast"),
                      value: 3,
                    ),
                    DropdownMenuItem(
                      child: Text("Export Hive"),
                      value: 4,
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _db = value;
                    });
                  }),
              Spacer(),
              Expanded(
                  child: TextField(
                keyboardType: TextInputType.number,
                controller: _runsController,
                decoration: InputDecoration(
                  labelText: 'Runs',
                ),
              )),
              Spacer(),
              Expanded(
                  child: TextField(
                keyboardType: TextInputType.number,
                controller: _countController,
                decoration: InputDecoration(
                  labelText: 'Count',
                ),
              )),
              Spacer(),
            ]),
            Spacer(),
            Expanded(child: Text(_result)),
            Spacer()
          ],
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _runBenchmark,
        tooltip: 'Start',
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
