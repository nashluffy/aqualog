import 'dart:async';
import 'package:grpc/grpc.dart';
import 'gen/dart/life/service.pbgrpc.dart';

class GrpcClient {
  ClientChannel? channel;
  LifeClient? stub;

  // Initialize the gRPC client
  Future<void> createClient() async {
    channel = ClientChannel(
      '127.0.0.1',
      port: 50051, // Port where the Go server is running
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    stub = LifeClient(channel!); // Create a stub for making RPC calls
  }

  // Call the GetByID RPC method
  Future<GetByIDResponse> getSpeciesById(int id) async {
    final request = GetByIDRequest()..id = id; // Create request with the id
    final response = await stub!.getByID(request); // Call the RPC method
    return response; // Return the name of the species from the response
  }

  // Shutdown the gRPC client
  Future<void> shutdown() async {
    await channel?.shutdown();
  }
}
