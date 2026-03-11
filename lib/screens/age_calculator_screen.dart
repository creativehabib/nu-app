import 'package:flutter/material.dart';

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime? _dateOfBirth;
  _AgeSummary? _summary;

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );

    if (selected == null) return;

    setState(() {
      _dateOfBirth = selected;
      _summary = _AgeSummary.fromBirthDate(selected, now);
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Age Calculator'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calculate your exact age instantly',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dateOfBirth == null
                        ? 'Choose your date of birth to see years, months, days and next birthday countdown.'
                        : 'Date of birth: ${_formatDate(_dateOfBirth!)}',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _pickBirthDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(_dateOfBirth == null ? 'Choose Date of Birth' : 'Change Date'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_summary != null) ...[
            _InfoCard(
              title: 'Exact Age',
              value: '${_summary!.years} years, ${_summary!.months} months, ${_summary!.days} days',
              icon: Icons.cake_outlined,
            ),
            _InfoCard(
              title: 'Total Time Lived',
              value:
                  '${_summary!.totalMonths} months • ${_summary!.totalWeeks} weeks • ${_summary!.totalDays} days',
              icon: Icons.timer_outlined,
            ),
            _InfoCard(
              title: 'Next Birthday',
              value:
                  '${_formatDate(_summary!.nextBirthday)} (${_summary!.daysUntilNextBirthday} days left)',
              icon: Icons.celebration_outlined,
            ),
            _InfoCard(
              title: 'Birth Day',
              value: _summary!.birthWeekDay,
              icon: Icons.event_available_outlined,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(value),
        ),
      ),
    );
  }
}

class _AgeSummary {
  const _AgeSummary({
    required this.years,
    required this.months,
    required this.days,
    required this.totalMonths,
    required this.totalWeeks,
    required this.totalDays,
    required this.nextBirthday,
    required this.daysUntilNextBirthday,
    required this.birthWeekDay,
  });

  final int years;
  final int months;
  final int days;
  final int totalMonths;
  final int totalWeeks;
  final int totalDays;
  final DateTime nextBirthday;
  final int daysUntilNextBirthday;
  final String birthWeekDay;

  static _AgeSummary fromBirthDate(DateTime dob, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    var years = today.year - dob.year;
    var months = today.month - dob.month;
    var days = today.day - dob.day;

    if (days < 0) {
      final previousMonth = DateTime(today.year, today.month, 0);
      days += previousMonth.day;
      months -= 1;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final totalDays = today.difference(DateTime(dob.year, dob.month, dob.day)).inDays;
    final totalWeeks = totalDays ~/ 7;
    final totalMonths = years * 12 + months;

    var nextBirthday = _safeDate(today.year, dob.month, dob.day);
    if (!nextBirthday.isAfter(today)) {
      nextBirthday = _safeDate(today.year + 1, dob.month, dob.day);
    }

    final daysUntilNextBirthday = nextBirthday.difference(today).inDays;

    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return _AgeSummary(
      years: years,
      months: months,
      days: days,
      totalMonths: totalMonths,
      totalWeeks: totalWeeks,
      totalDays: totalDays,
      nextBirthday: nextBirthday,
      daysUntilNextBirthday: daysUntilNextBirthday,
      birthWeekDay: dayNames[dob.weekday - 1],
    );
  }

  static DateTime _safeDate(int year, int month, int day) {
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final safeDay = day > lastDayOfMonth ? lastDayOfMonth : day;
    return DateTime(year, month, safeDay);
  }
}
