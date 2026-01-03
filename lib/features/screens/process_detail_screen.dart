// lib/features/screens/process_detail_screen.dart

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

  /// 🔹 Fetch logged-in worker employee_code
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

  /// 🔹 Mark job as completed
  Future<void> markAsCompleted(dynamic rowId) async {
    try {
      if (currentUserEmployeeCode == null) {
        await _fetchCurrentUserCode();
      }

      final int id = int.parse(rowId.toString());

      final response = await Supabase.instance.client
          .from('job_processes')
          .update({
            'status': 'completed',
            'employee_code': currentUserEmployeeCode,
            'updated_at': DateTime.now().toIso8601String(),
            'end_time': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select();

      if (response.isEmpty) {
        throw "Update blocked (check RLS policies)";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Job Completed"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 🔹 Fetch customer & machine
  Future<Map<String, String>> _getExtraDetails(dynamic jobId, dynamic machineId) async {
    String customer = "Unknown";
    String machine = "N/A";

    try {
      final job = await Supabase.instance.client
          .from('job_cards')
          .select('customer_name')
          .eq('job_id', jobId)
          .maybeSingle();

      if (job != null) customer = job['customer_name'] ?? customer;

      if (machineId != null) {
        final mach = await Supabase.instance.client
            .from('machines')
            .select('name')
            .eq('id', machineId)
            .maybeSingle();

        if (mach != null) machine = mach['name'] ?? machine;
      }
    } catch (_) {}

    return {'customer': customer, 'machine': machine};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDark;
    final scale = theme.fontSizeMultiplier;

    final primaryColor = isDark ? Colors.white : const Color(0xFF4A148C);
    final cardBg = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.8);

    final stream = Supabase.instance.client
        .from('job_processes')
        .stream(primaryKey: ['id'])
        .eq('process_id', widget.processId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _header(primaryColor, scale),
            _progressCard(isDark, scale, primaryColor, cardBg),
            _searchAndFilter(isDark, scale, cardBg),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final jobs = snapshot.data!.where((j) {
                    final status = (j['status'] ?? 'pending').toString().toLowerCase();
                    final jobId = (j['job_id'] ?? '').toString();
                    final empCode = j['employee_code']?.toString();

                    final isAdmin = widget.userRoles?.contains('admin') ?? false;
                    final isMine = empCode != null && empCode == currentUserEmployeeCode;
                    final isUnassigned = empCode == null || empCode.isEmpty;

                    final roleAllowed =
                        isAdmin || isMine || (isUnassigned && status == 'pending');

                    final filterOk =
                        filter == "All" ||
                        (filter == "Pending" && status == "pending") ||
                        (filter == "Completed" && status == "completed");

                    return roleAllowed && filterOk && jobId.contains(search);
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: jobs.length,
                    itemBuilder: (_, i) =>
                        _jobCard(jobs[i], isDark, scale, primaryColor, cardBg),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// UI helpers ↓↓↓

  Widget _header(Color color, double scale) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: color),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            widget.processName,
            style: GoogleFonts.balooBhai2(
              fontSize: 26 * scale,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCard(bool isDark, double scale, Color color, Color bg) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProcessStatsScreen(title: widget.processName),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: const [
            LinearProgressIndicator(value: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _searchAndFilter(bool isDark, double scale, Color bg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: InputDecoration(
              hintText: "Search Job ID",
              filled: true,
              fillColor: bg,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ["All", "Pending", "Completed"]
                .map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: filter == f,
                        onSelected: (_) => setState(() => filter = f),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _jobCard(
    Map<String, dynamic> job,
    bool isDark,
    double scale,
    Color color,
    Color bg,
  ) {
    final status = (job['status'] ?? 'pending').toString().toLowerCase();
    final isPrinting = widget.processName.toLowerCase().contains("printing");

    return FutureBuilder<Map<String, String>>(
      future: _getExtraDetails(job['job_id'], job['machine_id']),
      builder: (_, snap) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Job ${job['job_id']} / ${job['sub_job_id']}",
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text("Customer: ${snap.data?['customer'] ?? '...'}"),
              if (isPrinting)
                Text("Machine: ${snap.data?['machine'] ?? 'N/A'}"),
              const SizedBox(height: 10),
              status == 'completed'
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : ElevatedButton(
                      onPressed: () => markAsCompleted(job['id']),
                      child: const Text("Mark Completed"),
                    ),
            ],
          ),
        );
      },
    );
  }
}
