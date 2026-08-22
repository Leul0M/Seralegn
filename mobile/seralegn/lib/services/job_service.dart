import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job.dart';
import 'auth_service.dart';
import 'hive_service.dart';

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

  Future<void> claimJob({
    required String jobId,
    required String workerPhone,
  }) async {
    // 1. Try active session or sync
    String? workerId = _client.auth.currentUser?.id;
    if (workerId == null || workerId.isEmpty || !workerId.contains('-')) {
      workerId = await AuthService.instance.ensureSupabaseSession();
    }

    // 2. Query workers table by phone
    if (workerId == null || workerId.isEmpty || !workerId.contains('-')) {
      final cleaned = workerPhone.replaceAll(RegExp(r'\D'), '');
      final existing = await _client
          .from('workers')
          .select('id')
          .eq('phone_number', cleaned)
          .maybeSingle();
      if (existing != null) {
        workerId = existing['id'] as String;
      }
    }

    // 3. Fallback: if worker still doesn't exist in DB, create one using a random UUID
    if (workerId == null || workerId.isEmpty || !workerId.contains('-')) {
      final newUuid = _generateUuidV4();
      final cleaned = workerPhone.replaceAll(RegExp(r'\D'), '');
      final userData = HiveService.instance.getUserData();
      final name = (userData['fullName'] as String?) ?? 'Worker';
      final fayda = (userData['faydaNumber'] as String?)?.trim();
      final faydaVal = (fayda != null && fayda.isNotEmpty && fayda != 'N/A') ? fayda : null;

      final insertData = <String, dynamic>{
        'id': newUuid,
        'full_name': name,
        'phone_number': cleaned,
        'fayda_verified': false,
      };
      if (faydaVal != null) {
        insertData['fayda_number'] = faydaVal;
      }

      await _client.from('workers').insert(insertData);
      workerId = newUuid;
    }

    // 4. Atomic claim via claim_job_securely RPC function
    try {
      final success = await _client.rpc('claim_job_securely', params: {
        'p_job_id': jobId,
        'p_worker_id': workerId,
      });

      if (success != true) {
        // Fallback to direct update if RPC fails or non-matching UID
        await _client.from('jobs').update({
          'worker_id': workerId,
          'status': 'claimed',
          'claimed_at': DateTime.now().toIso8601String(),
        }).eq('id', jobId).eq('status', 'open');
      }
    } catch (_) {
      // Direct update fallback
      await _client.from('jobs').update({
        'worker_id': workerId,
        'status': 'claimed',
        'claimed_at': DateTime.now().toIso8601String(),
      }).eq('id', jobId);
    }
  }

  String _generateUuidV4() {
    final r = Random();
    String printHex(int val, int len) {
      return val.toRadixString(16).padLeft(len, '0');
    }
    final part1 = r.nextInt(0xFFFFFFFF);
    final part2 = r.nextInt(0xFFFF);
    final part3 = (r.nextInt(0x0FFF) | 0x4000);
    final part4 = (r.nextInt(0x3FFF) | 0x8000);
    final part5 = r.nextInt(0xFFFFFFFF);
    final part6 = r.nextInt(0xFFFF);

    return '${printHex(part1, 8)}-${printHex(part2, 4)}-${printHex(part3, 4)}-${printHex(part4, 4)}-${printHex(part5, 8)}${printHex(part6, 4)}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update job status (for worker progress updates)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    final statusStr = switch (status) {
      JobStatus.open             => 'open',
      JobStatus.accepted         => 'claimed',
      JobStatus.inProgress       => 'in_progress',
      JobStatus.awaitingApproval => 'pending_confirmation',
      JobStatus.completed        => 'completed',
      JobStatus.cancelled        => 'cancelled',
    };

    final updateMap = <String, dynamic>{'status': statusStr};
    if (status == JobStatus.awaitingApproval) {
      updateMap['is_completed'] = false;
    } else if (status == JobStatus.completed) {
      updateMap['is_completed'] = true;
      updateMap['completed_at'] = DateTime.now().toIso8601String();
    }

    await _client
        .from('jobs')
        .update(updateMap)
        .eq('id', jobId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Approve job completion (Client action)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> approveJobCompletion({
    required String jobId,
    required String clientId,
  }) async {
    try {
      await _client.rpc('approve_job_completion', params: {
        'p_job_id': jobId,
        'p_client_id': clientId,
      });
    } catch (_) {
      // Fallback direct update
      await _client
          .from('jobs')
          .update({
            'is_completed': true,
            'status': 'completed',
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', jobId);
    }
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

