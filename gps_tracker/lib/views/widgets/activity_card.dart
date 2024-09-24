import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ActivityCard extends StatelessWidget{
  final String title;
  final double distance;
  final double elevation;

  const ActivityCard({super.key, 
    required this.title,
    required this.distance,
    required this.elevation,
  });

  @override
  Widget build(BuildContext context){
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(title),
            subtitle: Text('Distance: ${distance.toStringAsFixed(1)} km, Dénivelé: ${elevation.toStringAsFixed(0)} m'),
          ),
          Container(
            height: 200,
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(46.992979, 6.931933),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a','b','c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        const LatLng(46.992979, 6.931933), //Point A (Neuchâtel)
                        const LatLng(46.996450, 6.938223), //Point B (point statique)
                      ],
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    )
                  ],
                )
                
              ],
            ),
          )
        ],
      ),
    );
  }
}