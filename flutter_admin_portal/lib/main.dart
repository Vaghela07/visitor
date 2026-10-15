import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_colors.dart';
import 'config/app_consts.dart';
import 'config/get_di.dart';
import 'views/admin_dashboard_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GetDI.init();
  runApp(const SmartTVAdminApp());
}

class SmartTVAdminApp extends StatelessWidget {
  const SmartTVAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: GetDI.adminViewModel),
      ],
      child: MaterialApp(
        title: AppConsts.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.accentGold,
            surface: AppColors.surface,
          ),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const AdminDashboardView(),
      ),
    );
  }
}
