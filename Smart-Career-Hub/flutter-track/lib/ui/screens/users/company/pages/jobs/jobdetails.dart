import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../data/models/company/job-model.dart';

class JobDetailsScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailsScreen({required this.job, super.key});

  String _calculateDaysRemaining() {
    if (job.deadline.isEmpty) {
      return 'Not set';
    }

    try {
      DateTime deadline = DateFormat('yyyy-MM-dd').parse(job.deadline);
      DateTime now = DateTime.now();
      int daysRemaining = deadline.difference(now).inDays;

      if (daysRemaining < 0) {
        return 'Expired';
      } else if (daysRemaining == 0) {
        return 'Today';
      } else if (daysRemaining == 1) {
        return '1 day remaining';
      } else if (daysRemaining < 7) {
        return '$daysRemaining days remaining';
      } else if (daysRemaining < 30) {
        int weeks = (daysRemaining / 7).ceil();
        return '$weeks ${weeks == 1 ? "week" : "weeks"} remaining';
      } else {
        int months = (daysRemaining / 30).ceil();
        return '$months ${months == 1 ? "month" : "months"} remaining';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _calculateDaysSincePosted() {
    if (job.postedDate.isEmpty) {
      return 'Unknown';
    }

    try {
      DateTime posted = DateFormat('yyyy-MM-dd').parse(job.postedDate);
      DateTime now = DateTime.now();
      int daysSince = now.difference(posted).inDays;

      if (daysSince == 0) {
        return 'Today';
      } else if (daysSince == 1) {
        return '1 day ago';
      } else if (daysSince < 7) {
        return '$daysSince days ago';
      } else if (daysSince < 30) {
        int weeks = (daysSince / 7).floor();
        return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
      } else {
        int months = (daysSince / 30).floor();
        return '$months ${months == 1 ? "month" : "months"} ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildLogoWidget() {
    if (job.logoPath == null || job.logoPath!.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xff1676C4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.business,
          color: Color(0xff1676C4),
          size: 40,
        ),
      );
    }

    if (job.logoPath!.startsWith("http")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          job.logoPath!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 40),
            );
          },
        ),
      );
    }

    if (File(job.logoPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(job.logoPath!),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 40),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = _calculateDaysRemaining();
    final daysSincePosted = _calculateDaysSincePosted();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Job Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Color(0xff1676C4),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1676C4), Color(0xff0d5fa3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  _buildLogoWidget(),
                  SizedBox(height: 12),
                  Text(
                    job.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (job.companyName != null && job.companyName!.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      job.companyName!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.status,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  _buildSectionTitle("Quick Stats", Icons.dashboard),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Applicants",
                          job.applicantsCount.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          "Posted",
                          daysSincePosted,
                          Icons.calendar_today,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Deadline",
                          daysRemaining,
                          Icons.timer,
                          Colors.orange,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          "Type",
                          job.employmentType,
                          Icons.work,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Job Details
                  _buildSectionTitle("Job Information", Icons.info_outline),
                  SizedBox(height: 12),
                  _buildDetailCard(
                    items: [
                      _DetailItem("Location Type", job.locationType, Icons.location_on),
                      if (job.location != null && job.location!.isNotEmpty)
                        _DetailItem("Location", job.location!, Icons.place),
                      _DetailItem("Salary Range", "${job.salaryMin} - ${job.salaryMax}", Icons.attach_money),
                      _DetailItem("Experience Level", job.experienceLevel, Icons.work_history),
                      _DetailItem("Employment Type", job.employmentType, Icons.business_center),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Description
                  _buildSectionTitle("Description", Icons.description),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
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
                    child: Text(
                      job.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Requirements
                  if (job.requirements.isNotEmpty) ...[
                    _buildSectionTitle("Requirements", Icons.checklist),
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: job.requirements.asMap().entries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: entry.key == job.requirements.length - 1 ? 0 : 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 6),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Color(0xff1676C4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Skills
                  if (job.skills.isNotEmpty) ...[
                    _buildSectionTitle("Required Skills", Icons.star),
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
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
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: job.skills.map((skill) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Timeline
                  _buildSectionTitle("Timeline", Icons.schedule),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(16),
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
                        _buildTimelineRow(
                          "Posted Date",
                          job.postedDate.isNotEmpty ? job.postedDate : 'Not set',
                          Icons.upload,
                          Colors.blue,
                        ),
                        SizedBox(height: 12),
                        _buildTimelineRow(
                          "Application Deadline",
                          job.deadline.isNotEmpty ? job.deadline : 'Not set',
                          Icons.flag,
                          Colors.red,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xff1676C4), size: 24),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
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
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({required List<_DetailItem> items}) {
    return Container(
      padding: EdgeInsets.all(16),
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
        children: items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: items.last == item ? 0 : 12),
            child: Row(
              children: [
                Icon(item.icon, color: Color(0xff1676C4), size: 20),
                SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                Flexible(
                  child: Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  final IconData icon;

  _DetailItem(this.label, this.value, this.icon);
}