import 'package:flutter/material.dart';
import 'package:gps_tracker/views/widgets/activity_card.dart';
import 'package:gps_tracker/views/widgets/sport_selector.dart';
import 'package:gps_tracker/services/strava_service.dart';

class ActivityPage extends StatefulWidget{
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>{
  final StravaService stravaService = StravaService();
  List<dynamic> routes =[];
  // Variables pour les filtres
  String selectedSport = 'Run'; // Sport initial sélectionné
  double selectedDifficulty = 2.0; // Filtrage par difficulté
  double selectedDistance = 10.0; // Distance en km
  double selectedElevation = 200.0; // Dénivelé en 

  @override
  void initState(){
    super.initState();
    fetchRoutes();
  }

  void fetchRoutes() async{
  try{
    final fetchedRoutes = await stravaService.fetchRoutes('20722692');
    setState(() {
      routes = fetchedRoutes;
    });
  }catch (e){
    print('Erreur lors de la récupération des itinéraires : $e');
  }
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activités sportives'),
      ),
      body: Column(
        children: [
          //Sélection du sport
          SportSelector(
            selectedSport: selectedSport,
            onSportChanged: (sport){
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
                      selectedDifficulty=value;
                    });
                  },
                ),
                Slider(
                  label: 'Distance (km)',
                  value: selectedDistance,
                  min: 1,
                  max: 500,
                  onChanged: (value){
                    setState(() {
                      selectedDistance=value;
                    });
                  },
                ),
                Slider(
                  label: 'Dénivelé (m)',
                  value: selectedElevation,
                  min: 0,
                  max: 10000,
                  onChanged: (value){
                    setState(() {
                      selectedElevation=value;
                    });
                  },
                ),
              ],
            ),
          ),

          //Liste des activités
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context,index){
                final route = routes[index];
                return ActivityCard(
                  title: route['name'],
                  distance: route['distance'] ?? selectedDistance,
                  elevation: route['elevation_gain'] ?? selectedElevation,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}