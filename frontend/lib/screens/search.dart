import 'package:flutter/material.dart';
import 'package:aqualog/gen/marine/marine.pb.dart';

import 'package:aqualog/species.dart';
import '../services/grpc_client.dart'; // Import the gRPC client

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.grpcClient});
  final GrpcClient grpcClient;

  @override
  _SearchPageState createState() => _SearchPageState(grpcClient: grpcClient);
}

class _SearchPageState extends State<SearchPage> {
  _SearchPageState({required this.grpcClient});
  final GrpcClient grpcClient;

  @override
  void initState() {
    super.initState();
  }

  static const _focusDelay = Duration(milliseconds: 10);
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  List<SpeciesInformation>? _species;

  Future<void> _fetchSpecies(String name) async {
    await grpcClient.createClient(); // Initialize the gRPC client
    final response = await grpcClient.getSpeciesByName(name); // Example ID: 1
    setState(() {
      _species = response.species.toList();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
