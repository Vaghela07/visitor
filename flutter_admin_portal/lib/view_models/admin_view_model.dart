import 'package:flutter/foundation.dart';
import '../config/log_utils.dart';
import '../models/visitor_model.dart';
import '../models/tv_device_model.dart';
import '../repositories/visitor_repository.dart';
import '../repositories/tv_sync_repository.dart';

enum ViewState { initial, loading, success, error, empty }

class AdminViewModel extends ChangeNotifier {
  final VisitorRepository _visitorRepo;
  final TVSyncRepository _tvRepo;

  AdminViewModel({
    required VisitorRepository visitorRepo,
    required TVSyncRepository tvRepo,
  })  : _visitorRepo = visitorRepo,
        _tvRepo = tvRepo;

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  List<VisitorModel> _visitors = [];
  List<VisitorModel> get visitors => _visitors;

  Map<String, TVDeviceModel> _tvs = {};
  Map<String, TVDeviceModel> get tvs => _tvs;

  bool _autoApprove = true;
  bool get autoApprove => _autoApprove;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboardData() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      LogUtils.info('Loading TV status and visitors feed...');
      final tvResults = await _tvRepo.getTVStatuses();
      final visitorResults = await _visitorRepo.getVisitors();

      _tvs = tvResults;
      _visitors = visitorResults;

      if (_visitors.isEmpty && _tvs.isEmpty) {
        _state = ViewState.empty;
      } else {
        _state = ViewState.success;
      }
    } catch (e, stack) {
      LogUtils.error('Error in loadDashboardData', error: e, stackTrace: stack);
      _errorMessage = e.toString();
      _state = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> approveVisitor(String id) async {
    try {
      LogUtils.info('Approving visitor $id...');
      final ok = await _visitorRepo.approveVisitor(id);
      if (ok) {
        await loadDashboardData();
        return true;
      }
    } catch (e, stack) {
      LogUtils.error('Approve visitor error', error: e, stackTrace: stack);
    }
    return false;
  }

  Future<bool> forcePlayWelcome(String id) async {
    return approveVisitor(id);
  }

  Future<bool> rejectVisitor(String id) async {
    try {
      LogUtils.info('Rejecting visitor $id...');
      final ok = await _visitorRepo.rejectVisitor(id);
      if (ok) {
        await loadDashboardData();
        return true;
      }
    } catch (e, stack) {
      LogUtils.error('Reject visitor error', error: e, stackTrace: stack);
    }
    return false;
  }

  Future<bool> sendBroadcast(String message) async {
    if (message.trim().isEmpty) return false;
    try {
      LogUtils.info('Sending broadcast message to all TVs: $message');
      return await _tvRepo.broadcastMessage(message.trim());
    } catch (e, stack) {
      LogUtils.error('Broadcast message error', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<void> toggleAutoApprove(bool val) async {
    _autoApprove = val;
    notifyListeners();
    try {
      await _tvRepo.setAutoApprove(val);
      LogUtils.info('Auto-approve toggled to $val');
    } catch (e, stack) {
      LogUtils.error('Toggle auto-approve error', error: e, stackTrace: stack);
    }
  }
}
