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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart'as path;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';



class StravaService {
  static late String accessToken;
  static late String refreshToken;
  static late String clientId;
  static late String clientSecret;

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  StravaService(){
    _loadConfig();
    loadTokens();
  }

  //Charger le fichier de configuration
  Future<void>_loadConfig() async{
    final String configString = await rootBundle.loadString('assets/config.json');
    final Map<String, dynamic> config = json.decode(configString);
    accessToken = (await _retrieveFromPreferences('access_token')) ?? '';
    refreshToken = config['refresh_token'];
    clientId = config['client_id'];
    clientSecret=config['client_secret'];
  }

  Future<void> _storeInPreferences(String key, String value)async{
    if(kIsWeb){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }else if (Platform.isAndroid || Platform.isIOS){
      await storage.write(key: key, value: value);
    }
  }

  Future<String?> _retrieveFromPreferences(String key) async{
    if(kIsWeb){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    else{
      return await storage.read(key: key);
    }
  }

  //Rafraichir le token
  Future<void> refreshAccessToken()async{
    final String configString = await rootBundle.loadString('assets/config.json');
    final Map<String, dynamic> config = json.decode(configString);
    accessToken = (await _retrieveFromPreferences('access_token')) ?? '';
    refreshToken = config['refresh_token'];
    clientId = config['client_id'];
    clientSecret=config['client_secret'];
    final response = await http.post(
      Uri.parse('https://www.strava.com/oauth/token'),
      headers: {
        'Content-type':'application/json',
      },
      body: json.encode({
        'client_id':clientId,
        'client_secret':clientSecret,
        'refresh_token':refreshToken,
        'grant_type':'refresh_token'
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
    await _storeInPreferences('access_token',accessToken);
    await _storeInPreferences('refresh_token',refreshToken);
  }

  Future<void> loadTokens() async {
    accessToken = (await _retrieveFromPreferences('access_token')) ?? '';
    refreshToken = (await _retrieveFromPreferences('refresh_token')) ?? '';
  }

  //Récupérer les itinéraires
  Future<List<Activity>> fetchRoutes(String athleteId) async{
    await refreshAccessToken();
    await _loadConfig();
    if(accessToken.isEmpty){
      throw Exception('Token d\'accès introuvable');
    }

    final url = 'https://www.strava.com/api/v3/athletes/$athleteId/routes';


    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization':'Bearer $accessToken',
      }
    );

    if(response.statusCode == 401){
      await refreshAccessToken();

      response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',  
      }
    );
    }
    if(response.statusCode == 200){
      final List<dynamic> activitiesJson = json.decode(response.body);
      List<Activity> activities = activitiesJson.map((json)=>Activity.fromJson(json)).toList();
      return activities;
      
      
    }else{
      throw Exception('Echec du chargement des itinéraires : ${response.statusCode}');
    }
  }

  Future<void> downloadTCX(String routeId)async{
    final url = 'https://www.strava.com/api/v3/routes/$routeId/export_tcx';
    try{
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':'Bearer $accessToken',
        }
      );
      if(response.statusCode == 200){
        Directory? downloadsDirectory;
        if(Platform.isAndroid){
          downloadsDirectory=await getExternalStorageDirectory();
        }else if(Platform.isIOS){
          downloadsDirectory = await getApplicationDocumentsDirectory();
        }

        if(downloadsDirectory!=null){
          final downloadPath = path.join(downloadsDirectory.path,'Download');
          final downloadDir = Directory(downloadPath);

          if(! await downloadDir.exists()){
            await downloadDir.create(recursive: true);
          }
          final filePath = path.join(downloadPath, 'route_$routeId.tcx');
           
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          if(await file.exists()){
            debugPrint('Fichier téléchargé avec succès à : $filePath');

          PermissionStatus status = await Permission.manageExternalStorage.request();

          if(status.isGranted){
          final result = await OpenFile.open(filePath);
          debugPrint('Ouverture du fichier: ${result.message}');
          }else{
            debugPrint('Permission non accordée');
          }
          }else{
            debugPrint('Le fichier n\'a pas été trouvé après la création.');
          }

        }else{
           debugPrint('Répertoire de téléchargement non trouvé.');
        }

      
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
     
    // Vérification du statut de la réponse
    if (response.statusCode == 200) {
      Directory? downloadsDirectory;
      
      // Déterminer le répertoire de téléchargement
      if (Platform.isAndroid) {
        //downloadsDirectory = Directory('/storage/emulated/0/Download');
        downloadsDirectory=await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory != null) {
        //final filePath = path.join(downloadsDirectory.path, 'route_$routeId.gpx');
        final downloadPath = path.join(downloadsDirectory.path,'Download');
        final downloadDir = Directory(downloadPath);

        if(!await downloadDir.exists()){
          await downloadDir.create(recursive: true);
        }

        final filePath = path.join(downloadPath, 'route_$routeId.gpx');
        final file = File(filePath);

        // Écrire le contenu dans le fichier
        await file.writeAsBytes(response.bodyBytes);

        // Vérification si le fichier a été créé
        if (await file.exists()) {
          debugPrint('Fichier téléchargé avec succès à : $filePath');

          PermissionStatus status = await Permission.manageExternalStorage.request();

          if(status.isGranted){
          final result = await OpenFile.open(filePath);
          debugPrint('Ouverture du fichier: ${result.message}');
          }else{
            debugPrint('Permission non accordée');
          }

          

        } else {
          debugPrint('Le fichier n\'a pas été trouvé après la création.');
        }
      } else {
        debugPrint('Répertoire de téléchargement non trouvé.');
      }
    } else {
      debugPrint('Erreur de téléchargement: ${response.statusCode}');
      throw Exception('Erreur lors du téléchargement du fichier GPX');
    }
  } catch (e) {
    debugPrint('Erreur lors du téléchargement du GPX: $e, activité id : $routeId');
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