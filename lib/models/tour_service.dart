class TourService {
  final int id;
  final String title;
  final String description;
  final List<String> photos;
  final double price;
  final int minParticipants;
  final int maxParticipants;
  final int durationMinutes;
  final String category;
  final String guideName;
  final String? guideProfilePicture;
  final double averageRating;
  final int reviewCount;
  final List<TourSchedule> schedules;
  final List<ServiceFeature> features;
  final MeetingLocation? meetingLocation;

  TourService({
    required this.id,
    required this.title,
    required this.description,
    required this.photos,
    required this.price,
    required this.minParticipants,
    required this.maxParticipants,
    required this.durationMinutes,
    required this.category,
    required this.guideName,
    this.guideProfilePicture,
    required this.averageRating,
    required this.reviewCount,
    required this.schedules,
    required this.features,
    this.meetingLocation,
  });

  factory TourService.fromJson(Map<String, dynamic> json) {
    return TourService(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      minParticipants: json['minParticipants'] ?? 1,
      maxParticipants: json['maxParticipants'] ?? 10,
      durationMinutes: json['durationMinutes'] ?? 0,
      category: json['category'] ?? '',
      guideName: json['guideName'] ?? 'Guía Localy',
      guideProfilePicture: json['guideProfilePicture'],
      averageRating:
          double.tryParse(json['averageRating']?.toString() ?? '') ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .map((item) => TourSchedule.fromJson(item))
          .toList(),
      features: (json['features'] as List<dynamic>? ?? [])
          .map((item) => ServiceFeature.fromJson(item))
          .toList(),
      meetingLocation: json['meetingLocation'] == null
          ? null
          : MeetingLocation.fromJson(json['meetingLocation']),
    );
  }
}

class TourSchedule {
  final String day;
  final String startTime;

  TourSchedule({
    required this.day,
    required this.startTime,
  });

  factory TourSchedule.fromJson(Map<String, dynamic> json) {
    return TourSchedule(
      day: json['day'] ?? '',
      startTime: json['startTime'] ?? '',
    );
  }
}

class ServiceFeature {
  final String name;
  final bool included;

  ServiceFeature({
    required this.name,
    required this.included,
  });

  factory ServiceFeature.fromJson(Map<String, dynamic> json) {
    return ServiceFeature(
      name: json['name'] ?? '',
      included: json['included'] ?? false,
    );
  }
}

class MeetingLocation {
  final String city;
  final String meetingAddress;
  final double? latitude;
  final double? longitude;

  MeetingLocation({
    required this.city,
    required this.meetingAddress,
    this.latitude,
    this.longitude,
  });

  factory MeetingLocation.fromJson(Map<String, dynamic> json) {
    return MeetingLocation(
      city: json['city'] ?? '',
      meetingAddress: json['meetingAddress'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
