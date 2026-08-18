import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/home_owner_model.dart';
import '../models/worker_model.dart';
import '../models/job_model.dart';
import '../services/supabase_service.dart';

abstract class DatabaseRepository {
  Future<HomeOwnerModel?> getHomeOwnerProfile(String id);
  Future<WorkerModel?> getWorkerProfile(String id);
  
  Future<void> createJob(JobModel job);
  Future<List<JobModel>> getHomeOwnerJobs(String homeownerId);
  Future<List<JobModel>> getOpenJobs();
  Future<List<JobModel>> getWorkerActiveJobs(String workerId);
  
  Future<bool> claimJobSecurely({required String jobId, required String workerId});
  Future<void> updateJobStatus({required String jobId, required String status});
  Future<void> reportIssue({
    required String homeownerId,
    required String workerId,
    required String jobId,
    required String reason,
  });
  
  Future<void> renewSubscription({
    required String workerId,
    required double amount,
    required String txRef,
  });
  
  // Developer test helper to expire subscription in mock mode
  void simulateSubscriptionExpiration(String workerId);
}

class SupabaseDatabaseRepository implements DatabaseRepository {
  final _client = SupabaseService.instance.client;

  @override
  Future<HomeOwnerModel?> getHomeOwnerProfile(String id) async {
    try {
      final res = await _client.from('home_owners').select().eq('id', id).maybeSingle();
      if (res == null) return null;
      return HomeOwnerModel.fromJson(res);
    } catch (e) {
      if (kDebugMode) print('Error getHomeOwnerProfile: $e');
      rethrow;
    }
  }

  @override
  Future<WorkerModel?> getWorkerProfile(String id) async {
    try {
      final res = await _client.from('workers').select().eq('id', id).maybeSingle();
      if (res == null) return null;
      return WorkerModel.fromJson(res);
    } catch (e) {
      if (kDebugMode) print('Error getWorkerProfile: $e');
      rethrow;
    }
  }

  @override
  Future<void> createJob(JobModel job) async {
    try {
      // Omit id let database generate it, or pass it if you want
      final data = job.toJson();
      // If job.id starts with a mock or is temporary, remove it to let db generate
      if (job.id.contains('temp-')) {
        data.remove('id');
      }
      await _client.from('jobs').insert(data);
    } catch (e) {
      if (kDebugMode) print('Error createJob: $e');
      rethrow;
    }
  }

  @override
  Future<List<JobModel>> getHomeOwnerJobs(String homeownerId) async {
    try {
      final List<dynamic> res = await _client
          .from('jobs')
          .select()
          .eq('home_owner_id', homeownerId)
          .order('created_at', ascending: false);
      return res.map((e) => JobModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) print('Error getHomeOwnerJobs: $e');
      rethrow;
    }
  }

  @override
  Future<List<JobModel>> getOpenJobs() async {
    try {
      final List<dynamic> res = await _client
          .from('jobs')
          .select()
          .eq('status', 'open')
          .order('created_at', ascending: false);
      return res.map((e) => JobModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) print('Error getOpenJobs: $e');
      rethrow;
    }
  }

  @override
  Future<List<JobModel>> getWorkerActiveJobs(String workerId) async {
    try {
      final List<dynamic> res = await _client
          .from('jobs')
          .select()
          .eq('worker_id', workerId)
          .inFilter('status', ['claimed', 'in_progress', 'pending_confirmation'])
          .order('created_at', ascending: false);
      return res.map((e) => JobModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) print('Error getWorkerActiveJobs: $e');
      rethrow;
    }
  }

  @override
  Future<bool> claimJobSecurely({required String jobId, required String workerId}) async {
    try {
      final response = await _client.rpc('claim_job_securely', params: {
        'p_job_id': jobId,
        'p_worker_id': workerId,
      });
      return response as bool;
    } catch (e) {
      if (kDebugMode) print('Error claimJobSecurely RPC: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateJobStatus({required String jobId, required String status}) async {
    try {
      final updates = {
        'status': status,
      };
      if (status == 'in_progress') {
        updates['started_at'] = DateTime.now().toIso8601String();
      } else if (status == 'completed') {
        updates['completed_at'] = DateTime.now().toIso8601String();
      }
      await _client.from('jobs').update(updates).eq('id', jobId);
    } catch (e) {
      if (kDebugMode) print('Error updateJobStatus: $e');
      rethrow;
    }
  }

  @override
  Future<void> reportIssue({
    required String homeownerId,
    required String workerId,
    required String jobId,
    required String reason,
  }) async {
    try {
      await _client.from('reports').insert({
        'home_owner_id': homeownerId,
        'worker_id': workerId,
        'job_id': jobId,
        'reason': reason,
      });
      
      // Update job to cancelled or flagged, let's update status to cancelled
      await updateJobStatus(jobId: jobId, status: 'cancelled');
    } catch (e) {
      if (kDebugMode) print('Error reportIssue: $e');
      rethrow;
    }
  }

  @override
  Future<void> renewSubscription({
    required String workerId,
    required double amount,
    required String txRef,
  }) async {
    try {
      final newExpiry = DateTime.now().add(const Duration(days: 30));
      
      await _client.from('subscriptions').insert({
        'worker_id': workerId,
        'amount': amount,
        'chapa_tx_ref': txRef,
        'status': 'success',
      });
      
      await _client.from('workers').update({
        'subscription_expires_at': newExpiry.toIso8601String(),
      }).eq('id', workerId);
    } catch (e) {
      if (kDebugMode) print('Error renewSubscription: $e');
      rethrow;
    }
  }

  @override
  void simulateSubscriptionExpiration(String workerId) {
    // Only applies to mock repository
  }
}

class MockDatabaseRepository implements DatabaseRepository {
  // Static state to mock real-time changes
  static final List<JobModel> _mockJobs = [];
  static final Map<String, HomeOwnerModel> _mockHomeOwners = {};
  static final Map<String, WorkerModel> _mockWorkers = {};

  MockDatabaseRepository() {
    // Seed some mock jobs if empty
    if (_mockJobs.isEmpty) {
      _mockJobs.addAll([
        JobModel(
          id: 'mock-job-1',
          homeOwnerId: 'mock-ho-1',
          title: 'Fix Leaking Kitchen Sink',
          category: 'Plumbing',
          description: 'Looking for someone to fix a sink in my kitchen. It\'s been dripping continuously and seems to have a faulty connector.',
          offeredPrice: 400.00,
          status: 'open',
          locationLat: 9.0300,
          locationLng: 38.7400,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        JobModel(
          id: 'mock-job-2',
          homeOwnerId: 'mock-ho-2',
          title: 'Deep Clean 2B/1B Apartment',
          category: 'Cleaning',
          description: 'Move-out cleaning required for an empty 2 bedroom apartment. Focus on kitchen and bathrooms.',
          offeredPrice: 600.00,
          status: 'open',
          locationLat: 9.0120,
          locationLng: 38.7520,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        JobModel(
          id: 'mock-job-3',
          homeOwnerId: 'mock-ho-3',
          title: 'Install Ceiling Fan',
          category: 'Electrical',
          description: 'Need a qualified electrician to install a new ceiling fan in the living room. Wiring is already present from the previous fan.',
          offeredPrice: 850.00,
          status: 'open',
          locationLat: 9.0220,
          locationLng: 38.7650,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ]);

      // Seed dummy profiles
      _mockHomeOwners['mock-ho-1'] = HomeOwnerModel(id: 'mock-ho-1', fullName: 'Almaz Abebe', phoneNumber: '+251911111111');
      _mockHomeOwners['mock-ho-2'] = HomeOwnerModel(id: 'mock-ho-2', fullName: 'Kassahun Tilahun', phoneNumber: '+251922222222');
      _mockHomeOwners['mock-ho-3'] = HomeOwnerModel(id: 'mock-ho-3', fullName: 'Fasil Kebede', phoneNumber: '+251933333333');
    }
  }

  @override
  Future<HomeOwnerModel?> getHomeOwnerProfile(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockHomeOwners[id];
  }

  @override
  Future<WorkerModel?> getWorkerProfile(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Explicitly seed mockup workers
    if (id == 'mock-worker-abebe') {
      return WorkerModel(
        id: 'mock-worker-abebe',
        fullName: 'Abebe D.',
        phoneNumber: '+251911223344',
        faydaNumber: 'FAYDA-111222333',
        faydaVerified: true,
        trialEndsAt: DateTime.now().add(const Duration(days: 30)),
      );
    }
    if (id == 'mock-worker-samuel') {
      return WorkerModel(
        id: 'mock-worker-samuel',
        fullName: 'Samuel T.',
        phoneNumber: '+251922334455',
        faydaNumber: 'FAYDA-444555666',
        faydaVerified: true,
        trialEndsAt: DateTime.now().add(const Duration(days: 30)),
      );
    }

    // If worker doesn't exist, seed a default one
    if (!_mockWorkers.containsKey(id)) {
      _mockWorkers[id] = WorkerModel(
        id: id,
        fullName: 'Dawit Hailu',
        phoneNumber: '+251900000000',
        faydaNumber: 'FAYDA-987654321',
        trialEndsAt: DateTime.now().add(const Duration(days: 30)),
      );
    }
    return _mockWorkers[id];
  }

  @override
  Future<void> createJob(JobModel job) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Ensure homeowner exists in our mock data
    if (!_mockHomeOwners.containsKey(job.homeOwnerId)) {
      _mockHomeOwners[job.homeOwnerId] = HomeOwnerModel(
        id: job.homeOwnerId,
        fullName: 'Meaza Belay',
        phoneNumber: '+251912345678',
      );
    }

    final newJob = job.copyWith(
      id: job.id.startsWith('temp-') ? 'job-${DateTime.now().millisecondsSinceEpoch}' : job.id,
      createdAt: DateTime.now(),
    );
    _mockJobs.add(newJob);
  }

  @override
  Future<List<JobModel>> getHomeOwnerJobs(String homeownerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Seed initial dashboard jobs specifically for this homeowner to match mockup
    final userJobs = _mockJobs.where((e) => e.homeOwnerId == homeownerId).toList();
    if (userJobs.isEmpty) {
      _mockJobs.addAll([
        JobModel(
          id: 'mock-job-ho-active',
          homeOwnerId: homeownerId,
          workerId: 'mock-worker-abebe',
          title: 'Fix a leaking kitchen tap',
          category: 'Plumbing',
          description: 'The kitchen sink tap has a steady drip. Needs a plumber to repair or replace the washer.',
          offeredPrice: 450.00,
          status: 'in_progress',
          locationLat: 9.0300,
          locationLng: 38.7400,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        JobModel(
          id: 'mock-job-ho-closed',
          homeOwnerId: homeownerId,
          workerId: 'mock-worker-samuel',
          title: 'Mount flat screen TV on wall',
          category: 'Handyman',
          description: 'Need to mount a 55-inch TV on a concrete wall. Bracket is already purchased.',
          offeredPrice: 900.00,
          status: 'cancelled', // representing "Closed" / "Cancelled" state
          locationLat: 9.0120,
          locationLng: 38.7520,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ]);
    }

    return _mockJobs.where((e) => e.homeOwnerId == homeownerId).toList()
      ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
  }

  @override
  Future<List<JobModel>> getOpenJobs() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockJobs.where((e) => e.status == 'open').toList()
      ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
  }

  @override
  Future<List<JobModel>> getWorkerActiveJobs(String workerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockJobs
        .where((e) => e.workerId == workerId && ['claimed', 'in_progress', 'pending_confirmation'].contains(e.status))
        .toList()
      ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
  }

  @override
  Future<bool> claimJobSecurely({required String jobId, required String workerId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _mockJobs.indexWhere((e) => e.id == jobId);
    if (index != -1) {
      final job = _mockJobs[index];
      if (job.status == 'open' && job.workerId == null) {
        _mockJobs[index] = job.copyWith(
          workerId: workerId,
          status: 'claimed',
          claimedAt: DateTime.now(),
        );
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> updateJobStatus({required String jobId, required String status}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockJobs.indexWhere((e) => e.id == jobId);
    if (index != -1) {
      final job = _mockJobs[index];
      DateTime? started = job.startedAt;
      DateTime? completed = job.completedAt;
      
      if (status == 'in_progress') {
        started = DateTime.now();
      } else if (status == 'completed') {
        completed = DateTime.now();
      }
      
      _mockJobs[index] = job.copyWith(
        status: status,
        startedAt: started,
        completedAt: completed,
      );
    }
  }

  @override
  Future<void> reportIssue({
    required String homeownerId,
    required String workerId,
    required String jobId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    // In mock, increment flags for worker
    final worker = _mockWorkers[workerId];
    if (worker != null) {
      _mockWorkers[workerId] = worker.copyWith(
        flagCount: worker.flagCount + 1,
        isSuspended: worker.flagCount + 1 >= 3, // Suspended if flags reach 3
      );
    }
    
    await updateJobStatus(jobId: jobId, status: 'cancelled');
  }

  @override
  Future<void> renewSubscription({
    required String workerId,
    required double amount,
    required String txRef,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final worker = _mockWorkers[workerId];
    if (worker != null) {
      _mockWorkers[workerId] = worker.copyWith(
        subscriptionExpiresAt: DateTime.now().add(const Duration(days: 30)),
        trialEndsAt: DateTime.now().subtract(const Duration(days: 1)), // Ensure trial is past
      );
    }
  }

  @override
  void simulateSubscriptionExpiration(String workerId) {
    final worker = _mockWorkers[workerId];
    if (worker != null) {
      _mockWorkers[workerId] = worker.copyWith(
        trialEndsAt: DateTime.now().subtract(const Duration(days: 10)),
        subscriptionExpiresAt: DateTime.now().subtract(const Duration(days: 10)),
      );
    }
  }
}
