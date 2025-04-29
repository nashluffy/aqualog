import 'dart:async';
import 'package:grpc/grpc.dart';
import 'package:aqualog/gen/dart/life.pb.dart'; // Updated import
import 'package:aqualog/gen/dart/life.pbgrpc.dart'; // Updated import

class GrpcClient {
  ClientChannel? channel;
  LifeClient? stub;

  // Initialize the gRPC client
  Future<void> createClient() async {
    channel = ClientChannel(
      'localhost', // Address of the Go server (adjust if necessary)
      port: 50051, // Port where the Go server is running
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(), // No SSL in development
      ),
    );

    stub = LifeClient(channel!); // Create a stub for making RPC calls
  }

  // Call the GetByID RPC method
  Future<String> getSpeciesById(int id) async {
    try {
      final request = GetByIDRequest()..id = id; // Create request with the id
      final response = await stub!.getByID(request); // Call the RPC method
      return response.name; // Return the name of the species from the response
    } catch (e) {
      print('Error calling gRPC service: $e');
      return 'Error: $e'; // Handle error if the RPC fails
    }
  }

  // Shutdown the gRPC client
  Future<void> shutdown() async {
    await channel?.shutdown();
  }
}
