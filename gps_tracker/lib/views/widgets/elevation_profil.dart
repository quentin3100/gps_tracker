import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:gps_tracker/services/strava_service.dart';
import 'package:geolocator/geolocator.dart';

class ElevationProfile extends StatefulWidget {
  final List<LatLng> routePoints;
  final Function(int) onPointSelected;

  const ElevationProfile({
    Key? key,
    required this.routePoints,
    required this.onPointSelected,
  }) : super(key: key);

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
      elevationPoints.add(FlSpot(totalDistance, elevationData[i]));
      if (i < widget.routePoints.length - 1) {
        totalDistance += calculateDistance(widget.routePoints[i], widget.routePoints[i + 1]);
      }
    }

    return Container(
      height: 200,
      width: 300,
      alignment: Alignment.center,
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
                    value.toStringAsFixed(1),
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
                  // Afficher les titres tous les 20 km
                  if (value % 20 == 0) {
                    return Text(
                      "${value.toStringAsFixed(1)} km",
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                    );
                  } else {
                    return const Text(""); // Retourner un texte vide pour d'autres valeurs
                  }
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          minX: 0,
          maxX: totalDistance,
          minY: elevationData.reduce((a, b) => a < b ? a : b) * 0.9,
          maxY: elevationPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: elevationPoints,
              isCurved: true,
              color: Colors.orange,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((spot) {
                  return LineTooltipItem(
                    'Altitude: ${spot.y.toStringAsFixed(1)} m\nKm: ${spot.x.toStringAsFixed(1)} km',
                    const TextStyle(color: Colors.white, fontSize: 10),
                  );
                }).toList();
              },
            ),
            touchCallback: (event, response) {
             if (response != null && response.lineBarSpots != null) {
                final spot = response.lineBarSpots!.first;
                double touchX = spot.x; // Distance touchée

                // Trouver l'indice du point le plus proche
                int closestIndex = 0;
                for (int i = 0; i < elevationPoints.length; i++) {
                  if (elevationPoints[i].x > touchX) {
                    closestIndex = i > 0 ? i - 1 : 0; // Prendre l'indice précédent
                    break;
                  }
                }

                // Si touchX correspond à la dernière valeur, on prend le dernier index
                if (closestIndex == 0 && elevationPoints[0].x > touchX) {
                  closestIndex = 0;
                } else if (closestIndex == elevationPoints.length - 1) {
                  closestIndex = elevationPoints.length - 1;
                }

                // Appeler la fonction de sélection avec l'indice du point de la route
                widget.onPointSelected(closestIndex);
                setState(() {}); // Re-render pour mettre à jour l'état si nécessaire
              }
            },
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }

  // Fonction pour calculer la distance entre deux points
  double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    ) / 1000; // Convertir en kilomètres
  }
}
