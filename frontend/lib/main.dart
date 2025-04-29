import 'package:flutter/material.dart';
import 'grpc_client.dart'; // Import the gRPC client

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter gRPC Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GrpcClient grpcClient = GrpcClient();
  String _speciesName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchSpecies(); // Fetch species when the app starts
  }

  Future<void> _fetchSpecies() async {
    await grpcClient.createClient(); // Initialize the gRPC client
    final name = await grpcClient.getSpeciesById(1); // Example ID: 1
    setState(() {
      _speciesName = name; // Update the UI with the species name
    });
  }

  @override
  void dispose() {
    grpcClient.shutdown(); // Clean up the gRPC client
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('gRPC Example'),
      ),
      body: Center(
        child: Text(
          'Species Name: $_speciesName', // Display the species name
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
