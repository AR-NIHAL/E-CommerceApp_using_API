import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../dose_tracking/domain/entities/dose_occurrence.dart';
import '../../../dose_tracking/presentation/providers/dose_providers.dart';
import '../../../dose_tracking/presentation/widgets/reminder_modal.dart';
import '../widgets/day_selector_strip.dart';
import '../widgets/dose_schedule_card.dart';
import '../widgets/progress_ring_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dosesAsync = ref.watch(todayDosesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(todayDosesProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Top Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greetingTime(),
                            style: AppTypography.displayMedium.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Row(
                            children: [
                              Text(
                                'Take care today!',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('💙', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      // Profile Avatar
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Date Selector Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: DaySelectorStrip(
                    selectedDate: _selectedDate,
                    onDaySelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),
                ),
              ),

              // Circular Progress Ring Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: GestureDetector(
                    onTap: () => context.push('/stats'),
                    child: dosesAsync.when(
                      data: (doses) {
                        final takenCount = doses.where((d) => d.status == DoseStatus.taken).length;
                        return ProgressRingCard(
                          takenCount: takenCount,
                          totalCount: doses.length,
                        );
                      },
                      loading: () => const ProgressRingCard(takenCount: 0, totalCount: 0),
                      error: (_, _) => const ProgressRingCard(takenCount: 0, totalCount: 0),
                    ),
                  ),
                ),
              ),

              // "Today's Schedule" Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Schedule",
                        style: AppTypography.titleLarge,
                      ),
                      InkWell(
                        onTap: () => context.push('/add-medicine'),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Text(
                            '+ Add',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Doses List or Empty State
              dosesAsync.when(
                data: (doses) {
                  if (doses.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.medication_outlined,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No medications added yet',
                              style: AppTypography.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Add your first medicine and schedule to start tracking your health.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/add-medicine'),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Add Medicine'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final dose = doses[index];
                          return DoseScheduleCard(
                            dose: dose,
                            onTap: () {
                              if (dose.status == DoseStatus.pending) {
                                ReminderModal.show(context, dose);
                              }
                            },
                          );
                        },
                        childCount: doses.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Failed to load doses: $err',
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            context.push('/refills');
          } else if (index == 2) {
            context.push('/history');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_rounded),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _greetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
