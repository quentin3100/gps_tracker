import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final double distance;
  final double elevation;
  final List<LatLng> routePoints;
  final VoidCallback onTap; // Ajouter un paramètre onTap

  const ActivityCard({
    super.key,
    required this.title,
    required this.distance,
    required this.elevation,
    required this.routePoints,
    required this.onTap, // Ajouter le paramètre onTap
  });

  @override
  Widget build(BuildContext context) {
    const LatLng startingPoint = LatLng(46.2289085, 7.2991633);
    return GestureDetector( // Utiliser GestureDetector pour gérer le clic
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(title),
              subtitle: Text('Distance: ${(distance / 10).toStringAsFixed(1)} km, Dénivelé: ${elevation.toStringAsFixed(0)} m'),
            ),
            Container(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: routePoints.first,
                  initialZoom: 12.0,
                  minZoom: 12.0,
                  maxZoom: 12.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: startingPoint,
                        radius: 1000,
                        color: Colors.black.withOpacity(1.0),
                        useRadiusInMeter: true,
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
