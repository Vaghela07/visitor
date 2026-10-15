import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_string.dart';
import '../models/tv_device_model.dart';
import '../models/visitor_model.dart';
import '../view_models/admin_view_model.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final TextEditingController _broadcastController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadDashboardData();
    });
  }

  @override
  void dispose() {
    _broadcastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              AppString.dashboardTitle,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              AppString.dashboardSubtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accentGold),
            onPressed: () => context.read<AdminViewModel>().loadDashboardData(),
          ),
        ],
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, vm, child) {
          switch (vm.state) {
            case ViewState.loading:
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accentGold),
              );
            case ViewState.error:
              return _buildErrorView(vm);
            case ViewState.empty:
            case ViewState.success:
            case ViewState.initial:
              return _buildDashboardContent(context, vm);
          }
        },
      ),
    );
  }

  Widget _buildErrorView(AdminViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            AppString.errorLoading,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold),
            onPressed: () => vm.loadDashboardData(),
            child: const Text('Try Again', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, AdminViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTVMonitorSection(vm),
          const SizedBox(height: 20),
          _buildQuickBroadcastSection(vm),
          const SizedBox(height: 20),
          _buildSettingsSection(vm),
          const SizedBox(height: 24),
          _buildVisitorFeedSection(vm),
        ],
      ),
    );
  }

  Widget _buildTVMonitorSection(AdminViewModel vm) {
    return Card(
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppString.tvMonitorTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'webOS 22',
                    style: TextStyle(color: AppColors.accentGold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (vm.tvs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Scanning for connected TVs...', style: TextStyle(color: AppColors.textSecondary)),
              )
            else
              ...vm.tvs.values.map((tv) => _buildTVRow(tv)),
          ],
        ),
      ),
    );
  }

  Widget _buildTVRow(TVDeviceModel tv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.tv, color: tv.isOnline ? AppColors.online : AppColors.offline, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tv.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  Text('${tv.location} • ${tv.isPriorityMode ? "5-Min Welcome" : "Ambient"}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tv.isOnline ? AppColors.online.withValues(alpha: 0.15) : AppColors.offline.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tv.isOnline ? AppString.statusOnline : AppString.statusOffline,
              style: TextStyle(
                color: tv.isOnline ? AppColors.online : AppColors.offline,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBroadcastSection(AdminViewModel vm) {
    return Card(
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📢 Quick Alert Broadcast',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _broadcastController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. Dinner is ready in dining hall...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    vm.sendBroadcast(_broadcastController.text);
                    _broadcastController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Broadcast sent to all 3 TVs!')),
                    );
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(AdminViewModel vm) {
    return Card(
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(AppString.autoApproveLabel,
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(AppString.autoApproveDesc,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Switch(
              value: vm.autoApprove,
              activeThumbColor: AppColors.accentGold,
              onChanged: (val) => vm.toggleAutoApprove(val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorFeedSection(AdminViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppString.visitorQueueTitle,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (vm.visitors.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Text(AppString.emptyVisitors,
                style: const TextStyle(color: AppColors.textSecondary)),
          )
        else
          ...vm.visitors.map((visitor) => _buildVisitorCard(vm, visitor)),
      ],
    );
  }

  Widget _buildVisitorCard(AdminViewModel vm, VisitorModel visitor) {
    return Card(
      color: AppColors.cardBg,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visitor.name,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${visitor.phone} • ${visitor.timestamp.hour}:${visitor.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: visitor.isApproved ? AppColors.success.withValues(alpha: 0.2) : AppColors.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    visitor.isApproved ? 'APPROVED' : 'PENDING',
                    style: TextStyle(
                      color: visitor.isApproved ? AppColors.success : AppColors.accentGold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (visitor.photos.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: visitor.photos.length,
                  itemBuilder: (context, idx) {
                    final photoUrl = visitor.photos[idx].startsWith('http')
                        ? visitor.photos[idx]
                        : 'http://localhost:5000${visitor.photos[idx]}';
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                        image: DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => vm.forcePlayWelcome(visitor.id),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text(AppString.forcePlayBtn, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => vm.rejectVisitor(visitor.id),
                  child: const Text(AppString.rejectBtn, style: TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
