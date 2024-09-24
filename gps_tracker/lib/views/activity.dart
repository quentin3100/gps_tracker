import 'package:flutter/material.dart';
import 'package:gps_tracker/models/activity.dart';
import 'package:gps_tracker/views/activity_detail.dart';

import 'package:gps_tracker/views/widgets/activity_card.dart';
import 'package:gps_tracker/views/widgets/sport_selector.dart';
import 'package:gps_tracker/services/strava_service.dart';


class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final StravaService stravaService = StravaService();
  List<Activity> activities = [];
  // Variables pour les filtres
  String selectedSport = 'Run'; // Sport initial sélectionné
  double selectedDifficulty = 2.0; // Filtrage par difficulté
  double selectedDistance = 10.0; // Distance en km
  double selectedElevation = 200.0; // Dénivelé en

  @override
  void initState() {
    super.initState();
    fetchRoutes();
  }

  void fetchRoutes() async {
    try {
      final fetchedRoutes = await stravaService.fetchRoutes('20722692');
      setState(() {
        activities = fetchedRoutes;
      });
    } catch (e) {
      print('Erreur lors de la récupération des itinéraires : $e');
    }
  }

  Map<String, dynamic> getActivityDetails(int index){
    switch (index) {
      case 0:
        return {
          'description': 'Description de l\'itinéraire 1',
          'technicalLevel': 3.0,
          'landscapeLevel': 4.0,
          'physicalLevel': 4.5,
        };
      case 1:
        return {
          'description': 'Description de l\'itinéraire 2',
          'technicalLevel': 4.0,
          'landscapeLevel': 3.0,
          'physicalLevel': 4.0,
        };
      case 2:
        return {
          'description': 'Description de l\'itinéraire 3',
          'technicalLevel': 2.5,
          'landscapeLevel': 5.0,
          'physicalLevel': 3.5,
        };
      // Ajoutez d'autres cas selon vos besoins
      default:
        return {
          'description': 'Description par défaut',
          'technicalLevel': 2.0,
          'landscapeLevel': 2.0,
          'physicalLevel': 2.0,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activités sportives'),
      ),
      body: Column(
        children: [
          //Sélection du sport
          SportSelector(
            selectedSport: selectedSport,
            onSportChanged: (sport) {
              setState(() {
                selectedSport = sport;
              });
            },
          ),
          //Filtres
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  label: 'Difficulté',
                  value: selectedDifficulty,
                  min: 1,
                  max: 5,
                  onChanged: (value) {
                    setState(() {
                      selectedDifficulty = value;
                    });
                  },
                ),
                Slider(
                  label: 'Distance (km)',
                  value: selectedDistance,
                  min: 1,
                  max: 500,
                  divisions: 50,
                  onChanged: (value) {
                    setState(() {
                      selectedDistance = value;
                    });
                  },
                ),
                Slider(
                  label: 'Dénivelé (m)',
                  value: selectedElevation,
                  min: 0,
                  max: 10000,
                  onChanged: (value) {
                    setState(() {
                      selectedElevation = value;
                    });
                  },
                ),
              ],
            ),
          ),

          //Liste des activités
          Expanded(
            child: ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final route = activities[index];
                final routePoints = stravaService.decodePolyline(route.summaryPolyline);

                return ActivityCard(
                  title: route.name,
                  distance: route.distance,
                  elevation: route.elevationGain,
                  routePoints: routePoints,
                  onTap: () {
                    // Récupérer les détails de l'activité en fonction de l'index
                    final details = getActivityDetails(index);

                    // Navigation vers la page de détails de l'itinéraire
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailPage(
                          id: route.id,
                          title: route.name,
                          distance: route.distance,
                          elevation: route.elevationGain,
                          description: details['description'],
                          technicalLevel: details['technicalLevel'],
                          landscapeLevel: details['landscapeLevel'],
                          physicalLevel: details['physicalLevel'],
                          routePoints: routePoints,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}