import 'dart:async';
import 'package:grpc/grpc.dart';
import '../gen/marine/marine.pbgrpc.dart';
import '../gen/records/records.pbgrpc.dart';

class GrpcClient {
  ClientChannel? channel;
  CatalogueClient? catalogueStub;
  StorageClient? storageStub;

  Future<void> createClient() async {
    channel = ClientChannel(
      '127.0.0.1',
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    catalogueStub = CatalogueClient(channel!);
    storageStub = StorageClient(channel!);
  }

  Future<GetByIDResponse> getSpeciesById(int id) async {
    final request = GetByIDRequest()..id = id;
    final response = await catalogueStub!.getByID(request);
    return response;
  }

  Future<GetByCommonNameResponse> getSpeciesByName(String name) async {
    final request = GetByCommonNameRequest()..name = name;
    final response = await catalogueStub!.getByCommonName(request);
    return response;
  }

  Future<ListRecordsResponse> listRecords() async {
    final request = ListRecordsRequest();
    final response = await storageStub!.listRecords(request);
    return response;
  }

  Future<CreateRecordResponse> createRecord(Record record) async {
    final request = CreateRecordRequest(record: record);
    final response = await storageStub!.createRecord(request);
    return response;
  }

  Future<void> shutdown() async {
    await channel?.shutdown();
  }
}
