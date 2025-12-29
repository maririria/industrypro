import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String searchText = "";
  String filter = "All";

  final List<Map<String, dynamic>> jobs = [
    {
      "jobId": "J101 - A",
      "customer": "Ali Traders",
      "description": "Laptop Boxes Printing",
      "processes": {
        "Printing": "Completed",
        "Cutting": "Completed",
        "Lamination": "Pending",
      }
    },
    {
      "jobId": "J102 - B",
      "customer": "Smart Packaging",
      "description": "Mobile Phone Boxes",
      "processes": {
        "Printing": "Completed",
        "Cutting": "Pending",
        "Varnish": "Pending",
      }
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredJobs = jobs.where((job) {
      final matchesSearch =
          job["customer"].toLowerCase().contains(searchText.toLowerCase());

      if (filter == "All") return matchesSearch;

      return matchesSearch &&
          job["processes"].values.contains(filter);
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Reports",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          // 🔍 SEARCH
          TextField(
            onChanged: (val) => setState(() => searchText = val),
            decoration: InputDecoration(
              hintText: "Search by customer",
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 FILTER
          Row(
            children: ["All", "Pending", "Completed"].map((f) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // 📋 JOBS LIST
          Expanded(
            child: ListView.builder(
              itemCount: filteredJobs.length,
              itemBuilder: (context, index) {
                final job = filteredJobs[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job["jobId"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      Text(job["customer"]),
                      Text(
                        job["description"],
                        style: const TextStyle(fontSize: 12),
                      ),

                      const Divider(),

                      ...job["processes"].entries.map<Widget>((entry) {
                        return Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(
                              entry.value,
                              style: TextStyle(
                                color: entry.value == "Completed"
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
