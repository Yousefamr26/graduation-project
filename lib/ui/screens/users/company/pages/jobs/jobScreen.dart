import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../../data/models/company/job-model.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/action_button.dart';
import 'JobmockData.dart';
import 'addnewjob.dart';
import 'jobhistory.dart';
import 'jobdetails.dart';


class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final List<JobModel> jobs = [];
  final List<JobModel> jobHistory = [];

  String searchText = "";
  String selectedFilter = "All";
  List<JobModel> filteredJobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  // ✅ MOCK: جيب البيانات من الـ static list
  Future<void> _fetchJobs() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    // ✅ MOCK
    await Future.delayed(const Duration(milliseconds: 400));
    final fetched = JobMockData.getJobs();

    // ❌ BACKEND:
    // final fetched = await _jobRepo.getAllJobs();

    if (!mounted) return;

    // استثنِ الـ jobs الموجودة في الـ history
    final historyIds = jobHistory.map((j) => j.id).toSet();

    setState(() {
      jobs.clear();
      for (var job in fetched) {
        if (!historyIds.contains(job.id)) jobs.add(job);
      }
      applyFilters();
      isLoading = false;
    });
  }

  void applyFilters() {
    setState(() {
      filteredJobs = jobs.where((job) {
        if (selectedFilter != "All" && job.status != selectedFilter) return false;
        if (searchText.isEmpty) return true;
        return _matchesSearch(job, searchText.toLowerCase());
      }).toList();
    });
  }

  bool _matchesSearch(JobModel job, String q) {
    return job.title.toLowerCase().contains(q) ||
        job.description.toLowerCase().contains(q) ||
        (job.companyName?.toLowerCase().contains(q) ?? false) ||
        job.locationType.toLowerCase().contains(q) ||
        job.experienceLevel.toLowerCase().contains(q) ||
        (job.location?.toLowerCase().contains(q) ?? false);
  }

  void _deleteJob(int index) {
    final jobToDelete = filteredJobs[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Delete Job"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to delete this job?"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                jobToDelete.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You can restore it from History later.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Color(0xff1676C4))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(jobToDelete);
            },
            icon: const Icon(Icons.delete),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _performDelete(JobModel job) {
    // ✅ MOCK: مش بنحذف من الـ static list — بس بنحركه للـ history في الـ runtime
    setState(() {
      jobHistory.add(job);
      jobs.remove(job);
      applyFilters();
    });

    // ❌ BACKEND:
    // await _jobRepo.deleteJob(job.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Job moved to History'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              final last = jobHistory.removeLast();
              jobs.add(last);
              applyFilters();
            });
          },
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildLogoWidget(JobModel job) {
    if (job.logoPath == null || job.logoPath!.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xff1676C4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.business, color: Color(0xff1676C4), size: 30),
      );
    }
    if (job.logoPath!.startsWith("http")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(job.logoPath!, width: 60, height: 60, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 30))),
      );
    }
    if (File(job.logoPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(job.logoPath!), width: 60, height: 60, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 30))),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newJob = await Navigator.push<JobModel>(
            context,
            MaterialPageRoute(builder: (_) => const CreateEditJobScreen()),
          );

          if (newJob != null && mounted) {
            // ✅ MOCK: ضيف في الـ static list وبعدين fetch
            JobMockData.addJob(newJob);
            await _fetchJobs();

            // ❌ BACKEND: الـ CreateEditJobScreen هو اللي بيعمل الـ API call
            // هنا بس نعمل fetch لو الـ screen رجع true مثلاً

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Job created successfully!'), backgroundColor: Colors.green),
              );
            }
          }
        },
        backgroundColor: const Color(0xff1676C4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [_buildAppBar(), _buildSearchAndFilter(), _buildJobsList()],
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
            toolbarHeight: 130,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Jobs", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text("Manage your job postings", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w300)),
              ],
            ),
            actions: [
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.refresh, color: Colors.white),
                  ],
                ),
                onPressed: _fetchJobs,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.history, color: Colors.white),
                    if (jobHistory.isNotEmpty)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Center(
                            child: Text(
                              '${jobHistory.length > 99 ? '99+' : jobHistory.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () async {
                  final restoredJob = await Navigator.push<JobModel>(
                    context,
                    MaterialPageRoute(builder: (_) => JobHistoryScreen(jobHistory: jobHistory)),
                  );
                  if (restoredJob != null && mounted) {
                    setState(() {
                      jobs.add(restoredJob);
                      jobHistory.remove(restoredJob);
                      applyFilters();
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Job restored successfully!'), backgroundColor: Colors.green),
                      );
                    }
                  }
                },
                tooltip: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search jobs...",
                prefixIcon: const Icon(Icons.search, color: Color(0xff1676C4)),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
              ),
              onChanged: (value) {
                setState(() { searchText = value; applyFilters(); });
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 160,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: CustomDropdown(
                items: const ["All", "Draft", "Published", "Closed"],
                value: selectedFilter,
                onChanged: (value) {
                  setState(() { selectedFilter = value!; applyFilters(); });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredJobs.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(searchText.isEmpty ? "No jobs yet" : "No jobs found",
                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(searchText.isEmpty ? "Create your first job posting!" : "Try a different search",
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchJobs,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredJobs.length,
          itemBuilder: (context, index) => _buildJobCard(index),
        ),
      ),
    );
  }

  Widget _buildJobCard(int index) {
    final job = filteredJobs[index];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogoWidget(job),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      if (job.companyName != null && job.companyName!.isNotEmpty)
                        Text(job.companyName!, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            job.locationType == 'Remote' ? Icons.home_work : job.locationType == 'Onsite' ? Icons.location_on : Icons.hub,
                            size: 16, color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(job.locationType, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Salary + Experience
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Row(children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                    Text("${job.salaryMin} - ${job.salaryMax}",
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600, fontSize: 12)),
                  ]),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xff1676C4).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Row(children: [
                    const Icon(Icons.work_history, size: 14, color: Color(0xff1676C4)),
                    const SizedBox(width: 4),
                    Text(job.experienceLevel, style: const TextStyle(color: Color(0xff1676C4), fontWeight: FontWeight.w600, fontSize: 9)),
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(job.description, style: TextStyle(color: Colors.grey[700], fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),

            const SizedBox(height: 12),

            // Status + Applicants
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: job.status == "Published"
                        ? Colors.green.withOpacity(0.15)
                        : job.status == "Closed"
                        ? Colors.grey.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job.status,
                    style: TextStyle(
                      color: job.status == "Published" ? Colors.green : job.status == "Closed" ? Colors.grey[700] : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.people, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text("${job.applicantsCount} applicants", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ActionButton(
                  icon: Icons.info_outline,
                  text: "Details",
                  color: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job))),
                ),
                ActionButton(
                  icon: Icons.edit,
                  text: "Edit",
                  color: const Color(0xff1676C4),
                  onTap: () async {
                    final updatedJob = await Navigator.push<JobModel>(
                      context,
                      MaterialPageRoute(builder: (_) => CreateEditJobScreen(job: job)),
                    );
                    if (updatedJob != null && mounted) {
                      // ✅ MOCK: عدّل في الـ static list وبعدين fetch
                      JobMockData.updateJob(updatedJob.id, updatedJob);
                      await _fetchJobs();

                      // ❌ BACKEND: الـ CreateEditJobScreen هو اللي بيعمل API call
                    }
                  },
                ),
                ActionButton(
                  icon: Icons.delete,
                  text: "Delete",
                  color: Colors.red,
                  onTap: () => _deleteJob(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}