import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_consts.dart';
import '../config/log_utils.dart';
import '../models/visitor_model.dart';

class VisitorRepository {
  final http.Client client;

  VisitorRepository({http.Client? client}) : client = client ?? http.Client();

  Future<List<VisitorModel>> getVisitors() async {
    try {
      final uri = Uri.parse('${AppConsts.baseUrl}${AppConsts.epVisitors}');
      final response = await client.get(uri).timeout(AppConsts.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['visitors'] is List) {
          return (data['visitors'] as List)
              .map((jsonItem) => VisitorModel.fromJson(jsonItem))
              .toList();
        }
      }
      return [];
    } catch (e, stack) {
      LogUtils.error('Failed to fetch visitors', error: e, stackTrace: stack);
      return [];
    }
  }

  Future<bool> approveVisitor(String id) async {
    try {
      final uri = Uri.parse('${AppConsts.baseUrl}${AppConsts.epApproveVisitor}/$id');
      final response = await client.post(uri).timeout(AppConsts.requestTimeout);
      return response.statusCode == 200;
    } catch (e, stack) {
      LogUtils.error('Failed to approve visitor: $id', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> rejectVisitor(String id) async {
    try {
      final uri = Uri.parse('${AppConsts.baseUrl}${AppConsts.epRejectVisitor}/$id');
      final response = await client.post(uri).timeout(AppConsts.requestTimeout);
      return response.statusCode == 200;
    } catch (e, stack) {
      LogUtils.error('Failed to reject visitor: $id', error: e, stackTrace: stack);
      return false;
    }
  }
}
