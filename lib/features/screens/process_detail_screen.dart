import 'package:flutter/material.dart';

class ProcessDetailScreen extends StatefulWidget {
  final String processName;
  const ProcessDetailScreen({super.key, required this.processName});

  @override
  State<ProcessDetailScreen> createState() => _ProcessDetailScreenState();
}

class _ProcessDetailScreenState extends State<ProcessDetailScreen> {
  String filter = "All";
  String search = "";

  List<Map<String, dynamic>> jobs = [
    {
      "id": "11203 - 1",
      "customer": "Ahmad",
      "completed": false,
    },
    {
      "id": "11203 - 2",
      "customer": "Yusuf",
      "completed": true,
    },
    {
      "id": "12301 - 1",
      "customer": "Kashif",
      "completed": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredJobs = jobs.where((job) {
      if (filter == "Pending" && job["completed"]) return false;
      if (filter == "Completed" && !job["completed"]) return false;
      if (search.isNotEmpty &&
          !job["customer"]
              .toLowerCase()
              .contains(search.toLowerCase()) &&
          !job["id"].contains(search)) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.processName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Column(
        children: [
          // 🔹 PROGRESS
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: jobs.where((j) => j["completed"]).length /
                      jobs.length,
                ),
                const SizedBox(height: 6),
                Text(
                    "${jobs.where((j) => j["completed"]).length} / ${jobs.length} completed"),
              ],
            ),
          ),

          // 🔹 SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => search = v),
              decoration: const InputDecoration(
                hintText: "Search job / customer",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 FILTERS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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

          const SizedBox(height: 8),

          // 🔹 JOB LIST
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: filteredJobs.length,
                itemBuilder: (context, index) {
                  final job = filteredJobs[index];
                  return Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job["id"],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(job["customer"]),
                        const SizedBox(height: 6),
                        job["completed"]
                            ? const Text(
                                "Completed by user",
                                style: TextStyle(color: Colors.green),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    job["completed"] = true;
                                  });
                                },
                                child: const Text("Mark Completed"),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
