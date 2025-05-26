import 'package:aqualog/gen/records/records.pb.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

abstract class Storage {
  Future<String> write(Record record);
  Future<List<Record>> list();
  Future<Record> read(String id);
}

class FSStorage implements Storage {
  FSStorage(this.path);

  final String path;

  @override
  Future<String> write(Record record) async {
    const uuid = Uuid();

    String id = uuid.v4();
    final file = File('$path/$id.json');

    await file.writeAsString(record.writeToJson());
    return id;
  }

  @override
  Future<List<Record>> list() async {
    final List<Record> records = [];
    final dir = Directory(path);
    final entities = dir.listSync();
    for (var entity in entities) {
      if (entity is! File) {
        continue;
      }
      final file = File(entity.absolute.path);
      final content = await file.readAsString();
      final record = Record.fromJson(content);
      records.add(record);
    }
    return records;
  }

  @override
  Future<Record> read(String id) async {
    final file = File('$path/$id.json');
    final bytes = await file.readAsString();
    return Record.fromJson(bytes);
  }
}
