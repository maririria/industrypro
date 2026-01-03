import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProcessDetailScreen extends StatefulWidget {
  final int processId;
  final String processName;
  const ProcessDetailScreen({super.key, required this.processId, required this.processName});

  @override
  State<ProcessDetailScreen> createState() => _ProcessDetailScreenState();
}

class _ProcessDetailScreenState extends State<ProcessDetailScreen> {
  String filter = "All";
  String search = "";

  // 🔹 "Done" button ka function
  Future<void> markAsCompleted(dynamic rowId) async {
    try {
      // rowId ko safe tareeqe se int mein badalna (int4 fix)
      final int parsedId = int.parse(rowId.toString());
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Profile se employee code lena
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('employee_code')
          .eq('id', user.id)
          .single();

      // Database Update
      final response = await Supabase.instance.client
          .from('job_processes')
          .update({
            'status': 'completed',
            'employee_code': profile['employee_code'],
            'updated_at': DateTime.now().toIso8601String(),
            'end_time': DateTime.now().toIso8601String(),
          })
          .eq('id', parsedId)
          .select();

      if (response.isEmpty) throw "Database ne update reject kar diya (RLS check karein)";

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
    // Realtime stream
    final stream = Supabase.instance.client
        .from('job_processes')
        .stream(primaryKey: ['id'])
        .eq('process_id', widget.processId);

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(title: Text(widget.processName), backgroundColor: Colors.transparent),
      body: Column(
        children: [
          // 🔹 Search Bar
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          
          // 🔹 Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All", "Pending", "Completed"].map((f) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: filter == f,
                    onSelected: (_) => setState(() => filter = f),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final jobs = snapshot.data!.where((j) {
                  final s = (j['status'] ?? 'pending').toString().toLowerCase();
                  final jId = (j['job_id'] ?? '').toString();
                  bool matchesFilter = (filter == "All") || (filter == "Pending" && s == "pending") || (filter == "Completed" && s == "completed");
                  return matchesFilter && jId.contains(search);
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
                          color: Colors.white10,
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
    } catch (e) { print(e); }
    return {'customer': customer, 'machine': machine};
  }
}