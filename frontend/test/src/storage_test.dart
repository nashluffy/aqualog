import 'package:aqualog/src/storage.dart';
import 'package:test/test.dart';
import 'package:aqualog/gen/records/records.pb.dart';
import 'dart:io';

void main() async {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('FSStorage can write valid record', () async {
    var sut = FSStorage(tempDir.path);
    var input = Record(comments: 'malarky');
    var uuid = await sut.write(input);
    var persisted = await sut.read(uuid);
    expect(input, equals(persisted));
  });
}
