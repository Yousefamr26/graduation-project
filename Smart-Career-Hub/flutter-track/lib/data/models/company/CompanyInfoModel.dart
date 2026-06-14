class CompanyInfoModel {
  String name;
  String industry;
  String description;
  String location;
  String email;
  String phone;
  String website;
  String founded;
  String size;
  String? logo;

  CompanyInfoModel({
    required this.name,
    required this.industry,
    required this.description,
    required this.location,
    required this.email,
    required this.phone,
    required this.website,
    required this.founded,
    required this.size,
    this.logo,
  });

  factory CompanyInfoModel.fromJson(Map<String, dynamic> json) {
    return CompanyInfoModel(
      name: json['name'],
      industry: json['industry'],
      description: json['description'],
      location: json['location'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      founded: json['founded'],
      size: json['size'],
      logo: json['logo'],
    );
  }
}
