// lib/features/screens/process_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProcessDetailScreen extends StatefulWidget {
  final int processId;
  final String processName; 
  final List<dynamic>? userRoles; // 🔹 Added Roles

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
  String? currentUserEmployeeCode; // 🔹 To store worker code

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserCode();
  }

  // 🔹 Fetch worker's employee_code on screen load
  Future<void> _fetchCurrentUserCode() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('employee_code')
            .eq('id', user.id)
            .single();
        setState(() {
          currentUserEmployeeCode = profile['employee_code'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  Future<void> markAsCompleted(dynamic rowId) async {
    try {
      final int parsedId = int.parse(rowId.toString());
      if (currentUserEmployeeCode == null) await _fetchCurrentUserCode();

      final response = await Supabase.instance.client
          .from('job_processes')
          .update({
            'status': 'completed',
            'employee_code': currentUserEmployeeCode,
            'updated_at': DateTime.now().toIso8601String(),
            'end_time': DateTime.now().toIso8601String(),
          })
          .eq('id', parsedId)
          .select();

      if (response.isEmpty) throw "Update reject ho gaya (RLS check karein)";

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

  @override
  Widget build(BuildContext context) {
    final stream = Supabase.instance.client
        .from('job_processes')
        .stream(primaryKey: ['id'])
        .eq('process_id', widget.processId);

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: Text(widget.processName), 
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (v) => setState(() => search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Job ID...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All", "Pending", "Completed"].map((f) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: filter == f,
                    onSelected: (_) => setState(() => filter = f),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final jobs = snapshot.data!.where((j) {
                  final s = (j['status'] ?? 'pending').toString().toLowerCase();
                  final jId = (j['job_id'] ?? '').toString();
                  final empCode = j['employee_code']?.toString();
                  
                  // 🛠️ ROLE FILTERING LOGIC
                  bool isAdmin = widget.userRoles?.contains('admin') ?? false;
                  bool isMyJob = currentUserEmployeeCode != null && empCode == currentUserEmployeeCode;
                  bool isUnassigned = empCode == null || empCode.isEmpty;

                  // Admin sab dekh sakta hai, Worker ko sirf apni assigned ya unassigned jobs dikhengi
                  bool roleAccessible = isAdmin || isMyJob || (isUnassigned && s == 'pending');

                  bool matchesFilter = (filter == "All") || 
                                       (filter == "Pending" && s == "pending") || 
                                       (filter == "Completed" && s == "completed");
                  
                  return roleAccessible && matchesFilter && jId.contains(search);
                }).toList();

                return ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    final String status = (job['status'] ?? 'pending').toString().toLowerCase();
                    bool isPrinting = widget.processName.toLowerCase().contains("printing");

                    return FutureBuilder(
                      future: _getExtraDetails(job['job_id'], job['machine_id']),
                      builder: (context, AsyncSnapshot<Map<String, String>> details) {
                        return Card(
                          color: Colors.white.withOpacity(0.05),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text("Job: ${job['job_id']} | ${details.data?['customer'] ?? '...'}", 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Sub-Job: ${job['sub_job_id']}", style: const TextStyle(color: Colors.white70)),
                                if (isPrinting) Text("Machine: ${details.data?['machine'] ?? 'N/A'}", 
                                    style: const TextStyle(color: Colors.orangeAccent)),
                                Text("Status: ${status.toUpperCase()}", 
                                    style: TextStyle(color: status == 'completed' ? Colors.greenAccent : Colors.amberAccent)),
                              ],
                            ),
                            trailing: status == 'completed'
                                ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 30)
                                : ElevatedButton(
                                    onPressed: () => markAsCompleted(job['id']),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: const Text("Done"),
                                  ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>> _getExtraDetails(dynamic jobId, dynamic machineId) async {
    String customer = "Unknown";
    String machine = "No Machine";
    try {
      final jobData = await Supabase.instance.client.from('job_cards').select('customer_name').eq('job_id', jobId).maybeSingle();
      if (jobData != null) customer = jobData['customer_name'] ?? customer;

      if (machineId != null) {
        final machData = await Supabase.instance.client.from('machines').select('name').eq('id', machineId).maybeSingle();
        if (machData != null) machine = machData['name'] ?? machine;
      }
    } catch (e) { debugPrint(e.toString()); }
    return {'customer': customer, 'machine': machine};
  }
}