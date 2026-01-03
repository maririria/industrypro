import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../screens/process_stats_screen.dart';

class ProcessDetailView extends StatefulWidget {
  final String title;
  final int processId;

  const ProcessDetailView({super.key, required this.title, required this.processId});

  @override
  State<ProcessDetailView> createState() => _ProcessDetailViewState();
}

class _ProcessDetailViewState extends State<ProcessDetailView> {
  String selectedFilter = "all";
  
  // Dummy data
  final List<Map<String, dynamic>> dummyJobs = [
    {"job_id": "1230978", "sub_job_id": "1", "customer": "Fawad", "status": "pending"},
    {"job_id": "1120987", "sub_job_id": "1", "customer": "Asfand", "status": "pending"},
    {"job_id": "11209", "sub_job_id": "1", "customer": "Atif Aslam", "status": "completed"},
  ];

  @override
  Widget build(BuildContext context) {
    // Ye line sab se zaroori hai settings ko follow karne ke liye
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDark;
    final double scale = themeProvider.fontSizeMultiplier;

    // Light theme mein Deep Purple aur Dark mein White text
    final Color primaryColor = isDark ? Colors.white : const Color(0xFF4A148C);
    final Color secondaryColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      // Scaffold ko transparent rakhein taake hum apna dynamic background laga sakein
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(isDark ? 'assets/images/bg_dark.png' : 'assets/images/bg_light.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, primaryColor, scale),
              _buildProgressCard(isDark, scale, primaryColor),
              _buildSearchAndFilters(isDark, primaryColor, scale),
              _buildJobsList(isDark, primaryColor, scale, secondaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color, double scale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: color, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            widget.title,
            style: GoogleFonts.balooBhai2(
              fontSize: 28 * scale,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(bool isDark, double scale, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProcessStatsScreen(title: widget.title)),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Overall Progress", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14 * scale)),
                Text("30%", style: GoogleFonts.balooBhai2(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18 * scale)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.3,
                minHeight: 12,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
              ),
            ),
            const SizedBox(height: 8),
            Text("Tap to see detailed counts", style: TextStyle(fontSize: 10 * scale, color: isDark ? Colors.white38 : Colors.black38)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDark, Color primary, double scale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          TextField(
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Search Job ID...",
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
              prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.black38),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: ["all", "pending", "completed"].map((tab) {
              bool isSelected = selectedFilter == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(tab.toUpperCase(), style: TextStyle(fontSize: 10 * scale)),
                  selected: isSelected,
                  onSelected: (val) => setState(() => selectedFilter = tab),
                  selectedColor: Colors.deepPurple,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54)),
                  backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.3),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(bool isDark, Color primary, double scale, Color secondary) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: dummyJobs.length,
        itemBuilder: (context, index) {
          final job = dummyJobs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${job['job_id']} / ${job['sub_job_id']}", 
                      style: TextStyle(color: primary, fontSize: 18 * scale, fontWeight: FontWeight.bold)),
                    _statusBadge(job['status']),
                  ],
                ),
                Text("Customer: ${job['customer']}", style: TextStyle(color: secondary, fontSize: 14 * scale)),
                if (job['status'] == "pending") ...[
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: const Text("Mark Completed", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    bool isPen = status == "pending";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPen ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: TextStyle(color: isPen ? Colors.orange : Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}