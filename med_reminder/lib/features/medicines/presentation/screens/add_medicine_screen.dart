import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/medicine.dart';
import '../controllers/add_medicine_controller.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _strengthController;
  late final TextEditingController _dosageController;
  late final TextEditingController _totalQuantityController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(addMedicineControllerProvider);
    _nameController = TextEditingController(text: state.name);
    _strengthController = TextEditingController(text: state.strength);
    _dosageController = TextEditingController(text: state.dosage);
    _totalQuantityController = TextEditingController(text: state.totalQuantity);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _strengthController.dispose();
    _dosageController.dispose();
    _totalQuantityController.dispose();
    super.dispose();
  }

  void _showAddScheduleBottomSheet() {
    TimeOfDay selectedTime = const TimeOfDay(hour: 14, minute: 0);
    String selectedInstruction = 'After lunch';

    final mealOptions = [
      'Before breakfast',
      'After breakfast',
      'Before lunch',
      'After lunch',
      'Before dinner',
      'After dinner',
      'At bedtime',
      'As needed',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Schedule Time',
                        style: AppTypography.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(bottomSheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Time', style: AppTypography.bodySmall),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                        color: AppColors.background,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            selectedTime.format(context),
                            style: AppTypography.titleMedium.copyWith(color: AppColors.navy),
                          ),
                          const Spacer(),
                          const Text('Change', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Meal Instruction', style: AppTypography.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: mealOptions.map((opt) {
                      final isSelected = opt == selectedInstruction;
                      return ChoiceChip(
                        label: Text(opt),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        onSelected: (val) {
                          if (val) {
                            setModalState(() {
                              selectedInstruction = opt;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Add to Schedule',
                    onPressed: () {
                      ref.read(addMedicineControllerProvider.notifier).addSchedule(
                            selectedTime,
                            selectedInstruction,
                          );
                      Navigator.pop(bottomSheetContext);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addMedicineControllerProvider);
    final notifier = ref.read(addMedicineControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add Medicine', style: AppTypography.titleMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message banner if any
                    if (state.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(color: AppColors.danger, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 1. Medicine Name
                    _buildFieldLabel('Medicine Name'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      onChanged: notifier.setName,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Metformin',
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. Strength (optional)
                    _buildFieldLabel('Strength (optional)'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _strengthController,
                      onChanged: notifier.setStrength,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 500mg',
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3. Dosage
                    _buildFieldLabel('Dosage'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dosageController,
                      onChanged: notifier.setDosage,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 1 tablet',
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 4. Form
                    _buildFieldLabel('Form'),
                    const SizedBox(height: 10),
                    _buildFormSelector(state.form, notifier.setForm),
                    const SizedBox(height: 18),

                    // 5. Total Quantity
                    _buildFieldLabel('Total Quantity'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _totalQuantityController,
                      onChanged: notifier.setTotalQuantity,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'e.g. 30',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 6. Schedule Section
                    _buildFieldLabel('Schedule'),
                    const SizedBox(height: 12),
                    ...state.schedules.map((schedule) {
                      return _buildScheduleItem(
                        schedule: schedule,
                        onDelete: () => notifier.removeSchedule(schedule.id),
                      );
                    }),
                    const SizedBox(height: 8),

                    // Add another time button
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _showAddScheduleBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Add another time',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Save Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: AppButton(
                label: 'Save Medicine',
                isLoading: state.isLoading,
                onPressed: () async {
                  final success = await notifier.saveMedicine();
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${_nameController.text.trim()} added successfully!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: AppTypography.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
    );
  }

  Widget _buildFormSelector(MedicineForm selectedForm, ValueChanged<MedicineForm> onSelect) {
    final forms = [
      MedicineForm.tablet,
      MedicineForm.capsule,
      MedicineForm.syrup,
      MedicineForm.other,
    ];

    return Row(
      children: forms.map((form) {
        final isSelected = form == selectedForm;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onSelect(form),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Text(
                  form.displayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScheduleItem({
    required ScheduleInputItem schedule,
    required VoidCallback onDelete,
  }) {
    final isNight = schedule.time.hour >= 18 || schedule.time.hour < 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            isNight ? Icons.nightlight_round : Icons.access_time_rounded,
            size: 18,
            color: isNight ? AppColors.navy : AppColors.warning,
          ),
          const SizedBox(width: 12),
          Text(
            schedule.formattedTime,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              schedule.instruction,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline_rounded,
              color: AppColors.danger,
              size: 22,
            ),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
