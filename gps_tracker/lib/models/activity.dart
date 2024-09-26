class Athlete {
  final int id;
  final String firstname;
  final String lastname;
  final String profileMedium;
  final String profile;

  Athlete({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.profileMedium,
    required this.profile,
  });

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      profileMedium: json['profile_medium'],
      profile: json['profile'],
    );
  }
}

class Activity {
  final String id;
  final String name;
  final double distance;
  final double elevationGain;
  final String description;
  final Athlete athlete;
  final String summaryPolyline;
  final int type; //1 = vélo, 2 = course
  final int subType;

  Activity({
    required this.id,
    required this.name,
    required this.distance,
    required this.elevationGain,
    required this.description,
    required this.athlete,
    required this.summaryPolyline,
    required this.type,
    required this.subType,
  });

  // Méthode pour obtenir une chaîne de caractère descriptive du type
  String getSportType() {
    switch (type) {
      case 1:
        return 'Ride';  // Vélo
      case 2:
        return 'Run';  // Course à pied
      case 4:
        return 'Hike'; // Randonnée
      default:
        return 'Unknown';
    }
  }

  // Méthode pour obtenir une chaîne de caractère descriptive du sous-type
  String getSubType() {
    switch (subType) {
      case 1:
        return 'Road';  // Route
      case 2:
        return 'Mountain Bike';  // VTT
      case 3:
        return 'Cross';  // Cyclo-cross
      case 4:
        return 'Trail';  // Trail (pour course ou vélo)
      case 5:
        return 'Mixed';  // Mixte
      default:
        return 'Unknown';
    }
  }


  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id_str'],
      name: json['name'],
      distance: json['distance']/100,
      elevationGain: json['elevation_gain'],
      description: json['description'] ?? '',
      athlete: Athlete.fromJson(json['athlete']),
      summaryPolyline: json['map']['summary_polyline'],
      type: json['type'],
      subType: json['sub_type'],
    );
  }
}
