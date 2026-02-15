import 'package:flutter/material.dart';

class HolidayCalendarScreen extends StatelessWidget {
  const HolidayCalendarScreen({super.key});

  static const List<String> _monthNamesBn = [
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];

  static const List<String> _weekDaysBn = ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি'];

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final holidays = _buildHolidayMap(year);

    return Scaffold(
      appBar: AppBar(
        title: Text('Holiday Calendar $year'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'লাল গোল চিহ্ন দেওয়া তারিখগুলো সরকারি/বিশেষ ছুটি।',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.76,
              ),
              itemBuilder: (context, index) {
                final month = index + 1;
                final daysInMonth = DateUtils.getDaysInMonth(year, month);
                final firstDay = DateTime(year, month, 1);
                final firstWeekdayColumn = firstDay.weekday % 7;

                return _MonthCalendarCard(
                  monthName: _monthNamesBn[index],
                  weekDaysBn: _weekDaysBn,
                  daysInMonth: daysInMonth,
                  firstWeekdayColumn: firstWeekdayColumn,
                  holidayDays: holidays[month] ?? const {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<int, Set<int>> _buildHolidayMap(int year) {
    return {
      1: {1},
      2: {21},
      3: {17, 26},
      4: {14},
      5: {1},
      6: {5},
      8: {15},
      10: {year.isLeapYear ? 2 : 1},
      12: {16, 25},
    };
  }
}

class _MonthCalendarCard extends StatelessWidget {
  const _MonthCalendarCard({
    required this.monthName,
    required this.weekDaysBn,
    required this.daysInMonth,
    required this.firstWeekdayColumn,
    required this.holidayDays,
  });

  final String monthName;
  final List<String> weekDaysBn;
  final int daysInMonth;
  final int firstWeekdayColumn;
  final Set<int> holidayDays;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalCells = ((firstWeekdayColumn + daysInMonth + 6) ~/ 7) * 7;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: weekDaysBn
                  .map(
                    (day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  final dayNumber = index - firstWeekdayColumn + 1;
                  final isValidDay = dayNumber > 0 && dayNumber <= daysInMonth;

                  if (!isValidDay) {
                    return const SizedBox.shrink();
                  }

                  final isHoliday = holidayDays.contains(dayNumber);
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isHoliday ? colorScheme.errorContainer : null,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isHoliday ? FontWeight.w700 : FontWeight.w500,
                        color: isHoliday
                            ? colorScheme.onErrorContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on int {
  bool get isLeapYear {
    if (this % 400 == 0) return true;
    if (this % 100 == 0) return false;
    return this % 4 == 0;
  }
}
