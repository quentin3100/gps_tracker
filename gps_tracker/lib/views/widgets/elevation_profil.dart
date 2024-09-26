
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:gps_tracker/services/strava_service.dart';
import 'package:geolocator/geolocator.dart';

class ElevationProfile extends StatefulWidget {
  final List<LatLng> routePoints;

  const ElevationProfile({super.key, required this.routePoints});

  @override
  _ElevationProfileState createState() => _ElevationProfileState();
}

class _ElevationProfileState extends State<ElevationProfile> {
  List<double> elevationData = [];
  bool loading = true;
  final StravaService stravaService = StravaService();

  @override
  void initState() {
    super.initState();
    _fetchElevationData();
  }

  Future<void> _fetchElevationData() async {
    try {
      elevationData = await stravaService.getElevations(widget.routePoints);
    } catch (e) {
      print("Error fetching elevation data: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: 200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (elevationData.isEmpty) {
      return Container(
        height: 200,
        child: const Center(child: Text("Aucune donnée d'élévation disponible.")),
      );
    }

    List<FlSpot> elevationPoints = [];
    double totalDistance = 0.0;

    for (int i = 0; i < widget.routePoints.length; i++) {
      // Add elevation data to the FlSpot list
      elevationPoints.add(FlSpot(totalDistance, elevationData[i]));

      // Calculate distance to the next point if not the last point
      if (i < widget.routePoints.length - 1) {
        totalDistance += calculateDistance(widget.routePoints[i], widget.routePoints[i + 1]);
      }
    }

    double midpoint=totalDistance/2;

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1), // Format pour afficher une décimale
                    style: const TextStyle(fontSize: 10, color: Colors.black),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                   if (value == 0.0) {
                  return const Text(
                    "0.0 km",
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  );
                } else if (value == midpoint) {
                  return Text(
                    "${value.toStringAsFixed(1)} km",
                    style: const TextStyle(fontSize: 10, color: Colors.black),
                  );
                } else if (value == totalDistance) {
                  return Text(
                    "${value.toStringAsFixed(1)} km",
                    style: const TextStyle(fontSize: 10, color: Colors.black),
                  );
                }
                // Return empty widget for other values
                return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          minX: 0,
          maxX: totalDistance,
          minY: elevationData.reduce((a,b)=>a<b?a:b) - elevationData.reduce((a,b)=>a<b?a:b)*0.10,
          maxY: elevationPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1, // +10% de la valeur max
          lineBarsData: [
            LineChartBarData(
              spots: elevationPoints,
              isCurved: true,
              color: Colors.orange,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.3)
                ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour calculer la distance entre deux points
  double calculateDistance(LatLng point1, LatLng point2) {
     return Geolocator.distanceBetween(
    point1.latitude, point1.longitude,
    point2.latitude, point2.longitude
  ) / 1000; // Convert to kilometers
  }
}
