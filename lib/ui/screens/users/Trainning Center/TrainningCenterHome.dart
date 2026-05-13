import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
//  TRAINING HOME SCREEN
// ══════════════════════════════════════════════════════

class TrainingHomeScreen extends StatefulWidget {
  const TrainingHomeScreen({super.key});

  @override
  State<TrainingHomeScreen> createState() => _TrainingHomeScreenState();
}

class _TrainingHomeScreenState extends State<TrainingHomeScreen> {
  static const Color kPrimary     = Color(0xff1676C4);
  static const Color kPrimaryDark = Color(0xff0d5fa3);
  static const Color kBg          = Color(0xffF0F9FF);

  int _selectedIndex = 0;
  final String academyName = 'SkillBoost Academy';

  // ── Mock Data ──
  final List<Map<String, dynamic>> courses = [
    {'name': 'Flutter Development', 'progress': 0.85, 'rate': 4.8},
    {'name': 'UI/UX Design',        'progress': 0.60, 'rate': 4.5},
    {'name': 'Data Science',         'progress': 0.40, 'rate': 4.2},
    {'name': 'Cybersecurity',        'progress': 0.75, 'rate': 4.7},
  ];

  final List<Map<String, dynamic>> recentTrainees = [
    {'name': 'Ahmed Mohamed', 'course': 'Flutter Development', 'status': 'Active'},
    {'name': 'Sara Ali',       'course': 'UI/UX Design',        'status': 'Completed'},
    {'name': 'Omar Hassan',    'course': 'Data Science',         'status': 'Active'},
    {'name': 'Nour Khalid',    'course': 'Cybersecurity',        'status': 'Pending'},
  ];

  // ── Helpers ──

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming Soon')),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Active':    return const Color(0xff22C55E);
      case 'Completed': return const Color(0xff1676C4);
      default:          return const Color(0xffF59E0B);
    }
  }

  // ══════════════ DRAWER ══════════════

  Widget _buildDrawer() {
    final items = [
      {'icon': Icons.dashboard_outlined,        'label': 'Dashboard'},
      {'icon': Icons.menu_book_outlined,         'label': 'Course Management'},
      {'icon': Icons.chat_bubble_outline_rounded,'label': 'Communication'},
      {'icon': Icons.people_outline_rounded,     'label': 'Trainee Profiles'},
      {'icon': Icons.bar_chart_rounded,          'label': 'Reports'},
      {'icon': Icons.notifications_outlined,     'label': 'Notifications'},
      {'icon': Icons.smart_toy_outlined,         'label': 'AI Assistant'},
      {'icon': Icons.person_outline_rounded,     'label': 'Profile'},
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Close button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // ── Logo + Title ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, kPrimaryDark],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Smart Career\nHub',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Menu Items ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ...items.map(
                    (item) => ListTile(
                      leading: Icon(item['icon'] as IconData, color: kPrimary, size: 22),
                      title: Text(
                        item['label'] as String,
                        style: const TextStyle(fontSize: 14),
                      ),
                      horizontalTitleGap: 8,
                      onTap: () {
                        Navigator.pop(context);
                        _showComingSoon();
                      },
                    ),
                  ),

                  const Divider(),

                  // ── Logout ──
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Colors.red, size: 22),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    horizontalTitleGap: 8,
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context, '/chooseUser', (r) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════ APP BAR ══════════════

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimary,
      elevation: 0,
      leading: Builder(
        builder: (ctx) => GestureDetector(
          onTap: () => Scaffold.of(ctx).openDrawer(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.25),
              child: const Icon(Icons.business, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
      title: const Text('Smart Career Hub',
          style: TextStyle(color: Colors.white, fontSize: 16)),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: _showComingSoon,
        ),
      ],
    );
  }

  // ══════════════ BOTTOM NAV ══════════════

  Widget _buildBottomNav() {
    final items = [
      Icons.home_rounded,
      Icons.menu_book_outlined,
      Icons.bar_chart_rounded,
      Icons.people_outline_rounded,
      Icons.person_outline_rounded,
    ];
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: kPrimary,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (i) {
        setState(() => _selectedIndex = i);
        if (i != 0) _showComingSoon();
      },
      items: items
          .map((icon) => BottomNavigationBarItem(icon: Icon(icon), label: ''))
          .toList(),
    );
  }

  // ══════════════ STAT CARD ══════════════

  Widget _statCard({
    required String value,
    required String label,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // ══════════════ COURSE ROW ══════════════

  Widget _courseRow(Map<String, dynamic> course) {
    final double p = course['progress'] as double;
    final Color pc = p >= 0.75
        ? const Color(0xff22C55E)
        : p >= 0.5
            ? const Color(0xffF59E0B)
            : const Color(0xffEF4444);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(course['name'],
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: p,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(pc),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 2),
                Text('${(p * 100).toInt()}%',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xffF59E0B), size: 13),
              const SizedBox(width: 2),
              Text(course['rate'].toString(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════ TRAINEE ROW ══════════════

  Widget _traineeRow(Map<String, dynamic> t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: kPrimary.withOpacity(0.1),
            child: Text(t['name'].toString()[0],
                style: const TextStyle(
                    color: kPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['name'],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(t['course'],
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                    color: _statusColor(t['status']), shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(t['status'],
                  style: TextStyle(
                      fontSize: 11,
                      color: _statusColor(t['status']),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════ WHITE CARD ══════════════

  Widget _card({required String title, required String action, required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: _showComingSoon,
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text(action,
                    style: const TextStyle(color: kPrimary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  // ══════════════ BUILD ══════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Blue Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimary, kPrimaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Welcome Row
                  Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.star_rounded,
                            color: Color(0xffFCD34D), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome,',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text(academyName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Stats Row 1
                  Row(children: [
                    _statCard(value: '18',  label: 'Total Courses',
                        icon: Icons.menu_book_rounded,
                        iconBg: Colors.white.withOpacity(0.2), iconColor: Colors.white),
                    const SizedBox(width: 12),
                    _statCard(value: '342', label: 'Active Trainees',
                        icon: Icons.people_rounded,
                        iconBg: Colors.white.withOpacity(0.2), iconColor: Colors.white),
                  ]),

                  const SizedBox(height: 12),

                  // Stats Row 2
                  Row(children: [
                    _statCard(value: '465', label: 'Pending Requests',
                        icon: Icons.pending_actions_rounded,
                        iconBg: const Color(0xffFEF3C7), iconColor: const Color(0xffD97706)),
                    const SizedBox(width: 12),
                    _statCard(value: '287', label: 'Certificates Issued',
                        icon: Icons.workspace_premium_rounded,
                        iconBg: const Color(0xffFEF3C7), iconColor: const Color(0xffF59E0B)),
                  ]),

                  const SizedBox(height: 12),

                  // Stats Row 3
                  Row(children: [
                    _statCard(value: '90%', label: 'Completion Rate',
                        icon: Icons.check_circle_rounded,
                        iconBg: const Color(0xffDCFCE7), iconColor: const Color(0xff16A34A)),
                    const SizedBox(width: 12),
                    _statCard(value: '6',   label: 'Active Entities',
                        icon: Icons.business_center_rounded,
                        iconBg: Colors.white.withOpacity(0.2), iconColor: Colors.white),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Course Performance ──
            _card(
              title: 'Course Performance',
              action: 'See All',
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Expanded(flex: 4,
                            child: Text('Course Name',
                                style: TextStyle(fontSize: 11, color: Colors.grey,
                                    fontWeight: FontWeight.w600))),
                        Expanded(flex: 3,
                            child: Text('Progress',
                                style: TextStyle(fontSize: 11, color: Colors.grey,
                                    fontWeight: FontWeight.w600))),
                        const Text('Rate',
                            style: TextStyle(fontSize: 11, color: Colors.grey,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...courses.map(_courseRow),
                ],
              ),
            ),

            // ── Recent Trainees ──
            _card(
              title: 'Recent Trainees',
              action: 'View All',
              child: Column(children: recentTrainees.map(_traineeRow).toList()),
            ),

            // ── Add Course Button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PublishCourseScreen()),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, color: kPrimary),
                  label: const Text('Add Course',
                      style: TextStyle(
                          color: kPrimary, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: kPrimary, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }
}


// ══════════════════════════════════════════════════════
//  PUBLISH COURSE SCREEN
// ══════════════════════════════════════════════════════

class PublishCourseScreen extends StatefulWidget {
  const PublishCourseScreen({super.key});

  @override
  State<PublishCourseScreen> createState() => _PublishCourseScreenState();
}

class _PublishCourseScreenState extends State<PublishCourseScreen> {
  static const Color kPrimary     = Color(0xff1676C4);
  static const Color kPrimaryDark = Color(0xff0d5fa3);
  static const Color kFieldBg     = Color(0xffEFF6FF);

  final _formKey = GlobalKey<FormState>();

  final _titleCtrl       = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _durationCtrl    = TextEditingController();
  final _feeCtrl         = TextEditingController();
  final _hoursCtrl       = TextEditingController();

  String _selectedMode   = 'Online';
  bool   _isOnline       = true;
  bool   _loading        = false;

  final List<String> _modes = ['Online', 'Offline', 'Hybrid'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _feeCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  // ── Field Builder ──

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool required = false,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kPrimary),
              children: required
                  ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              filled: true,
              fillColor: kFieldBg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPrimary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mode Row ──

  Widget _modeRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Mode',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kPrimary)),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: _isOnline,
                  activeColor: kPrimary,
                  onChanged: (v) => setState(() {
                    _isOnline = v;
                    _selectedMode = v ? 'Online' : 'Offline';
                  }),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: kFieldBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMode,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: kPrimary),
                style: const TextStyle(
                    fontSize: 13, color: Colors.black87),
                items: _modes
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedMode = v;
                      _isOnline = v == 'Online';
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit ──

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate API
    setState(() => _loading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course published successfully!'),
        backgroundColor: Color(0xff16A34A),
      ),
    );
    Navigator.pop(context);
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('new course',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ──
              const Text(
                'Publish New Course',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Create a new course for your training center',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),

              const SizedBox(height: 24),

              // ── Fields ──
              _field(
                label: 'Course Title',
                hint: 'Course Title',
                controller: _titleCtrl,
                required: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Title is required' : null,
              ),

              _field(
                label: 'Description',
                hint: 'Description',
                controller: _descCtrl,
                required: true,
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Description is required' : null,
              ),

              _field(
                label: 'Duration (weeks)',
                hint: 'Duration (weeks)',
                controller: _durationCtrl,
                keyboard: TextInputType.number,
              ),

              _field(
                label: 'Fee',
                hint: 'Fee (if any)',
                controller: _feeCtrl,
                keyboard: TextInputType.number,
              ),

              _field(
                label: 'Hours per week',
                hint: 'Hours per week',
                controller: _hoursCtrl,
                keyboard: TextInputType.number,
              ),

              _modeRow(),

              const SizedBox(height: 8),

              // ── Buttons ──
              Row(
                children: [
                  // Publish
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff475569),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Publish Course',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Cancel
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Cancel',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // ── Blue Bottom Bar (decoration) ──
      bottomNavigationBar: Container(
        height: 6,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
        ),
      ),
    );
  }
}