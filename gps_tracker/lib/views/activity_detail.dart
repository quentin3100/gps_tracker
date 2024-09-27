
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gps_tracker/services/strava_service.dart';
import 'package:gps_tracker/views/widgets/elevation_profil.dart';
import 'package:gps_tracker/views/widgets/gauge.dart';
import 'package:latlong2/latlong.dart';



class ActivityDetailPage extends StatefulWidget{
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
  @override
  _ActivityDetailPageState createState()=>_ActivityDetailPageState();
}

  class _ActivityDetailPageState extends State<ActivityDetailPage>{
  final StravaService stravaService = StravaService();
  late int _currentIndex;

  @override
  void initState(){
    super.initState();
    _currentIndex=0;
  }

  void _onElevationPointSelected(int index){
    setState(() {
      _currentIndex=index;
    });
  }

  void _downloadGpx(BuildContext context) async{
    try{
      await stravaService.downloadGpx(widget.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fichier GPX téléchargé avec succès')),
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement du GPX: $e activité id : ${widget.id}')),
      );
    }
  }

   void _downloadTcx(BuildContext context) async{
    try{
      await stravaService.downloadTCX(widget.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fichier TCX téléchargé avec succès')),
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement du TCX: $e activité id : ${widget.id}')),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    const LatLng  startPoint = LatLng(46.2289085, 7.2991633);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distance: ${(widget.distance/10).toStringAsFixed(1)} km'),
            Text('Dénivelé: ${widget.elevation.toStringAsFixed(0)} m'),
            Text('Description: ${widget.description}'),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomGauge(

                  value: widget.technicalLevel,
                  maxValue: 5.0,
                  label: 'Technique',
                  color: Colors.red,
                ),
                const SizedBox(width: 16),
                CustomGauge(
                  value: widget.landscapeLevel,
                  maxValue: 5.0,
                  label: 'Paysage',
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                CustomGauge(
                  value: widget.physicalLevel,
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
                  initialCenter: widget.routePoints.isNotEmpty ? widget.routePoints[_currentIndex] :  const LatLng(46.9889, 6.9293),
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
                        points: widget.routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      if(widget.routePoints.isNotEmpty) ...[
                        Marker(
                          point: widget.routePoints[_currentIndex],
                          child: Builder(builder: (context) =>const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 30,
                          ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: startPoint,
                        radius: 1000,
                        color: Colors.black.withOpacity(1.0),
                        useRadiusInMeter: true,
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevationProfile(routePoints: widget.routePoints, onPointSelected: _onElevationPointSelected),
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