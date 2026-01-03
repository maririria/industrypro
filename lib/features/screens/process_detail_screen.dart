import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/theme_provider.dart';
import '../screens/process_stats_screen.dart';

class ProcessDetailScreen extends StatefulWidget {
  final int processId;
  final String processName;
  final List<dynamic>? userRoles;

  const ProcessDetailScreen({
    super.key,
    required this.processId,
    required this.processName,
    this.userRoles,
  });

  @override
  State<ProcessDetailScreen> createState() => _ProcessDetailScreenState();
}

class _ProcessDetailScreenState extends State<ProcessDetailScreen> {
  String filter = "All";
  String search = "";
  String? currentUserEmployeeCode;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserCode(); 
  }

  Future<void> _fetchCurrentUserCode() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('employee_code')
          .eq('id', user.id)
          .single();

      setState(() {
        currentUserEmployeeCode = profile['employee_code'];
      });
    } catch (e) {
      debugPrint("Profile fetch error: $e");
    }
  }

  // 🔹 Aapka Real-time Stats Calculation
  Map<String, dynamic> _calculateStats(List<Map<String, dynamic>> jobs) {
    int total = jobs.length;
    int completed = jobs.where((j) => j['status'] == 'completed').length;
    int pending = total - completed;
    double percentage = total > 0 ? (completed / total) : 0.0;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'percentage': percentage,
    };
  }

  Future<void> markAsCompleted(dynamic rowId) async {
    try {
      if (currentUserEmployeeCode == null) {
        await _fetchCurrentUserCode();
      }

      await Supabase.instance.client.from('job_processes').update({
        'status': 'completed',
        'employee_code': currentUserEmployeeCode,
        'updated_at': DateTime.now().toIso8601String(),
        'end_time': DateTime.now().toIso8601String(),
      }).eq('id', rowId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job Completed!"), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<Map<String, String>> _getExtraDetails(dynamic jobId, dynamic machineId) async {
    String customer = "Unknown";
    String machine = "N/A";
    try {
      final jobData = await Supabase.instance.client.from('job_cards').select('customer_name').eq('job_id', jobId).maybeSingle();
      if (jobData != null) customer = jobData['customer_name'] ?? "Unknown";

      if (machineId != null) {
        final mach = await Supabase.instance.client.from('machines').select('name').eq('id', machineId).maybeSingle();
        if (mach != null) machine = mach['name'] ?? "N/A";
      }
    } catch (e) {
      debugPrint("Extra details error: $e");
    }
    return {'customer': customer, 'machine': machine};
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDark;
    final double scale = themeProvider.fontSizeMultiplier;

    final Color primaryPurple = const Color(0xFF4A148C);
    final Color textColor = isDark ? Colors.white : primaryPurple;
    final Color cardBg = isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.7);

    final stream = Supabase.instance.client.from('job_processes').stream(primaryKey: ['id']).eq('process_id', widget.processId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(isDark ? 'assets/images/bg_dark.png' : 'assets/images/bg_light.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text("Error loading data", style: TextStyle(color: textColor)));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));

              final allJobs = snapshot.data!;
              final stats = _calculateStats(allJobs);

              final filteredJobs = allJobs.where((j) {
                final status = (j['status'] ?? 'pending').toString().toLowerCase();
                final jobId = (j['job_id'] ?? '').toString();
                final empCode = j['employee_code']?.toString();

                final isAdmin = widget.userRoles?.contains('admin') ?? false;
                final isMine = empCode != null && empCode == currentUserEmployeeCode;
                final isUnassigned = empCode == null || empCode.isEmpty;

                final roleAllowed = isAdmin || isMine || (isUnassigned && status == 'pending');
                
                bool matchesFilter = (filter == "All") || (filter == "Pending" && status == "pending") || (filter == "Completed" && status == "completed");
                
                return roleAllowed && matchesFilter && jobId.contains(search);
              }).toList();

              return Column(
                children: [
                  _buildHeader(context, isDark ? Colors.white : primaryPurple, scale),
                  _buildProgressCard(isDark, scale, primaryPurple, cardBg, stats),
                  _buildSearchAndFilters(isDark, scale, cardBg, textColor),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      itemCount: filteredJobs.length,
                      itemBuilder: (context, index) => _buildJobCard(filteredJobs[index], isDark, scale, primaryPurple, cardBg),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color, double scale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.arrow_back_ios_new, color: color, size: 20), onPressed: () => Navigator.pop(context)),
          Text(widget.processName, style: GoogleFonts.balooBhai2(fontSize: 24 * scale, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProgressCard(bool isDark, double scale, Color purple, Color cardBg, Map<String, dynamic> stats) {
    double progress = stats['percentage'];
    int displayPercent = (progress * 100).toInt();

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProcessStatsScreen(title: widget.processName, stats: stats))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.2))),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Overall Progress", style: TextStyle(color: purple, fontSize: 13 * scale, fontWeight: FontWeight.bold)),
                Text("$displayPercent%", style: GoogleFonts.balooBhai2(color: purple, fontWeight: FontWeight.bold, fontSize: 18 * scale)),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(10))),
                LayoutBuilder(
                  builder: (context, constraints) => Container(
                    height: 10,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.blueAccent, Colors.pinkAccent]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("View Detailed Stats", style: TextStyle(fontSize: 10 * scale, color: purple, fontWeight: FontWeight.w500)),
                Icon(Icons.keyboard_arrow_right, size: 14, color: purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDark, double scale, Color cardBg, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: [
          SizedBox(
            height: 35,
            child: TextField(
              onChanged: (v) => setState(() => search = v),
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF4A148C), fontSize: 14),
              decoration: InputDecoration(
                hintText: "Search Job ID...",
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.deepPurple, fontSize: 13),
                filled: true,
                fillColor: cardBg,
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ["All", "Pending", "Completed"].map((f) {
              bool isSelected = filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (_) => setState(() => filter = f),
                  selectedColor: const Color(0xFF673AB7),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                  backgroundColor: cardBg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, bool isDark, double scale, Color purple, Color cardBg) {
    final status = (job['status'] ?? 'pending').toString().toLowerCase();
    final isPrinting = widget.processName.toLowerCase().contains("printing");

    return FutureBuilder<Map<String, String>>(
      future: _getExtraDetails(job['job_id'], job['machine_id']),
      builder: (context, snap) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.2))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${job['job_id']} / ${job['sub_job_id']}", style: TextStyle(color: purple, fontSize: 16 * scale, fontWeight: FontWeight.bold)),
                  _statusBadge(status, isDark),
                ],
              ),
              Text("Customer: ${snap.data?['customer'] ?? '...'}", style: TextStyle(color: purple.withOpacity(0.8), fontSize: 12 * scale, fontWeight: FontWeight.w500)),
              if (isPrinting)
                Text("Machine: ${snap.data?['machine'] ?? 'N/A'}", style: TextStyle(color: purple.withOpacity(0.7), fontSize: 11 * scale)),
              
              if (status == 'pending') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => markAsCompleted(job['id']),
                    child: const Text("Mark Completed", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status, bool isDark) {
    bool isDone = status == "completed";
    Color bgColor = isDone ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2);
    Color txtColor = isDone ? (isDark ? Colors.greenAccent : Colors.green[800]!) : (isDark ? Colors.orangeAccent : Colors.orange[900]!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: txtColor.withOpacity(0.3))),
      child: Text(status.toUpperCase(), style: TextStyle(color: txtColor, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}