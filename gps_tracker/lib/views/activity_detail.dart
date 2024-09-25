
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gps_tracker/services/strava_service.dart';
import 'package:gps_tracker/views/widgets/gauge.dart';
import 'package:latlong2/latlong.dart';



class ActivityDetailPage extends StatelessWidget{
  final String title;
  final double distance;
  final double elevation;
  final String description;
  final double technicalLevel;
  final double landscapeLevel;
  final double physicalLevel;
  final List<LatLng> routePoints;
  final String id;

   ActivityDetailPage({
    super.key,
    required this.title,
    required this.distance,
    required this.elevation,
    required this.description,
    required this.technicalLevel,
    required this.landscapeLevel,
    required this.physicalLevel,
    required this.routePoints,
    required this.id,

  });

  final StravaService stravaService = StravaService();

  void _downloadGpx(BuildContext context) async{
    try{
      await stravaService.downloadGpx(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fichier GPX téléchargé avec succès')),
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement du GPX: $e activité id : $id')),
      );
    }
  }

   void _downloadTcx(BuildContext context) async{
    try{
      await stravaService.downloadTCX(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fichier TCX téléchargé avec succès')),
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement du TCX: $e activité id : $id')),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distance: ${(distance/10).toStringAsFixed(1)} km'),
            Text('Dénivelé: ${elevation.toStringAsFixed(0)} m'),
            Text('Description: $description'),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomGauge(

                  value: technicalLevel,
                  maxValue: 5.0,
                  label: 'Technique',
                  color: Colors.red,
                ),
                const SizedBox(width: 16),
                CustomGauge(
                  value: landscapeLevel,
                  maxValue: 5.0,
                  label: 'Paysage',
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                CustomGauge(
                  value: physicalLevel,
                  maxValue: 5.0,
                  label: 'Physique',
                  color: Colors.blue,
                ),
              ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: routePoints.isNotEmpty ? routePoints.first :  const LatLng(46.9889, 6.9293),
                  initialZoom: 13.0,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a','b','c'],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: ()=>_downloadGpx(context),
                child: const Text('Télécharger GPX'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: ()=>_downloadTcx(context),
                child: const Text('Télécharger TCX'),
              ),
            )
          ],
        ),
      ),
    );
  }
}