import 'package:flutter/material.dart';
import 'process_detail_screen.dart';

class ProcessesScreen extends StatelessWidget {
  const ProcessesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final processes = [
      {"title": "Printing", "id": 1},
      {"title": "Cutting", "id": 2},
      {"title": "Lamination", "id": 3},
      {"title": "Pasting", "id": 4},
      {"title": "Varnish", "id": 5},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Processes")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: processes.length,
        itemBuilder: (context, index) {
          final p = processes[index];

          return Card(
            child: ListTile(
              title: Text(p["title"].toString()),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProcessDetailScreen(
                      title: p["title"].toString(),
                      processId: p["id"] as int,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
