import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String searchText = "";
  String filter = "all"; // 'all', 'pending', 'completed'
  final supabase = Supabase.instance.client;

  Map<String, String> customerNames = {};

  @override
  void initState() {
    super.initState();
    _fetchAllCustomerNames();
  }

  Future<void> _fetchAllCustomerNames() async {
    try {
      final data = await supabase.from('job_cards').select('job_id, customer_name');
      if (data != null) {
        setState(() {
          for (var item in data) {
            customerNames[item['job_id'].toString()] = item['customer_name'] ?? "Unknown";
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching customers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = supabase.from('job_processes').stream(primaryKey: ['id']);

    return Scaffold(
      backgroundColor: Colors.transparent, // Background Layout handles this
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 16), // Adjusted padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reports",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 15),

            // 🔍 SEARCH BAR
            TextField(
              onChanged: (val) => setState(() => searchText = val),
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search Job ID or Customer...",
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 10),

            // 📑 FILTER TABS (New)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["all", "pending", "completed"].map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f.toUpperCase()),
                      selected: filter == f,
                      onSelected: (selected) {
                        if (selected) setState(() => filter = f);
                      },
                      selectedColor: Colors.blueAccent,
                      labelStyle: TextStyle(color: filter == f ? Colors.white : Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // 📋 DATA LIST
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No data found", style: TextStyle(color: Colors.white)));
                  }

                  final filtered = snapshot.data!.where((row) {
                    final jId = row['job_id']?.toString().toLowerCase() ?? "";
                    final cName = customerNames[row['job_id'].toString()]?.toLowerCase() ?? "";
                    final status = row['status']?.toString().toLowerCase() ?? "";

                    bool matchesSearch = jId.contains(searchText.toLowerCase()) || 
                                       cName.contains(searchText.toLowerCase());
                    bool matchesFilter = filter == "all" || status == filter;

                    return matchesSearch && matchesFilter;
                  }).toList();

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final report = filtered[index];
                      final String jobId = report['job_id'].toString();
                      final String customer = customerNames[jobId] ?? "Loading...";
                      
                      return _buildReportCard(report, customer);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, String customer) {
    bool isDone = report['status'].toString().toLowerCase() == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("JOB ID: ${report['job_id']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(customer, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report['status'].toString().toUpperCase(),
                  style: TextStyle(color: isDone ? Colors.greenAccent : Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          _rowInfo("Sub Job:", report['sub_job_id']?.toString() ?? "N/A"),
          _rowInfo("Employee Code:", report['employee_code'] ?? "Unassigned"),
          _rowInfo("Machine ID:", report['machine_id']?.toString() ?? "N/A"),
          _rowInfo("Updated:", _formatTime(report['updated_at'])),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      final date = DateTime.parse(dateStr).toLocal();
      // Padding with leading zeros
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      String hour = date.hour.toString().padLeft(2, '0');
      String min = date.minute.toString().padLeft(2, '0');
      return "$day/$month $hour:$min";
    } catch (e) {
      return dateStr;
    }
  }
}