// lib/core/models/job_process_model.dart
class JobProcess {
  final String id;
  final String jobId;
  final String subJobId;
  final int processId;
  String status; // 'pending' or 'completed'
  final String? employeeCode;

  JobProcess({
    required this.id,
    required this.jobId,
    required this.subJobId,
    required this.processId,
    required this.status,
    this.employeeCode,
  });

  factory JobProcess.fromJson(Map<String, dynamic> json) {
    return JobProcess(
      id: json['id'].toString(),
      jobId: json['job_id'],
      subJobId: json['sub_job_id'],
      processId: json['process_id'],
      status: json['status'],
      employeeCode: json['employee_code'],
    );
  }
}