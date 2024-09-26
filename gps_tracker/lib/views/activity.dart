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
  List<Activity> filteredActivities = [];
  // Variables pour les filtres
  String selectedSport = 'Run'; // Sport initial sélectionné
  double selectedDifficulty = 2.0; // Filtrage par difficulté
  double selectedDistance = 10.0; // Distance en km

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
        filteredActivities = activities;
        applyFilters();
      });
    } catch (e) {
      print('Erreur lors de la récupération des itinéraires : $e');
    }
  }

  //Application des filtres
  void applyFilters(){
    setState(() {
      filteredActivities = activities.where((activity){
        bool matchesSport = activity.getSportType() == selectedSport;

        bool matchesDistance = selectedDistance>=100
        ? true
        :activity.distance/10.0<=selectedDistance;

        bool matchesDifficulty = getDifficulty(activity.elevationGain) <= selectedDifficulty;


        return matchesSport && matchesDistance && matchesDifficulty;

      }).toList();
    });
  }

  //Filtrer les difficultés
  int getDifficulty(double elevationGain){
    if (elevationGain < 500) {
      return 1; // Très facile
    } else if (elevationGain < 1000) {
      return 2; // Facile
    } else if (elevationGain < 1500) {
      return 3; // Moyen
    } else if (elevationGain < 2000) {
      return 4; // Difficile
    } else {
      return 5; // Très difficile
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
                applyFilters();
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
                  label: 'Difficulté ${selectedDifficulty.toStringAsFixed(0)}/5',
                  value: selectedDifficulty,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  onChanged: (value) {
                    setState(() {
                      selectedDifficulty = value;
                      applyFilters();
                    });
                  },
                ),
                Slider(
                  label: selectedDistance >= 100 ? '100+' : '${selectedDistance.toStringAsFixed(0)} km',
                  value: selectedDistance>100?100:selectedDistance,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  onChanged: (value) {
                    setState(() {
                      selectedDistance = value == 100?101:value;
                      applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),

          // Liste des activités filtrées
          Expanded(
            child: filteredActivities.isEmpty
                ? const Center(
                    child: Text('Aucune activité ne correspond à vos critères de filtrage.'),
                  )
                : ListView.builder(
                    itemCount: filteredActivities.length,
                    itemBuilder: (context, index) {
                      final route = filteredActivities[index];
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