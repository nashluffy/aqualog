import 'dart:async';
import 'package:grpc/grpc.dart';
import '../gen/marine/marine.pbgrpc.dart';

class GrpcClient {
  ClientChannel? channel;
  CatalogueClient? stub;

  Future<void> createClient() async {
    channel = ClientChannel(
      '127.0.0.1',
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    stub = CatalogueClient(channel!);
  }

  Future<GetByIDResponse> getSpeciesById(int id) async {
    final request = GetByIDRequest()..id = id;
    final response = await stub!.getByID(request);
    return response;
  }

  Future<GetByCommonNameResponse> getSpeciesByName(String name) async {
    final request = GetByCommonNameRequest()..name = name;
    final response = await stub!.getByCommonName(request);
    return response;
  }

  Future<void> shutdown() async {
    await channel?.shutdown();
  }
}
