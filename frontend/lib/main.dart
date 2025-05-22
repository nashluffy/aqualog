import 'package:aqualog/gen/dart/life/service.pb.dart';
import 'package:aqualog/species_card.dart';
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
  SpeciesInformation? _species;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchSpecies(String name) async {
    await grpcClient.createClient(); // Initialize the gRPC client
    final response = await grpcClient.getSpeciesByName(name); // Example ID: 1
    setState(() {
      _species = response.species[0];
      print(_species);
    });
  }

  final _focusDelay = Duration(milliseconds: 10);
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
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
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.newline, // Keep keyboard open

              onSubmitted: (String value) async {
                Future.delayed(_focusDelay, () {
                  _focusNode.requestFocus();
                });

                await _fetchSpecies(value);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Species ID',
              ),
            ),
            if (_species != null) SpeciesCard(species: _species!),
          ],
        ),
      ),
    );
  }
}
