import 'package:aqualog/gen/dart/life/service.pb.dart';
import 'package:flutter/material.dart';

class SpeciesCard extends StatelessWidget {
  final SpeciesInformation species;

  const SpeciesCard({Key? key, required this.species}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          children: [
            DefaultTextStyle.merge(child: Text(species.name)),
            DefaultTextStyle.merge(child: Text(species.comments)),
          ],
        ),
      ),
    );
  }
}
