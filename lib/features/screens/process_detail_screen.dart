import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/theme_provider.dart';
import '../screens/process_stats_screen.dart';

class ProcessDetailScreen extends StatefulWidget {
  final int processId;
  final String processName;

  const ProcessDetailScreen({
    super.key,
    required this.processId,
    required this.processName,
  });

  @override
  State<ProcessDetailScreen> createState() => _ProcessDetailScreenState();
}

class _ProcessDetailScreenState extends State<ProcessDetailScreen> {
  String filter = "All";
  String search = "";

  // 🔹 BACKEND: Mark Job as Completed (Friend's Logic)
  Future<void> markAsCompleted(dynamic rowId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('employee_code')
          .eq('id', user.id)
          .single();

      await Supabase.instance.client.from('job_processes').update({
        'status': 'completed',
        'employee_code': profile['employee_code'],
        'updated_at': DateTime.now().toIso8601String(),
        'end_time': DateTime.now().toIso8601String(),
      }).eq('id', rowId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job Completed!"), backgroundColor: Colors.green),
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

  // 🔹 BACKEND: Extra Details Fetcher (Friend's Logic)
  Future<Map<String, String>> _getExtraDetails(dynamic jobId, dynamic machineId) async {
    String customer = "Loading...";
    String machine = "N/A";
    try {
      final jobData = await Supabase.instance.client
          .from('job_cards')
          .select('customer_name')
          .eq('job_id', jobId)
          .maybeSingle();
      if (jobData != null) customer = jobData['customer_name'] ?? "Unknown";

      if (machineId != null) {
        final machData = await Supabase.instance.client
            .from('machines')
            .select('name')
            .eq('id', machineId)
            .maybeSingle();
        if (machData != null) machine = machData['name'] ?? "N/A";
      }
    } catch (e) { customer = "Unknown"; }
    return {'customer': customer, 'machine': machine};
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 UI: Your Theme Integration
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final scale = themeProvider.fontSizeMultiplier;
    final primaryColor = isDark ? Colors.white : const Color(0xFF4A148C);
    final cardBg = isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.7);

    // ⚡ BACKEND: Realtime Stream
    final stream = Supabase.instance.client
        .from('job_processes')
        .stream(primaryKey: ['id'])
        .eq('process_id', widget.processId);

    return Scaffold(
      backgroundColor: Colors.transparent, // Layout BG will show through
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, primaryColor, scale),
            _buildProgressCard(isDark, scale, primaryColor, cardBg),
            _buildSearchAndFilters(isDark, scale, cardBg),
            
            // ⚡ BACKEND: StreamBuilder for Realtime List
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: primaryColor)));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));

                  final filteredJobs = snapshot.data!.where((j) {
                    final s = (j['status'] ?? 'pending').toString().toLowerCase();
                    final jId = (j['job_id'] ?? '').toString();
                    bool matchesFilter = (filter == "All") || 
                                       (filter == "Pending" && s == "pending") || 
                                       (filter == "Completed" && s == "completed");
                    return matchesFilter && jId.contains(search);
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) => _buildJobCard(filteredJobs[index], isDark, scale, primaryColor, cardBg),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 UI: Your Header
  Widget _buildHeader(BuildContext context, Color color, double scale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.arrow_back_ios_new, color: color, size: 20), onPressed: () => Navigator.pop(context)),
          Text(widget.processName, style: GoogleFonts.balooBhai2(fontSize: 28 * scale, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 🎨 UI: Your Progress Card
  Widget _buildProgressCard(bool isDark, double scale, Color primaryColor, Color cardBg) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProcessStatsScreen(title: widget.processName))),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Overall Progress", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14 * scale)),
                Text("30%", style: GoogleFonts.balooBhai2(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18 * scale)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: 0.3, minHeight: 12, backgroundColor: Colors.black12, color: Colors.purpleAccent),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 UI: Your Filters
  Widget _buildSearchAndFilters(bool isDark, double scale, Color cardBg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => search = v),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Search Job ID...",
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
              filled: true,
              fillColor: cardBg,
              prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.black38),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ["All", "Pending", "Completed"].map((f) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f, style: TextStyle(fontSize: 10 * scale)),
                selected: filter == f,
                onSelected: (_) => setState(() => filter = f),
                selectedColor: const Color(0xFF6200EE),
                labelStyle: TextStyle(color: filter == f ? Colors.white : (isDark ? Colors.white60 : Colors.black54)),
                backgroundColor: cardBg,
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // 🎨 UI: Your Job Card + ⚡ BACKEND Data
  Widget _buildJobCard(Map<String, dynamic> job, bool isDark, double scale, Color primaryColor, Color cardBg) {
    final status = (job['status'] ?? 'pending').toString().toLowerCase();
    
    return FutureBuilder<Map<String, String>>(
      future: _getExtraDetails(job['job_id'], job['machine_id']),
      builder: (context, details) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${job['job_id']} / ${job['sub_job_id']}", 
                    style: TextStyle(color: primaryColor, fontSize: 18 * scale, fontWeight: FontWeight.bold)),
                  _statusBadge(status),
                ],
              ),
              Text("Customer: ${details.data?['customer'] ?? '...'}", 
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black87, fontSize: 14 * scale)),
              if (status == 'pending') ...[
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6200EE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => markAsCompleted(job['id']),
                    child: const Text("Mark Completed", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    bool isDone = status == "completed";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status.toUpperCase(), 
        style: TextStyle(color: isDone ? Colors.greenAccent : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}