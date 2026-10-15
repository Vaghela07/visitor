import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_consts.dart';
import '../config/log_utils.dart';
import '../models/tv_device_model.dart';

class TVSyncRepository {
  final http.Client client;

  TVSyncRepository({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, TVDeviceModel>> getTVStatuses() async {
    try {
      final uri = Uri.parse('${AppConsts.baseUrl}${AppConsts.epTVStatus}');
      final response = await client.get(uri).timeout(AppConsts.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['tvs'] is Map) {
          final Map<String, TVDeviceModel> result = {};
          (data['tvs'] as Map<String, dynamic>).forEach((key, val) {
            result[key] = TVDeviceModel.fromJson(val);
          });
          return result;
        }
      }
      return {};
    } catch (e, stack) {
      LogUtils.error('Failed to get TV statuses', error: e, stackTrace: stack);
      return {};
    }
  }

  Future<bool> broadcastMessage(String message, {int durationSeconds = 15}) async {
    try {
      final uri = Uri.parse('${AppConsts.baseUrl}${AppConsts.epBroadcast}');
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          'durationSeconds': durationSeconds,
        }),
      ).timeout(AppConsts.requestTimeout);
      return response.statusCode == 200;
    } catch (e, stack) {
      LogUtils.error('Failed to broadcast message', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> setAutoApprove(bool autoApprove) async {
    try {
      final uri = Uri.parse('${AppConsts.baseUrl}${AppConsts.epSettings}');
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'autoApprove': autoApprove}),
      ).timeout(AppConsts.requestTimeout);
      return response.statusCode == 200;
    } catch (e, stack) {
      LogUtils.error('Failed to update settings', error: e, stackTrace: stack);
      return false;
    }
  }
}
