import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProcessDetailScreen extends StatefulWidget {
  final String processName;
  const ProcessDetailScreen({super.key, required this.processName});

  @override
  State<ProcessDetailScreen> createState() => _ProcessDetailScreenState();
}

class _ProcessDetailScreenState extends State<ProcessDetailScreen> {
  String selectedFilter = "All";
  
  // DUMMY DATA
  List<Map<String, String>> dummyJobs = [
    {"id": "1230978", "subId": "1", "customer": "Fawad", "status": "Pending"},
    {"id": "1120987", "subId": "1", "customer": "Asfand", "status": "Pending"},
    {"id": "11209", "subId": "2", "customer": "Atif Aslam", "status": "Completed"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/images/bg_dark.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildProgressBar(context),
                _buildSearchAndFilter(),
                _buildJobsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Header with Back Button
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            widget.processName,
            style: GoogleFonts.balooBhai2(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 2. Percentage Bar (Clickable as per your sketch)
  Widget _buildProgressBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showProgressDetails(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 15,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                ),
                FractionallySizedBox(
                  widthFactor: 0.3, // 30% Progress
                  child: Container(
                    height: 15,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.purple, Colors.blue]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text("30% Progress (Click for details)", style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // 3. Search & Filter Section
  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search by Job ID...",
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["All", "Pending", "Completed"].map((f) {
              return ChoiceChip(
                label: Text(f),
                selected: selectedFilter == f,
                onSelected: (val) => setState(() => selectedFilter = f),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 4. Jobs List (The Cards in your sketch)
  Widget _buildJobsList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dummyJobs.length,
        itemBuilder: (context, index) {
          final job = dummyJobs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${job['id']} / ${job['subId']}", 
                      style: GoogleFonts.balooBhai2(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: job['status'] == "Pending" ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(job['status']!, style: TextStyle(color: job['status'] == "Pending" ? Colors.orange : Colors.greenAccent, fontSize: 12)),
                    ),
                  ],
                ),
                Text("Customer: ${job['customer']}", style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 15),
                if (job['status'] == "Pending")
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: const Text("Mark Completed", style: TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Progress Detail Dialog
  void _showProgressDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Progress Details", style: GoogleFonts.balooBhai2(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow("Total Jobs", "10"),
            _detailRow("Completed", "3"),
            _detailRow("Pending", "7"),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}