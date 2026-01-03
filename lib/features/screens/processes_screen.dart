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
                  if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No processes found"));

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
                          }
                        },
child: Container(
  margin: const EdgeInsets.only(bottom: 15),
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  decoration: BoxDecoration(
    color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.6),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded( 
        child: Text(
          processName,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: GoogleFonts.balooBhai2(
            fontSize: 20 * scale,
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
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