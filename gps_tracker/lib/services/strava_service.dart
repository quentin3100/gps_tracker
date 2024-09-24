import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gps_tracker/models/activity.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:path_provider/path_provider.dart';


class StravaService {
  static late String accessToken;
  static late String refreshToken;
  static late String clientId;
  static late String clientSecret;

  final storage = const FlutterSecureStorage();

  StravaService(){
    _loadConfig();
  }

  //Charger le fichier de configuration
  Future<void>_loadConfig() async{
    final String configString = await rootBundle.loadString('assets/config.json');
    final Map<String, dynamic> config = json.decode(configString);
    accessToken = config['access_token'];
    refreshToken = config['refresh_token'];
    clientId = config['client_id'];
    clientSecret=config['client_secret'];
  }

  //Rafraichir le token
  Future<void> refreshAccessToken()async{
    final response = await http.post(
      Uri.parse('https://www.strava.com/oauth/token'),
      headers: {
        'Content-type':'application/json',
      },
      body: json.encode({
        'client_id':clientId,
        'client_secret':clientSecret,
        'refresh_token':refreshToken,
      }),
    );

    if(response.statusCode==200){
      final data = json.decode(response.body);
      accessToken=data['access_token'];
      refreshToken=data['refresh_token'];
      await storeTokens(accessToken,refreshToken);
    }else{
      throw Exception('Echec du rafraichissement du token : ${response.statusCode}');
    }
  }

  //Stockage des tokens
  Future<void> storeTokens(String accessToken, String refreshToken) async{
    await storage.write(key: 'access_token', value: accessToken);
    await storage.write(key: 'refresh_token', value: refreshToken);
  }

  //Récupérer les itinéraires
  Future<List<Activity>> fetchRoutes(String athleteId) async{
    await _loadConfig();
    if(accessToken.isEmpty){
      throw Exception('Token d\'accès introuvable');
    }

    final url = 'https://www.strava.com/api/v3/athletes/$athleteId/routes';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization':'Bearer $accessToken',
      }
    );

    if(response.statusCode == 401){
      await refreshAccessToken();
      return await fetchRoutes(athleteId);
    }
    if(response.statusCode == 200){
      final List<dynamic> activitiesJson = json.decode(response.body);
      List<Activity> activities = activitiesJson.map((json)=>Activity.fromJson(json)).toList();
      return activities;
      
      
    }else{
      throw Exception('Echec du chargement des itinéraires : ${response.statusCode}');
    }
  }

  Future<void> downloadTCX(int routeId)async{
    final url = 'https://www.strava.com/api/v3/routes/$routeId/export_tcx';
    try{
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':'Bearer $accessToken',
        }
      );
      if(response.statusCode == 200){
        final directory=await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/route_$routeId.tcx';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('Fichier TCX téléchargé avec succès à : $filePath');
      }else{
        throw Exception('Erreur lors du téléchargement du fichier TCX');
      }
      
    }catch(e){
      debugPrint('Erreur lors du téléchargement du TCX: $e');
      throw Exception('Erreur lors du téléchargement du TCX');
    }
  }

  Future<void> downloadGpx(String routeId) async{
    final url = 'https://www.strava.com/api/v3/routes/$routeId/export_gpx'; 
    try{
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':'Bearer $accessToken',
        }
      );
      if(response.statusCode==200){
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/route_$routeId.gpx';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('Fichier GPX téléchargé avec succès à : $filePath');
      }else{
        throw Exception('Erreur lors du téléchargement du fichier GPX');
      }
    }catch(e){
      debugPrint('Erreur lors du téléchargement du GPX: $e activité id : $routeId');
      throw Exception('Erreur lors du téléchargement du GPX');
    }
  }

// Fonction pour décoder le polyline en une liste de points LatLng
  List<LatLng> decodePolyline(String polyline) {
  List<LatLng> points = [];
  
  PolylinePoints polylinePoints = PolylinePoints();
  List<PointLatLng>decodedPoints = polylinePoints.decodePolyline(polyline);

  if(decodedPoints.isNotEmpty){
    for(var point in decodedPoints){
      points.add(LatLng(point.latitude, point.longitude));
    }
  }
  return points;
}

  
}