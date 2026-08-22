import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../utils/icon_helper.dart';

// ── Predefined icon+color options ──────────────────────────────────────────
const _iconOptions = [
  // Health & Body
  ('drop',            'Water'),
  ('heartbeat',       'Heart Rate'),
  ('pill',            'Medicine'),
  ('apple',           'Nutrition'),
  ('carrot',          'Diet'),
  ('knife',           'Meal Prep'),
  ('scales',          'Weight'),
  ('thermometer',     'Health'),
  ('bandaids',        'Recovery'),
  ('syringe',         'Supplement'),
  // Fitness
  ('barbell',         'Workout'),
  ('footprints',      'Steps'),
  ('bicycle',         'Cycling'),
  ('swimmer',         'Swimming'),
  ('person',          'Yoga'),
  ('soccer-ball',     'Sport'),
  ('timer',           'Cardio'),
  ('trophy',          'Competition'),
  // Mind & Wellness
  ('sparkle',         'Meditation'),
  ('moon',            'Sleep'),
  ('sun',             'Morning'),
  ('brain',           'Mental Health'),
  ('smiley',          'Gratitude'),
  ('wind',            'Breathing'),
  ('butterfly',       'Mindfulness'),
  ('flower',          'Self Care'),
  // Learning
  ('bookOpenText',    'Reading'),
  ('pencil',          'Journaling'),
  ('graduation-cap',  'Study'),
  ('chalkboard',      'Learning'),
  ('translate',       'Language'),
  ('music-note',      'Music'),
  ('palette',         'Art'),
  // Work & Productivity
  ('fire',            'Focus'),
  ('code',            'Coding'),
  ('target',          'Goal'),
  ('chart-line',      'Progress'),
  ('briefcase',       'Work'),
  ('clock',           'Time Block'),
  ('list-checks',     'Tasks'),
  ('lightning',       'Productivity'),
  // Finance & Life
  ('money',           'Finance'),
  ('piggy-bank',      'Savings'),
  ('shopping-cart',   'Spending'),
  ('house',           'Home'),
  ('plant',           'Gardening'),
  ('dog',             'Pets'),
  ('car',             'Commute'),
  ('recycle',         'Eco'),
  // Social
  ('users',           'Social'),
  ('phone',           'Call Family'),
  ('chat',            'Connect'),
  ('hands-clapping',  'Kindness'),
  // General
  ('star',            'Important'),
  ('bed',             'Rest'),
  ('check',           'Other'),
];

const _colorOptions = [
  (0xFF00FFB2, 'Teal'),
  (0xFFFF2E93, 'Magenta'),
  (0xFFFF8A00, 'Orange'),
  (0xFF00E676, 'Green'),
  (0xFF448AFF, 'Blue'),
  (0xFFFFB300, 'Amber'),
];

const _categoryOptions = ['Health', 'Mind', 'Focus', 'Fitness', 'Work', 'Finance', 'Learning', 'Social'];

class CreateHabitSheet extends ConsumerStatefulWidget {
  final Habit? initialHabit;
  const CreateHabitSheet({super.key, this.initialHabit});

  @override
  ConsumerState<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends ConsumerState<CreateHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _unitController = TextEditingController();

  HabitType _type = HabitType.numeric;
  String _selectedIcon = 'check';
  int _selectedColor = 0xFF00FFB2;
  String _selectedCategory = 'Health';
  String _timeOfDay = 'Anytime';
  TimeOfDay? _reminderTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialHabit != null) {
      final h = widget.initialHabit!;
      _titleController.text = h.title;
      _targetController.text = h.targetValue.toString();
      _unitController.text = h.unit;
      _type = h.type;
      _selectedIcon = h.iconName;
      _selectedColor = h.colorHex;
      if (h.reminderTime != null) {
        final parts = h.reminderTime!.split(':');
        if (parts.length == 2) {
          _reminderTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
      if (h.categories.isNotEmpty) {
        _selectedCategory = h.categories.first;
      }
      _timeOfDay = h.timeOfDay ?? 'Anytime';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final isEditing = widget.initialHabit != null;
    String? finalReminderTime;
    if (_reminderTime != null) {
      final hh = _reminderTime!.hour.toString().padLeft(2, '0');
      final mm = _reminderTime!.minute.toString().padLeft(2, '0');
      finalReminderTime = '$hh:$mm';
    }
    
    final habit = Habit(
      id: isEditing ? widget.initialHabit!.id : 'h_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      subtitle: '',
      type: _type,
      targetValue: double.tryParse(_targetController.text.trim()) ?? 1.0,
      unit: _unitController.text.trim(),
      streak: isEditing ? widget.initialHabit!.streak : 0,
      categories: [_selectedCategory],
      colorHex: _selectedColor,
      iconName: _selectedIcon,
      orderIndex: isEditing ? widget.initialHabit!.orderIndex : ref.read(habitsProvider).length,
      isArchived: isEditing ? widget.initialHabit!.isArchived : false,
      reminderTime: finalReminderTime,
      timeOfDay: _timeOfDay,
      activeDays: isEditing ? widget.initialHabit!.activeDays : const [1, 2, 3, 4, 5, 6, 7],
    );

    if (isEditing) {
      ref.read(habitsProvider.notifier).updateHabit(habit);
    } else {
      ref.read(habitsProvider.notifier).addHabit(habit);
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.initialHabit != null ? 'Edit Habit' : 'Create New Habit',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 22,
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ──
              _label('Habit Name *'),
              const SizedBox(height: 8),
              _textField(
                controller: _titleController,
                hint: 'e.g. Morning Run',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Habit name is required.' : null,
              ),
              const SizedBox(height: 20),

              // ── Type selector ──
              _label('Habit Type'),
              const SizedBox(height: 8),
              Row(
                children: HabitType.values.map((t) {
                  final labels = {
                    HabitType.boolean: 'Checkbox',
                    HabitType.numeric: 'Numeric',
                    HabitType.blocks: 'Blocks',
                  };
                  final selected = _type == t;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _type = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? Color(_selectedColor).withValues(alpha: 0.2)
                                : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? Color(_selectedColor)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              labels[t]!,
                              style: TextStyle(
                                color: selected ? Color(_selectedColor) : AppTheme.textSecondary,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Target & Unit (only for numeric/blocks) ──
              if (_type != HabitType.boolean) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Target Value *'),
                          const SizedBox(height: 8),
                          _textField(
                            controller: _targetController,
                            hint: _type == HabitType.blocks ? 'e.g. 4' : 'e.g. 3000',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Target is required.';
                              if (double.tryParse(v.trim()) == null) return 'Enter a valid number.';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Unit'),
                          const SizedBox(height: 8),
                          _textField(
                            controller: _unitController,
                            hint: _type == HabitType.blocks ? 'blocks' : 'mL, mins…',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // ── Category ──
              _label('Category'),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categoryOptions.map((cat) {
                    final selected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.accentMagenta : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: selected ? Colors.white : AppTheme.textSecondary,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              
              // ── Time of Day ──
              _label('Time of Day'),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Anytime', 'Morning', 'Afternoon', 'Evening'].map((time) {
                    final selected = _timeOfDay == time;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _timeOfDay = time),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.accentBlue : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: selected ? Colors.white : AppTheme.textSecondary,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // ── Color ──
              _label('Color'),
              const SizedBox(height: 8),
              Row(
                children: _colorOptions.map((c) {
                  final selected = _selectedColor == c.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedColor = c.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Color(c.$1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: Color(c.$1).withValues(alpha: 0.6), blurRadius: 8)]
                              : [],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Icon ──
              _label('Icon'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _iconOptions.map((opt) {
                  final selected = _selectedIcon == opt.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = opt.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? Color(_selectedColor).withValues(alpha: 0.2)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? Color(_selectedColor) : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getHabitIcon(opt.$1),
                            color: selected ? Color(_selectedColor) : AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            opt.$2,
                            style: TextStyle(
                              color: selected ? Color(_selectedColor) : AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Reminder Time ──
              _label('Daily Reminder'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => _reminderTime = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _reminderTime != null 
                            ? _reminderTime!.format(context)
                            : 'Set reminder time',
                        style: TextStyle(
                          color: _reminderTime != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      if (_reminderTime != null)
                        GestureDetector(
                          onTap: () => setState(() => _reminderTime = null),
                          child: const Icon(Icons.close, color: AppTheme.textSecondary, size: 20),
                        )
                      else
                        const Icon(Icons.access_time, color: AppTheme.textSecondary, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Buttons ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.surfaceLight),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentMagenta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(widget.initialHabit != null ? 'Save Changes' : 'Create Habit', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accentMagenta, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
