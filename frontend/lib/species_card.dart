import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'grpc_client.dart'; // Import the gRPC client

class SpeciesCard extends StatelessWidget {
  final String speciesName;
  final String speciesComments;

  const SpeciesCard({
    Key? key,
    required this.speciesName,
    required this.speciesComments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          children: [
            DefaultTextStyle.merge(child: Text(speciesName)),
            DefaultTextStyle.merge(child: Text(speciesComments)),
          ],
        ),
      ),
    );
  }
}
