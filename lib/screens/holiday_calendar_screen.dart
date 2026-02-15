import 'package:flutter/material.dart';

import '../services/api_service.dart';

class HolidayCalendarScreen extends StatefulWidget {
  const HolidayCalendarScreen({super.key});

  @override
  State<HolidayCalendarScreen> createState() => _HolidayCalendarScreenState();
}

class _HolidayCalendarScreenState extends State<HolidayCalendarScreen> {
  late Future<HolidayCalendarData> _holidayFuture;

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

  static const List<String> _weekDaysBn = [
    'রবি',
    'সোম',
    'মঙ্গল',
    'বুধ',
    'বৃহঃ',
    'শুক্র',
    'শনি',
  ];

  @override
  void initState() {
    super.initState();
    _holidayFuture = ApiService().fetchNuHolidays();
  }

  void _reloadHolidays() {
    setState(() {
      _holidayFuture = ApiService().fetchNuHolidays();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HolidayCalendarData>(
      future: _holidayFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final data = snapshot.data;
        final year = data?.year ?? DateTime.now().year;
        final holidays = data?.holidayMap ?? const <int, Set<int>>{};
        final holidayReasons = data?.holidayReasons ?? const <int, Map<int, String>>{};

        return Scaffold(
          appBar: AppBar(
            title: Text('Holiday Calendar $year'),
            actions: [
              IconButton(
                onPressed: isLoading ? null : _reloadHolidays,
                icon: const Icon(Icons.refresh),
                tooltip: 'Reload holidays',
              ),
            ],
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
                  'Holiday data source: nu-holidays.json\nলাল = সরকারী ছুটি (ক্লিক/হোভার করলে কারণ দেখা যাবে), কমলা = সাপ্তাহিক ছুটি (শুক্র/শনি)।',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              if (isLoading)
                const LinearProgressIndicator(minHeight: 2)
              else
                const SizedBox(height: 2),
              if (snapshot.hasError)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    'ডেটা লোডে সমস্যা হয়েছে, fallback holiday list দেখানো হচ্ছে।',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
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
                      year: year,
                      month: month,
                      firstWeekdayColumn: firstWeekdayColumn,
                      specialHolidayDays: holidays[month] ?? const {},
                      specialHolidayReasons: holidayReasons[month] ?? const {},
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthCalendarCard extends StatelessWidget {
  const _MonthCalendarCard({
    required this.monthName,
    required this.weekDaysBn,
    required this.daysInMonth,
    required this.year,
    required this.month,
    required this.firstWeekdayColumn,
    required this.specialHolidayDays,
    required this.specialHolidayReasons,
  });

  final String monthName;
  final List<String> weekDaysBn;
  final int daysInMonth;
  final int year;
  final int month;
  final int firstWeekdayColumn;
  final Set<int> specialHolidayDays;
  final Map<int, String> specialHolidayReasons;

  void _showHolidayReason(BuildContext context, int dayNumber) {
    final reason = specialHolidayReasons[dayNumber] ?? 'কারণ উল্লেখ নেই';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$dayNumber ${monthName}: $reason'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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

                  final date = DateTime(year, month, dayNumber);
                  final isWeekendHoliday =
                      date.weekday == DateTime.friday ||
                      date.weekday == DateTime.saturday;
                  final isSpecialHoliday = specialHolidayDays.contains(dayNumber);

                  Color? dayBackground;
                  Color dayColor = colorScheme.onSurface;
                  FontWeight dayWeight = FontWeight.w500;

                  if (isWeekendHoliday) {
                    dayBackground = colorScheme.tertiaryContainer;
                    dayColor = colorScheme.onTertiaryContainer;
                    dayWeight = FontWeight.w600;
                  }

                  if (isSpecialHoliday) {
                    dayBackground = colorScheme.errorContainer;
                    dayColor = colorScheme.onErrorContainer;
                    dayWeight = FontWeight.w700;
                  }

                  final dayChip = Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: dayBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: dayWeight,
                        color: dayColor,
                      ),
                    ),
                  );

                  if (!isSpecialHoliday) {
                    return dayChip;
                  }

                  final reason = specialHolidayReasons[dayNumber] ?? 'কারণ উল্লেখ নেই';

                  return Tooltip(
                    message: reason,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _showHolidayReason(context, dayNumber),
                        child: dayChip,
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
