import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/services/ProfileService.dart';
import 'cubit/profile/profile_cubit.dart';
import 'cubit/profile/profile_state.dart';

class StudentProfileScreen extends StatefulWidget {
  final bool showBackButton;
  const StudentProfileScreen({super.key, this.showBackButton = true});
  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);

  @override
  Widget build(BuildContext context) {
    final parentProfileCubit = () {
      try {
        return BlocProvider.of<ProfileCubit>(context);
      } catch (_) {
        return null;
      }
    }();

    return DynamicProfileProvider(
      parentCubit: parentProfileCubit,
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kPrimary,
          elevation: 0,
          leading: widget.showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: const Text(
            'My Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: kPrimary),
              );
            } else if (state is ProfileError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load profile details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<ProfileCubit>().loadProfile(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is ProfileSuccess) {
              final profile = state.profileData;
              final basicInfo = (profile['basicInfo'] ?? {}) as Map;
              final stats = (profile['stats'] ?? {}) as Map;

              final name = basicInfo['fullName']?.toString() ?? '';
              final email = basicInfo['email']?.toString() ?? '';
              final phone = (basicInfo['phoneNumber']?.toString() ?? '')
                  .replaceAll('N/A', '');
              final city = basicInfo['city']?.toString() ?? '';
              final country = basicInfo['country']?.toString() ?? '';
              final joinedAt = basicInfo['joinedAt']?.toString() ?? '';
              final major = basicInfo['major']?.toString() ?? '';
              final university = basicInfo['university']?.toString() ?? '';
              final profileImage = basicInfo['profileImage']?.toString() ?? '';

              final totalPoints = stats['totalPoints'] ?? 0;
              final careerReadinessRaw = stats['careerReadinessScore'] ?? 0;
              final careerReadiness = double.tryParse(careerReadinessRaw.toString()) ?? 0.0;

              // Roadmaps
              final roadmaps = (profile['roadmapsProgress'] ?? []) as List;

              // Skills
              final skillsList = (profile['skills'] ?? []) as List;

              // Achievements
              final achievements = (profile['achievements'] ?? []) as List;

              // Workshops inside activityDtos
              final activityDtos = (profile['activityDtos'] ?? []) as List;
              final workshops = activityDtos
                  .where((act) => act is Map && act['type'] == 'Workshop')
                  .toList();

              return RefreshIndicator(
                onRefresh: () => context.read<ProfileCubit>().loadProfile(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    widget.showBackButton ? 16 : 100,
                  ),
                  child: Column(
                    children: [
                      // Profile Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 44,
                                  backgroundColor: kPrimary.withValues(alpha: 0.1),
                                  backgroundImage:
                                      profileImage.isNotEmpty &&
                                          profileImage != '/default-profile.png'
                                      ? NetworkImage(
                                          profileImage.startsWith('http')
                                              ? profileImage
                                              : 'http://smartcareerhub.runasp.net$profileImage',
                                        )
                                      : null,
                                  child:
                                      profileImage.isEmpty ||
                                          profileImage == '/default-profile.png'
                                      ? Text(
                                          name.trim().isNotEmpty
                                              ? name.trim()[0].toUpperCase()
                                              : 'S',
                                          style: const TextStyle(
                                            fontSize: 36,
                                            color: kPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: kPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (major.isNotEmpty || university.isNotEmpty)
                              Text(
                                '$major${university.isNotEmpty ? " • $university" : ""}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffDDEEFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Active Student',
                                style: TextStyle(
                                  color: kPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                if (email.isNotEmpty)
                                  _contact(Icons.email_outlined, email),
                                if (phone.isNotEmpty)
                                  _contact(Icons.phone_outlined, phone),
                                if (city.isNotEmpty || country.isNotEmpty)
                                  _contact(
                                    Icons.location_on_outlined,
                                    '$city${country.isNotEmpty ? ", $country" : ""}',
                                  ),
                                if (joinedAt.isNotEmpty)
                                  _contact(
                                    Icons.calendar_today_outlined,
                                    'Joined ${joinedAt.split('T').first}',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Career Readiness',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Text(
                                  '$careerReadiness%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: careerReadiness / 100,
                                minHeight: 8,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation(
                                  kPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Total Points: $totalPoints',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (achievements.isNotEmpty) ...[
                        _sectionCard(
                          'Achievements',
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: achievements
                                .map(
                                  (a) => _achievementChip(
                                    a['name']?.toString() ??
                                        a['title']?.toString() ??
                                        'Badge',
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      if (roadmaps.isNotEmpty) ...[
                        _sectionCard(
                          'Joined Roadmaps',
                          trailing: '${roadmaps.length} Active',
                          child: Column(
                            children: roadmaps.take(4).map((r) {
                              if (r is! Map) return const SizedBox.shrink();
                              final pctRaw = r['progressPercent'] ??
                                      r['progressPercentage'] ??
                                      r['progress'] ??
                                      0;
                              final pct = double.tryParse(pctRaw.toString()) ?? 0.0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            r['title']?.toString() ??
                                                r['roadmapTitle']?.toString() ??
                                                '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${pct.toInt()}%',
                                          style: const TextStyle(
                                            color: kPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: pct / 100,
                                        minHeight: 6,
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              kPrimary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      if (workshops.isNotEmpty) ...[
                        _sectionCard(
                          'Enrolled Workshops',
                          trailing: '${workshops.length} Upcoming',
                          child: Column(
                            children: workshops
                                .take(4)
                                .map(
                                  (w) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.school_outlined,
                                          color: kPrimary,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            w['title']?.toString() ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          (w['registeredAt'] ??
                                                  w['startDate'] ??
                                                  '')
                                              .toString()
                                              .split('T')
                                              .first,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      if (skillsList.isNotEmpty) ...[
                        _sectionCard(
                          'Skills & Progress',
                          child: Column(
                            children: skillsList.take(6).map((e) {
                              if (e is! Map) return const SizedBox.shrink();
                              final name = e['skillName']?.toString() ?? '';
                              final pctRaw = e['progressPercent'] ?? 0;
                              final pct = double.tryParse(pctRaw.toString()) ?? 0.0;
                              final level = e['level']?.toString() ?? '';
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: SizedBox(
                                        width: 100,
                                        child: LinearProgressIndicator(
                                          value: pct / 100,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                kPrimary,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${pct.toInt()}%${level.isNotEmpty ? " ($level)" : ""}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: kPrimary),
            );
          },
        ),
      ),
    );
  }

  Widget _contact(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _achievementChip(String name) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[200]!),
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xffFEF3C7).withValues(alpha: 0.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.emoji_events_rounded,
          color: Color(0xffF59E0B),
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );

  Widget _sectionCard(
    String title, {
    required Widget child,
    String? trailing,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(
                  color: kPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class DynamicProfileProvider extends StatelessWidget {
  final ProfileCubit? parentCubit;
  final Widget child;

  const DynamicProfileProvider({super.key, this.parentCubit, required this.child});

  @override
  Widget build(BuildContext context) {
    final cubit = parentCubit;
    if (cubit != null) {
      return BlocProvider.value(value: cubit, child: child);
    }
    return BlocProvider(
      create: (_) => ProfileCubit(ProfileService())..loadProfile(),
      child: child,
    );
  }
}
