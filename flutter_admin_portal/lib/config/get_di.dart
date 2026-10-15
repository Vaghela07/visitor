import 'package:http/http.dart' as http;
import '../repositories/visitor_repository.dart';
import '../repositories/tv_sync_repository.dart';
import '../view_models/admin_view_model.dart';
import 'log_utils.dart';

class GetDI {
  GetDI._();

  static late final http.Client httpClient;
  static late final VisitorRepository visitorRepository;
  static late final TVSyncRepository tvSyncRepository;
  static late final AdminViewModel adminViewModel;

  static void init() {
    LogUtils.info('Initializing Enterprise Dependency Injection (GetDI)...');
    httpClient = http.Client();
    visitorRepository = VisitorRepository(client: httpClient);
    tvSyncRepository = TVSyncRepository(client: httpClient);
    adminViewModel = AdminViewModel(
      visitorRepo: visitorRepository,
      tvRepo: tvSyncRepository,
    );
    LogUtils.info('Dependency Injection setup complete.');
  }
}
