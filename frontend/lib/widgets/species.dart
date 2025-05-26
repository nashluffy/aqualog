import 'package:aqualog/gen/marine/marine.pb.dart';
import 'package:flutter/material.dart';

class SpeciesCard extends StatelessWidget {
  final SpeciesInformation species;

  const SpeciesCard({super.key, required this.species});

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

class SpeciesCardList extends StatelessWidget {
  final List<SpeciesInformation> species;

  const SpeciesCardList({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: species.length,
        itemBuilder: (context, index) {
          return SpeciesCard(species: species[index]);
        },
      ),
    );
  }
}
