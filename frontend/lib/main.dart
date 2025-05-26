import 'package:aqualog/gen/marine/marine.pb.dart';
import 'package:aqualog/screens/diary.dart';
import 'package:aqualog/screens/search.dart';
import 'package:aqualog/species.dart';
import 'package:flutter/material.dart';
import 'grpc_client.dart'; // Import the gRPC client

void main() {
  runApp(AqualogApp());
}

class AqualogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter gRPC Client',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DefaultTabController(length: 3, child: AqualogHomePage()),
    );
  }
}

class AqualogHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AqualogHomePage> {
  final GrpcClient grpcClient = GrpcClient();
  List<SpeciesInformation>? _species;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchSpecies(String name) async {
    await grpcClient.createClient(); // Initialize the gRPC client
    final response = await grpcClient.getSpeciesByName(name); // Example ID: 1
    setState(() {
      _species = response.species.toList();
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
      appBar: AppBar(
        title: Text('aqualog'),
        bottom: const TabBar(
          tabs: [Tab(icon: Icon(Icons.search)), Tab(icon: Icon(Icons.book))],
        ),
      ),
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
            if (_species != null) SpeciesCardList(species: _species!),
          ],
        ),
      ),
    );
  }
}
