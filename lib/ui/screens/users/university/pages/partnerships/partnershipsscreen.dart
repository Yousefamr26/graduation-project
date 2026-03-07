import 'package:flutter/material.dart';
import 'dart:io';

import '../../../../../../data/models/university/partner-model.dart';

class PartnershipsScreen extends StatefulWidget {
  const PartnershipsScreen({super.key});

  @override
  State<PartnershipsScreen> createState() => _PartnershipsScreenState();
}

class _PartnershipsScreenState extends State<PartnershipsScreen> {
  final List<PartnerModel> partners = [
    PartnerModel(
      id: '1',
      name: 'Vodafone',
      industry: 'Telecommunications',
      status: 'Active',
      partnerSince: '2023',
      eventsHosted: 8,
      studentsReached: 156,
      description: 'Leading telecommunications company providing mobile and fixed services',
      contactPerson: 'Ahmed Hassan',
      contactEmail: 'ahmed.hassan@vodafone.com',
      contactPhone: '+20 100 123 4567',
      website: 'www.vodafone.com.eg',
      benefits: ['Internship opportunities', 'Training programs', 'Career workshops'],
    ),
    PartnerModel(
      id: '2',
      name: 'Microsoft',
      industry: 'AI & Cloud Computing',
      status: 'Active',
      partnerSince: '2022',
      eventsHosted: 12,
      studentsReached: 245,
      description: 'Global technology leader in AI, cloud, and enterprise solutions',
      contactPerson: 'Sara Mohamed',
      contactEmail: 'sara.mohamed@microsoft.com',
      contactPhone: '+20 100 234 5678',
      website: 'www.microsoft.com',
      benefits: ['Azure certifications', 'AI workshops', 'Cloud training'],
    ),
    PartnerModel(
      id: '3',
      name: 'Orange Digital',
      industry: 'Digital Services',
      status: 'Active',
      partnerSince: '2024',
      eventsHosted: 5,
      studentsReached: 89,
      description: 'Digital services and telecommunications provider',
      contactPerson: 'Khaled Ali',
      contactEmail: 'khaled.ali@orange.com',
      contactPhone: '+20 100 345 6789',
      website: 'www.orange.eg',
      benefits: ['Digital skills training', 'Innovation labs', 'Mentorship'],
    ),
    PartnerModel(
      id: '4',
      name: 'TechCorp Solutions',
      industry: 'Software Development',
      status: 'Active',
      partnerSince: '2023',
      eventsHosted: 10,
      studentsReached: 198,
      description: 'Software development and IT consulting firm',
      contactPerson: 'Layla Ibrahim',
      contactEmail: 'layla.ibrahim@techcorp.com',
      contactPhone: '+20 100 456 7890',
      website: 'www.techcorp.com',
      benefits: ['Coding bootcamps', 'Project collaborations', 'Job placements'],
    ),
    PartnerModel(
      id: '5',
      name: 'IBM',
      industry: 'Enterprise Solutions',
      status: 'Pending',
      partnerSince: '2024',
      eventsHosted: 3,
      studentsReached: 67,
      description: 'Enterprise technology and consulting solutions',
      contactPerson: 'Omar Youssef',
      contactEmail: 'omar.youssef@ibm.com',
      contactPhone: '+20 100 567 8901',
      website: 'www.ibm.com',
      benefits: ['Enterprise training', 'Research programs', 'Tech talks'],
    ),
    PartnerModel(
      id: '6',
      name: 'Amazon Web Services',
      industry: 'Cloud Services',
      status: 'Active',
      partnerSince: '2023',
      eventsHosted: 7,
      studentsReached: 134,
      description: 'Cloud computing and web services platform',
      contactPerson: 'Rana Waleed',
      contactEmail: 'rana.waleed@aws.com',
      contactPhone: '+20 100 678 9012',
      website: 'www.aws.amazon.com',
      benefits: ['AWS certifications', 'Cloud workshops', 'Free credits'],
    ),
  ];

  String searchText = "";
  String selectedFilter = "All";
  List<PartnerModel> filteredPartners = [];

  @override
  void initState() {
    super.initState();
    applyFilters();
  }

  void applyFilters() {
    setState(() {
      filteredPartners = partners.where((partner) {
        bool matchesFilter = true;

        if (selectedFilter == "Active") {
          matchesFilter = partner.status == "Active";
        } else if (selectedFilter == "Pending") {
          matchesFilter = partner.status == "Pending";
        } else if (selectedFilter == "Inactive") {
          matchesFilter = partner.status == "Inactive";
        }

        if (searchText.isEmpty) return matchesFilter;

        final searchLower = searchText.toLowerCase();
        return matchesFilter &&
            (partner.name.toLowerCase().contains(searchLower) ||
                partner.industry.toLowerCase().contains(searchLower));
      }).toList();
    });
  }

  int get totalPartners => partners.length;
  int get activePartners =>
      partners.where((p) => p.status == "Active").length;
  int get totalEvents =>
      partners.fold(0, (sum, partner) => sum + partner.eventsHosted);
  int get totalStudents =>
      partners.fold(0, (sum, partner) => sum + partner.studentsReached);

  void _showPartnerDetails(PartnerModel partner) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff1676C4), Color(0xff0d5fa3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    _buildLogoWidget(partner, size: 60),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partner.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            partner.industry,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailStatCard(
                              'Events Hosted',
                              partner.eventsHosted.toString(),
                              Icons.event,
                              Colors.blue,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildDetailStatCard(
                              'Students Reached',
                              partner.studentsReached.toString(),
                              Icons.people,
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Description
                      if (partner.description != null) ...[
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          partner.description!,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 20),
                      ],
                      // Contact Info
                      Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      if (partner.contactPerson != null)
                        _buildDetailRow(Icons.person, 'Contact Person', partner.contactPerson!),
                      if (partner.contactEmail != null)
                        _buildDetailRow(Icons.email, 'Email', partner.contactEmail!),
                      if (partner.contactPhone != null)
                        _buildDetailRow(Icons.phone, 'Phone', partner.contactPhone!),
                      if (partner.website != null)
                        _buildDetailRow(Icons.language, 'Website', partner.website!),
                      // Benefits
                      if (partner.benefits != null && partner.benefits!.isNotEmpty) ...[
                        SizedBox(height: 20),
                        Text(
                          'Partnership Benefits',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 12),
                        ...partner.benefits!.map((benefit) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Color(0xff1676C4)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoWidget(PartnerModel partner, {double size = 50}) {
    if (partner.logoPath == null || partner.logoPath!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Color(0xff1676C4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.business,
          color: Color(0xff1676C4),
          size: size * 0.6,
        ),
      );
    }

    if (partner.logoPath!.startsWith("http")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          partner.logoPath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image, color: Colors.grey[500]),
            );
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(partner.logoPath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: Colors.grey[500]),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Add Partnership screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Add New Partnership feature coming soon!')),
          );
        },
        backgroundColor: Color(0xff1676C4),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Add New Partnership', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildAppBar(),
          _buildStatsCards(),
          _buildSearchAndFilter(),
          _buildPartnersList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xff1676C4),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 80,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Partnership Integration",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Manage company partnerships and collaborations",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              totalPartners.toString(),
              "Total Partners",
              Icons.business,
              Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              totalEvents.toString(),
              "Joint Events",
              Icons.event,
              Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              totalStudents.toString(),
              "Students Reached",
              Icons.people,
              Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              activePartners.toString(),
              "Active Partners",
              Icons.check_circle,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search partners...",
                prefixIcon: const Icon(Icons.search, color: Color(0xff1676C4)),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xff1676C4), width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  applyFilters();
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: DropdownButton<String>(
              value: selectedFilter,
              underline: SizedBox(),
              items: const [
                DropdownMenuItem(value: "All", child: Text("All")),
                DropdownMenuItem(value: "Active", child: Text("Active")),
                DropdownMenuItem(value: "Pending", child: Text("Pending")),
                DropdownMenuItem(value: "Inactive", child: Text("Inactive")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                  applyFilters();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersList() {
    return Expanded(
      child: filteredPartners.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "No partners found",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredPartners.length,
        itemBuilder: (context, index) {
          return _buildPartnerCard(filteredPartners[index]);
        },
      ),
    );
  }

  Widget _buildPartnerCard(PartnerModel partner) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPartnerDetails(partner),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLogoWidget(partner),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partner.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          partner.industry,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(partner.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(partner.status),
                      ),
                    ),
                    child: Text(
                      partner.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(partner.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.calendar_today,
                      'Partner since: ${partner.partnerSince}',
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.event,
                      'Events hosted: ${partner.eventsHosted}',
                      Colors.orange,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      Icons.people,
                      'Students reached: ${partner.studentsReached}',
                      Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showPartnerDetails(partner),
                  icon: Icon(Icons.visibility, size: 18),
                  label: Text('View Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xff1676C4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}