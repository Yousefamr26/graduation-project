class CompanyActivity {
  String action;
  String detail;
  String date;

  CompanyActivity({
    required this.action,
    required this.detail,
    required this.date,
  });

  factory CompanyActivity.fromJson(Map<String, dynamic> json) {
    return CompanyActivity(
      action: json['action'],
      detail: json['detail'],
      date: json['date'],
    );
  }
}
