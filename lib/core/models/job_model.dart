// lib/core/models/job_model.dart
class Job {
  final int id; // Ensure this matches DB type (int4)
  final String jobId;
  final String subJobId;
  final String status;
  final int processId;

  Job({
    required this.id,
    required this.jobId,
    required this.subJobId,
    required this.status,
    required this.processId,
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      // ?? 0 ka matlab hai agar null aaye toh crash na ho balkay 0 assign ho jaye
      id: map['id'] ?? 0, 
      jobId: map['job_id']?.toString() ?? 'N/A',
      subJobId: map['sub_job_id']?.toString() ?? 'N/A',
      status: map['status'] ?? 'pending',
      processId: map['process_id'] ?? 0,
    );
  }
}