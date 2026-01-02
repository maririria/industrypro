import 'package:flutter/material.dart';
import '../components/process_detail_view.dart'; 
class PastingScreen extends StatelessWidget {
  const PastingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProcessDetailView(
      title: "Pasting Jobs", 
      processId: 20,
    );
  }
}