import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job.dart';
import 'auth_service.dart';

/// Service that handles all Supabase operations for jobs.
class JobService {
  static final JobService instance = JobService._();
  JobService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ─────────────────────────────────────────────────────────────────────────
  // Fetch open jobs (for Worker marketplace)
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Job>> fetchOpenJobs() async {
    final response = await _client
        .from('jobs')
        .select()
        .eq('status', 'open')
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => Job.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fetch all jobs posted by a specific client (for Client home)
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Job>> fetchClientJobs(String phoneOrId) async {
    final clean = phoneOrId.trim();
    if (clean.isEmpty) return [];

    final isPhone = !clean.contains('-');
    final queryField = isPhone ? 'client_phone' : 'client_id';

    final response = await _client
        .from('jobs')
        .select()
        .eq(queryField, clean)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => Job.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Post a new job (with optional image upload)
  // ─────────────────────────────────────────────────────────────────────────
  Future<({Job job, int failedUploads})> postJob({
    required Job job,
    required String clientId,
    required List<XFile> imageFiles,
  }) async {
    String activeClientId = clientId.trim();
    if (activeClientId.isEmpty) {
      activeClientId = _client.auth.currentUser?.id ?? '';
    }
    if (activeClientId.isEmpty) {
      activeClientId = (await AuthService.instance.ensureSupabaseSession()) ?? '';
    }

    // 1. Upload images to Supabase Storage — each upload is independent;
    //    a failed upload is skipped so the job posting never gets blocked.
    final List<String> uploadedUrls = [];
    int failedUploads = 0;

    final uploadFolder = activeClientId.isNotEmpty
        ? activeClientId
        : 'public_${DateTime.now().millisecondsSinceEpoch}';

    for (int i = 0; i < imageFiles.length; i++) {
      final xFile = imageFiles[i];
      try {
        final bytes = await xFile.readAsBytes();
        final ext = xFile.name.split('.').last.toLowerCase();
        final fileName =
            '$uploadFolder/${DateTime.now().millisecondsSinceEpoch}_$i.$ext';

        await _client.storage.from('job-photos').uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: _mimeType(ext),
            upsert: true,
          ),
        );

        final publicUrl =
            _client.storage.from('job-photos').getPublicUrl(fileName);
        uploadedUrls.add(publicUrl);
      } catch (_) {
        // This image failed to upload — skip it, don't block the whole job.
        failedUploads++;
      }
    }

    // 2. Build the insert map — use whatever URLs were successfully uploaded.
    final insertMap = job.toMap(clientId: activeClientId);
    insertMap['photos'] = uploadedUrls;

    // 3. Insert and get back the created row.
    final response = await _client
        .from('jobs')
        .insert(insertMap)
        .select()
        .single();

    return (job: Job.fromMap(response), failedUploads: failedUploads);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cancel an open job (client only, status must be 'open')
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> cancelJob(String jobId) async {
    await _client
        .from('jobs')
        .update({'status': 'cancelled'})
        .eq('id', jobId)
        .eq('status', 'open'); // Safety: only cancel open jobs
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Worker claims / accepts a job
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> claimJob({
    required String jobId,
    required String workerId,
  }) async {
    await _client.from('jobs').update({
      'status': 'accepted',
      'worker_id': workerId,
      'claimed_at': DateTime.now().toIso8601String(),
    }).eq('id', jobId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update job status (for worker progress updates)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    final statusStr = switch (status) {
      JobStatus.open             => 'open',
      JobStatus.accepted         => 'accepted',
      JobStatus.inProgress       => 'inprogress',
      JobStatus.awaitingApproval => 'awaiting_approval',
      JobStatus.completed        => 'completed',
      JobStatus.cancelled        => 'cancelled',
    };
    await _client
        .from('jobs')
        .update({'status': statusStr})
        .eq('id', jobId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────
  String _mimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png':  return 'image/png';
      case 'webp': return 'image/webp';
      case 'heic': return 'image/heic';
      default:     return 'image/jpeg';
    }
  }
}
