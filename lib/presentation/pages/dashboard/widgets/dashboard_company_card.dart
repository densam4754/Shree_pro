import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/devices/domain/entities/device_group_entity.dart';
import 'dashboard_shared_widgets.dart';

class DashboardCompanyCard extends StatelessWidget {
  const DashboardCompanyCard({
    super.key,
    required this.theme,
    required this.isDark,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedGroup,
    required this.deviceGroups,
    required this.onGroupSelected,
  });

  final ThemeData theme;
  final bool isDark;
  final bool isLoading;
  final String? errorMessage;
  final DeviceGroupEntity? selectedGroup;
  final List<DeviceGroupEntity> deviceGroups;
  final ValueChanged<DeviceGroupEntity> onGroupSelected;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return DashboardStatusCard(
        theme: theme,
        isDark: isDark,
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: 'Loading company info...',
      );
    }

    if (errorMessage != null) {
      return DashboardStatusCard(
        theme: theme,
        isDark: isDark,
        title: 'Company information unavailable',
        subtitle: errorMessage ?? 'Unable to load data. Please try again later.',
      );
    }

    if (selectedGroup == null) {
      return DashboardStatusCard(
        theme: theme,
        isDark: isDark,
        title: 'No company data found',
        subtitle: 'Make sure your account is linked to a company.',
      );
    }

    final group = selectedGroup!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.spName.isNotEmpty ? group.spName : 'Company',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.white : AppTheme.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (deviceGroups.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: PopupMenuButton<DeviceGroupEntity>(
                              onSelected: onGroupSelected,
                              itemBuilder: (context) {
                                return deviceGroups.map((group) {
                                  return PopupMenuItem<DeviceGroupEntity>(
                                    value: group,
                                    child: Text(
                                      group.spName.isNotEmpty
                                          ? group.spName
                                          : group.spRefNum,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  );
                                }).toList();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.grey700
                                      : AppTheme.grey100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      group.spName.isNotEmpty
                                          ? group.spName
                                          : group.spRefNum,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppTheme.white
                                            : AppTheme.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: isDark
                                          ? AppTheme.white
                                          : AppTheme.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DashboardInfoRow(
                      theme: theme,
                      isDark: isDark,
                      icon: Icons.local_gas_station_outlined,
                      label: 'Reference',
                      value: group.spRefNum,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

