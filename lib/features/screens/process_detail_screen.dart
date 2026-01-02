import 'package:flutter/material.dart';

class ProcessDetailScreen extends StatefulWidget {
  final String title;
  final int processId;

  const ProcessDetailScreen({
    super.key,
    required this.title,
    required this.processId,
  });

  @override
  State<ProcessDetailScreen> createState() => _ProcessDetailScreenState();
}

class _ProcessDetailScreenState extends State<ProcessDetailScreen> {
  String filter = "all";
  String search = "";

  List<Map<String, dynamic>> allJobs = [];
  List<Map<String, dynamic>> visibleJobs = [];

  @override
  void initState() {
    super.initState();
    loadDummyData();
  }

  void loadDummyData() {
    allJobs = [
      {
        "jobId": "1203-1",
        "customer": "Ali Traders",
        "status": "pending",
      },
      {
        "jobId": "1204-2",
        "customer": "Fast Print",
        "status": "completed",
      },
    ];
    visibleJobs = List.from(allJobs);
    setState(() {});
  }

  void applySearch(String value) {
    search = value;
    applyFilters();
  }

  void applyFilter(String value) {
    filter = value;
    applyFilters();
  }

  void applyFilters() {
    visibleJobs = allJobs.where((job) {
      final matchSearch = job["jobId"]
              .toLowerCase()
              .contains(search.toLowerCase()) ||
          job["customer"]
              .toLowerCase()
              .contains(search.toLowerCase());

      final matchFilter =
          filter == "all" ? true : job["status"] == filter;

      return matchSearch && matchFilter;
    }).toList();

    setState(() {});
  }

  void markCompleted(int index) {
    visibleJobs[index]["status"] = "completed";
    setState(() {});
    // 🔴 Later: Supabase update
  }

  @override
  Widget build(BuildContext context) {
    final completed =
        visibleJobs.where((j) => j["status"] == "completed").length;
    final progress =
        visibleJobs.isEmpty ? 0.0 : completed / visibleJobs.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),

            TextField(
              onChanged: applySearch,
              decoration: const InputDecoration(
                hintText: "Search job or customer",
                prefixIcon: Icon(Icons.search),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ["all", "pending", "completed"].map((f) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: filter == f,
                    onSelected: (_) => applyFilter(f),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: visibleJobs.length,
                itemBuilder: (context, index) {
                  final job = visibleJobs[index];
                  return Card(
                    child: ListTile(
                      title: Text(job["jobId"]),
                      subtitle: Text(job["customer"]),
                      trailing: job["status"] == "pending"
                          ? ElevatedButton(
                              onPressed: () => markCompleted(index),
                              child: const Text("Mark Completed"),
                            )
                          : const Text(
                              "Completed",
                              style: TextStyle(color: Colors.green),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
