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

  Activity({
    required this.id,
    required this.name,
    required this.distance,
    required this.elevationGain,
    required this.description,
    required this.athlete,
    required this.summaryPolyline,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id_str'],
      name: json['name'],
      distance: json['distance']/100,
      elevationGain: json['elevation_gain'],
      description: json['description'] ?? '',
      athlete: Athlete.fromJson(json['athlete']),
      summaryPolyline: json['map']['summary_polyline'],
    );
  }
}
