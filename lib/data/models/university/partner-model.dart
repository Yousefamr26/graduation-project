class PartnerModel {
  final String id;
  final String name;
  final String industry;
  final String status; // Active, Pending, Inactive
  final String partnerSince;
  final int eventsHosted;
  final int studentsReached;
  final String? logoPath;
  final String? description;
  final String? contactPerson;
  final String? contactEmail;
  final String? contactPhone;
  final String? website;
  final List<String>? benefits;

  PartnerModel({
    required this.id,
    required this.name,
    required this.industry,
    required this.status,
    required this.partnerSince,
    required this.eventsHosted,
    required this.studentsReached,
    this.logoPath,
    this.description,
    this.contactPerson,
    this.contactEmail,
    this.contactPhone,
    this.website,
    this.benefits,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'industry': industry,
      'status': status,
      'partnerSince': partnerSince,
      'eventsHosted': eventsHosted,
      'studentsReached': studentsReached,
      'logoPath': logoPath,
      'description': description,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'benefits': benefits,
    };
  }

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'],
      name: json['name'],
      industry: json['industry'],
      status: json['status'],
      partnerSince: json['partnerSince'],
      eventsHosted: json['eventsHosted'],
      studentsReached: json['studentsReached'],
      logoPath: json['logoPath'],
      description: json['description'],
      contactPerson: json['contactPerson'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      website: json['website'],
      benefits: json['benefits'] != null
          ? List<String>.from(json['benefits'])
          : null,
    );
  }

  PartnerModel copyWith({
    String? id,
    String? name,
    String? industry,
    String? status,
    String? partnerSince,
    int? eventsHosted,
    int? studentsReached,
    String? logoPath,
    String? description,
    String? contactPerson,
    String? contactEmail,
    String? contactPhone,
    String? website,
    List<String>? benefits,
  }) {
    return PartnerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      status: status ?? this.status,
      partnerSince: partnerSince ?? this.partnerSince,
      eventsHosted: eventsHosted ?? this.eventsHosted,
      studentsReached: studentsReached ?? this.studentsReached,
      logoPath: logoPath ?? this.logoPath,
      description: description ?? this.description,
      contactPerson: contactPerson ?? this.contactPerson,
      contactEmail: contactEmail ?? this.contactPhone,
      contactPhone: contactPhone ?? this.contactPhone,
      website: website ?? this.website,
      benefits: benefits ?? this.benefits,
    );
  }
}