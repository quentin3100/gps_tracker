import 'package:flutter/material.dart';

class SportSelector extends StatelessWidget{
  final String selectedSport;
  final ValueChanged<String> onSportChanged;

  SportSelector({required this.selectedSport, required this.onSportChanged});

  @override
  Widget build(BuildContext context){
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          buildSportButton('Run', Icons.directions_run),
          buildSportButton('Ride', Icons.directions_bike),
          buildSportButton('Hike', Icons.terrain),
        ],
      ),
    );
  }

  // Méthode pour créer un bouton pour chaque sport
  Widget buildSportButton(String sport, IconData icon) {
    return GestureDetector(
      onTap: () => onSportChanged(sport),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: selectedSport == sport ? Colors.blue : Colors.grey,
              size: 40,
            ),
            Text(
              sport,
              style: TextStyle(
                color: selectedSport == sport ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}