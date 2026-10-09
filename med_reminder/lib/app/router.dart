import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/widgets/app_button.dart';

import '../features/dose_tracking/domain/entities/dose_occurrence.dart';
import '../features/dose_tracking/presentation/screens/taken_success_screen.dart';
import '../features/history/presentation/screens/history_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/medicines/presentation/screens/add_medicine_screen.dart';
import '../features/medicines/presentation/screens/medicine_details_screen.dart';
import '../features/medicines/presentation/screens/refill_reminder_screen.dart';
import '../features/stats/presentation/screens/stats_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-medicine',
      builder: (context, state) => const AddMedicineScreen(),
    ),
    GoRoute(
      path: '/taken-success',
      builder: (context, state) {
        final dose = state.extra as DoseOccurrence;
        return TakenSuccessScreen(dose: dose);
      },
    ),
    GoRoute(
      path: '/medicines/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return MedicineDetailsScreen(medicineId: id);
      },
    ),
    GoRoute(
      path: '/refills',
      builder: (context, state) => const RefillReminderScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const StatsScreen(),
    ),
  ],
);

/// Initial screen demonstrating that Feature 0 (Theme, Tokens, Hive, Router, Riverpod) is active.
class FoundationReadyScreen extends StatelessWidget {
  const FoundationReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MediCare', style: AppTypography.titleLarge),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Feature 0 Complete',
                                style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Foundation & Design System Active',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 12),
                    _buildCheckItem('Clean Architecture Directory Structure'),
                    _buildCheckItem('MediCare Color Palette & Typography Tokens'),
                    _buildCheckItem('Riverpod ProviderScope & State Management'),
                    _buildCheckItem('Hive Local Storage Service Initialized'),
                    _buildCheckItem('GoRouter Navigation Configured'),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Open Add Medicine Screen',
                variant: AppButtonVariant.primary,
                onPressed: () => context.push('/add-medicine'),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Feature 3: Add Medicine UI & Navigation',
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.done_rounded, size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
