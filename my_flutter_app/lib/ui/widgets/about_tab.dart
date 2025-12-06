import 'package:flutter/material.dart';
import '../../../../data/models/CompanyInfoModel.dart';

class AboutTab extends StatelessWidget {
  final CompanyInfoModel companyInfo;  // ✅ استخدمنا CompanyInfoModel
  const AboutTab({super.key, required this.companyInfo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Us',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                companyInfo.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const Divider(height: 32),
              _buildInfoRow(Icons.location_on, 'Location', companyInfo.location),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.email, 'Email', companyInfo.email),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.phone, 'Phone', companyInfo.phone),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.language, 'Website', companyInfo.website, isLink: true),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.calendar_today, 'Founded', companyInfo.founded),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.people, 'Company Size', companyInfo.size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isLink ? const Color(0xff3B82F6) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}