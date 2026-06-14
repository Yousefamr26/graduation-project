class PartnershipModel {
  final String? id;
  final String companyId;
  final String companyName;
  final String industry;
  final String partnershipType;
  final String contactPerson;
  final String email;
  final String phone;
  final String website;
  final String location;
  final String details;
  final String? status;

  PartnershipModel({
    this.id,
    required this.companyId,
    required this.companyName,
    required this.industry,
    required this.partnershipType,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.website,
    required this.location,
    required this.details,
    this.status,
  });

  factory PartnershipModel.fromJson(Map<String, dynamic> json) {
    return PartnershipModel(
      id: json['id']?.toString(),
      companyId: json['companyId'] ?? '',
      companyName: json['companyName'] ?? '',
      industry: json['industry'] ?? '',
      partnershipType: json['partnershipType'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      location: json['location'] ?? '',
      details: json['details'] ?? '',
      status: json['status']?.toString().toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'industry': industry,
      'partnershipType': partnershipType,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'website': website,
      'location': location,
      'details': details,
      if (status != null) 'status': status,
    };
  }

  PartnershipModel copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? industry,
    String? partnershipType,
    String? contactPerson,
    String? email,
    String? phone,
    String? website,
    String? location,
    String? details,
    String? status,
  }) {
    return PartnershipModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      industry: industry ?? this.industry,
      partnershipType: partnershipType ?? this.partnershipType,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      location: location ?? this.location,
      details: details ?? this.details,
      status: status ?? this.status,
    );
  }
}
