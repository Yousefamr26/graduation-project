class UniversityModel {
  final String id;
  final String name;
  final String abbreviation;
  final String? logoPath;
  final String? coverImagePath;
  final String location;
  final String email;
  final String phone;
  final String website;
  final String about;
  final int totalStudents;
  final int totalPrograms;
  final double successRate;
  final int totalPartners;
  final String? establishedYear;
  final List<String>? specializations;
  final Map<String, dynamic>? socialMedia;

  UniversityModel({
    required this.id,
    required this.name,
    required this.abbreviation,
    this.logoPath,
    this.coverImagePath,
    required this.location,
    required this.email,
    required this.phone,
    required this.website,
    required this.about,
    required this.totalStudents,
    required this.totalPrograms,
    required this.successRate,
    required this.totalPartners,
    this.establishedYear,
    this.specializations,
    this.socialMedia,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'logoPath': logoPath,
      'coverImagePath': coverImagePath,
      'location': location,
      'email': email,
      'phone': phone,
      'website': website,
      'about': about,
      'totalStudents': totalStudents,
      'totalPrograms': totalPrograms,
      'successRate': successRate,
      'totalPartners': totalPartners,
      'establishedYear': establishedYear,
      'specializations': specializations,
      'socialMedia': socialMedia,
    };
  }

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'],
      name: json['name'],
      abbreviation: json['abbreviation'],
      logoPath: json['logoPath'],
      coverImagePath: json['coverImagePath'],
      location: json['location'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      about: json['about'],
      totalStudents: json['totalStudents'],
      totalPrograms: json['totalPrograms'],
      successRate: json['successRate'].toDouble(),
      totalPartners: json['totalPartners'],
      establishedYear: json['establishedYear'],
      specializations: json['specializations'] != null
          ? List<String>.from(json['specializations'])
          : null,
      socialMedia: json['socialMedia'],
    );
  }

  UniversityModel copyWith({
    String? id,
    String? name,
    String? abbreviation,
    String? logoPath,
    String? coverImagePath,
    String? location,
    String? email,
    String? phone,
    String? website,
    String? about,
    int? totalStudents,
    int? totalPrograms,
    double? successRate,
    int? totalPartners,
    String? establishedYear,
    List<String>? specializations,
    Map<String, dynamic>? socialMedia,
  }) {
    return UniversityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      logoPath: logoPath ?? this.logoPath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      location: location ?? this.location,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      about: about ?? this.about,
      totalStudents: totalStudents ?? this.totalStudents,
      totalPrograms: totalPrograms ?? this.totalPrograms,
      successRate: successRate ?? this.successRate,
      totalPartners: totalPartners ?? this.totalPartners,
      establishedYear: establishedYear ?? this.establishedYear,
      specializations: specializations ?? this.specializations,
      socialMedia: socialMedia ?? this.socialMedia,
    );
  }
}