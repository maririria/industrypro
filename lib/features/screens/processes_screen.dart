// lib/features/screens/processes_screen.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'process_detail_screen.dart';

class ProcessesScreen extends StatefulWidget {
  final List<dynamic>? userRoles;

  const ProcessesScreen({super.key, this.userRoles});

  @override
  State<ProcessesScreen> createState() => _ProcessesScreenState();
}

class _ProcessesScreenState extends State<ProcessesScreen> {
  @override
  Widget build(BuildContext context) {
    final stream = Supabase.instance.client.from('processes').stream(primaryKey: ['process_id']);

    return Scaffold(
      backgroundColor: Colors.blueGrey[900], 
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Processes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
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
                    return const Center(child: Text("No processes found", style: TextStyle(color: Colors.white)));
                  }

                  // 🛠️ FILTER LOGIC: User roles ke mutabiq
                  final allProcesses = snapshot.data!;
                  final filteredProcesses = allProcesses.where((process) {
                    final pName = process['process_name']?.toString().toLowerCase() ?? "";
                    if (widget.userRoles != null && widget.userRoles!.contains('admin')) {
                      return true;
                    }
                    return widget.userRoles?.any((role) => pName.contains(role.toString().toLowerCase())) ?? false;
                  }).toList();

                  if (filteredProcesses.isEmpty) {
                    return const Center(child: Text("No authorized processes", style: TextStyle(color: Colors.white70)));
                  }

                  return ListView.builder(
                    itemCount: filteredProcesses.length,
                    itemBuilder: (context, index) {
                      final process = filteredProcesses[index];
                      final int safeId = int.tryParse(process['process_id'].toString()) ?? 0;

                      return GestureDetector(
                        onTap: () {
                          if (safeId != 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProcessDetailScreen(
                                  processId: safeId,
                                  processName: process['process_name']?.toString() ?? 'Unknown',
                                  userRoles: widget.userRoles, // 🔹 PASSING ROLES
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                process['process_name'] ?? 'N/A',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                            ],
                          ),
                        ),
                      );
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
}