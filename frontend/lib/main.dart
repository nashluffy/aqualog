import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'grpc_client.dart'; // Import the gRPC client

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter gRPC Client',
      theme: ThemeData(primarySwatch: Colors.blue),
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
    _fetchSpecies(5); // Fetch species when the app starts
  }

  Future<void> _fetchSpecies(int id) async {
    await grpcClient.createClient(); // Initialize the gRPC client
    final name = await grpcClient.getSpeciesById(id); // Example ID: 1
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
      appBar: AppBar(title: Text('aqualog')),
      body: Padding(
        padding: const EdgeInsets.all(200.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (String value) async {
                await _fetchSpecies(int.parse(value));
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Species ID',
              ),
            ),
            DefaultTextStyle.merge(child: Text(_speciesName)),
          ],
        ),
      ),
    );
  }
}
