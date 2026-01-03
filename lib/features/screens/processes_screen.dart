import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/theme_provider.dart';
import 'process_detail_screen.dart';

class ProcessesScreen extends StatelessWidget {
  const ProcessesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final scale = themeProvider.fontSizeMultiplier;
    final primaryColor = isDark ? Colors.white : const Color(0xFF4A148C);

    final stream = Supabase.instance.client.from('processes').stream(primaryKey: ['process_id']);

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40), 
            Text(
              "Select Process",
              style: GoogleFonts.balooBhai2(
                fontSize: 28 * scale,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: primaryColor)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No processes found", style: TextStyle(color: primaryColor)));
                  }

                  final processesList = snapshot.data!;

                  return ListView.builder(
                    itemCount: processesList.length,
                    itemBuilder: (context, index) {
                      final process = processesList[index];
                      final String processName = process['process_name']?.toString() ?? 'Unknown';
                      final int safeId = int.tryParse(process['process_id'].toString()) ?? 0;

                      return GestureDetector(
                        onTap: () {
                          if (safeId != 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProcessDetailScreen(
                                  processId: safeId,
                                  processName: processName,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Error: Process ID not found"))
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black12, blurRadius: 10)],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                processName,
                                style: GoogleFonts.balooBhai2(
                                  fontSize: 20 * scale,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, color: primaryColor, size: 18),
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