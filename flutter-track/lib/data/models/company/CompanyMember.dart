class CompanyMember {
  String name;
  String role;
  String email;

  CompanyMember({
    required this.name,
    required this.role,
    required this.email,
  });

  factory CompanyMember.fromJson(Map<String, dynamic> json) {
    return CompanyMember(
      name: json['name'],
      role: json['role'],
      email: json['email'],
    );
  }
}
