import 'package:flutter/material.dart';

import '../navigation/app_bottom_nav_items.dart';
import '../widgets/app_bottom_nav.dart';

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime? _dateOfBirth;
  DateTime _targetDate = DateTime.now();
  _AgeSummary? _summary;

  Future<void> _pickDate({required bool isBirthDate}) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: isBirthDate ? (_dateOfBirth ?? DateTime(now.year - 20, now.month, now.day)) : _targetDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: isBirthDate ? 'Select date of birth' : 'Select age at the date of',
    );

    if (selected == null) return;

    setState(() {
      if (isBirthDate) {
        _dateOfBirth = selected;
      } else {
        _targetDate = selected;
      }

      if (_dateOfBirth != null) {
        _summary = _AgeSummary.fromDates(_dateOfBirth!, _targetDate);
      }
    });
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomNavItems = buildAppBottomNavItems(
      context,
      onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Age Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Input Section: Birth Date & Target Date
          Card(
            elevation: 0,
            color: colorScheme.primaryContainer.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DateSelectorTile(
                    label: "Date of Birth",
                    value: _dateOfBirth == null ? "Select Date" : _formatDate(_dateOfBirth!),
                    icon: Icons.cake_outlined,
                    onTap: () => _pickDate(isBirthDate: true),
                    iconColor: Colors.orange,
                  ),
                  const Divider(height: 24),
                  _DateSelectorTile(
                    label: "Age at the Date of",
                    value: _formatDate(_targetDate),
                    icon: Icons.event_note_outlined,
                    onTap: () => _pickDate(isBirthDate: false),
                    iconColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ),

          if (_summary != null) ...[
            const SizedBox(height: 24),

            // Life Progress Bar
            _SectionTitle(title: "Life Progress (Est. 80 years)", color: colorScheme.primary),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _summary!.lifeProgress,
                    minHeight: 20,
                    backgroundColor: colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
                Text(
                  "${(_summary!.lifeProgress * 100).toStringAsFixed(1)}% lived",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Age Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _SmallStatCard(title: 'Zodiac Sign', value: _summary!.zodiacSign, icon: Icons.auto_awesome, color: Colors.purple),
                _SmallStatCard(title: 'Birth Day', value: _summary!.birthWeekDay, icon: Icons.today, color: Colors.pink),
                _SmallStatCard(
                  title: 'Chinese Zodiac',
                  value: _summary!.chineseZodiac,
                  icon: Icons.pets,
                  color: Colors.deepOrange,
                ),
                _SmallStatCard(
                  title: 'Birthday Countdown',
                  value: _summary!.birthdayCountdown,
                  icon: Icons.countdown,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _InfoCard(
              title: 'Exact Age',
              value: '${_summary!.years} years, ${_summary!.months} months, ${_summary!.days} days',
              icon: Icons.hourglass_full_rounded,
              iconColor: Colors.teal,
              subtitle: 'Age on ${_formatDate(_targetDate)}',
            ),

            _InfoCard(
              title: 'Next Birthday',
              value: '${_formatDate(_summary!.nextBirthday)}',
              icon: Icons.celebration_outlined,
              iconColor: Colors.amber,
              subtitle: '${_summary!.daysUntilNextBirthday} days left from today!',
              trailing: CircleAvatar(
                backgroundColor: colorScheme.primary,
                child: Text('${_summary!.yearsAtNextBday}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),

            _InfoCard(
              title: 'Reminder Notifications',
              value: _summary!.notificationPlan,
              icon: Icons.notifications_active_outlined,
              iconColor: Colors.deepPurple,
              subtitle: 'Great for widget + push reminder workflow.',
            ),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Health Insights', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _ListTileInfo(
                      label: 'Estimated Sleep Time',
                      value: _summary!.estimatedSleep,
                      icon: Icons.bedtime_outlined,
                      color: Colors.indigo,
                    ),
                    _ListTileInfo(
                      label: 'Estimated Meals Eaten',
                      value: _summary!.estimatedMeals,
                      icon: Icons.restaurant_menu,
                      color: Colors.brown,
                    ),
                  ],
                ),
              ),
            ),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fun Facts', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _ListTileInfo(
                      label: 'Famous People Born Today',
                      value: _summary!.famousPeople,
                      icon: Icons.people_alt_outlined,
                      color: Colors.blue,
                    ),
                    _ListTileInfo(
                      label: 'Historical Event',
                      value: _summary!.historicalEvent,
                      icon: Icons.history_edu_outlined,
                      color: Colors.teal,
                    ),
                    _ListTileInfo(
                      label: 'Age on Mars / Venus',
                      value: _summary!.planetAge,
                      icon: Icons.public,
                      color: Colors.deepOrange,
                    ),
                  ],
                ),
              ),
            ),

            // Statistics Expansion
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ExpansionTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Detailed Life Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
                children: [
                  _ListTileInfo(label: 'Total Months', value: '${_summary!.totalMonths}', icon: Icons.calendar_view_month, color: Colors.cyan),
                  _ListTileInfo(label: 'Total Weeks', value: '${_summary!.totalWeeks}', icon: Icons.view_week, color: Colors.indigo),
                  _ListTileInfo(label: 'Total Days', value: '${_summary!.totalDays}', icon: Icons.timer_outlined, color: Colors.lightGreen),
                  _ListTileInfo(label: 'Total Hours', value: _summary!.totalHours, icon: Icons.schedule, color: Colors.orange),
                  _ListTileInfo(label: 'Total Minutes', value: _summary!.totalMinutes, icon: Icons.av_timer, color: Colors.blueGrey),
                  _ListTileInfo(label: 'Total Seconds', value: _summary!.totalSeconds, icon: Icons.shutter_speed, color: Colors.redAccent),
                  _ListTileInfo(label: 'Est. Heartbeats', value: _summary!.heartbeats, icon: Icons.favorite, color: Colors.red),
                  _ListTileInfo(label: 'Est. Breaths', value: _summary!.breaths, icon: Icons.air, color: Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _SectionTitle(title: "Upcoming 10 Birthdays", color: colorScheme.secondary),
            const SizedBox(height: 8),

            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _summary!.upcomingBirthdays.length,
                itemBuilder: (context, index) {
                  final bday = _summary!.upcomingBirthdays[index];
                  return Card(
                    margin: const EdgeInsets.only(right: 10),
                    child: Container(
                      width: 110,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(bday.year.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Divider(),
                          Text(bday.dayName, style: TextStyle(color: colorScheme.primary, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: bottomNavItems,
        currentIndex: 2,
      ),
    );
  }
}

// --- Supporting Widgets ---

class _DateSelectorTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _DateSelectorTile({required this.label, required this.value, required this.icon, required this.onTap, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.edit_calendar, size: 20),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5));
  }
}

class _SmallStatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _SmallStatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.value, required this.icon, required this.iconColor, this.subtitle, this.trailing});
  final String title, value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('$value${subtitle != null ? "\n$subtitle" : ""}'),
        trailing: trailing,
        isThreeLine: subtitle != null,
      ),
    );
  }
}

class _ListTileInfo extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _ListTileInfo({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: color),
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

// --- Logic Layer ---

class _Birthday {
  final int year;
  final String dayName;
  _Birthday(this.year, this.dayName);
}

class _AgeSummary {
  const _AgeSummary({
    required this.years, required this.months, required this.days,
    required this.totalMonths, required this.totalWeeks, required this.totalDays,
    required this.totalHours, required this.totalMinutes, required this.totalSeconds,
    required this.nextBirthday, required this.daysUntilNextBirthday, required this.birthWeekDay,
    required this.zodiacSign, required this.lifeProgress,
    required this.heartbeats, required this.breaths,
    required this.upcomingBirthdays, required this.yearsAtNextBday,
    required this.birthdayCountdown, required this.notificationPlan,
    required this.estimatedSleep, required this.estimatedMeals,
    required this.chineseZodiac, required this.famousPeople,
    required this.historicalEvent, required this.planetAge,
  });

  final int years, months, days, totalMonths, totalWeeks, totalDays, daysUntilNextBirthday, yearsAtNextBday;
  final String totalHours, totalMinutes, totalSeconds;
  final DateTime nextBirthday;
  final String birthWeekDay, zodiacSign, heartbeats, breaths;
  final String birthdayCountdown, notificationPlan, estimatedSleep, estimatedMeals;
  final String chineseZodiac, famousPeople, historicalEvent, planetAge;
  final double lifeProgress;
  final List<_Birthday> upcomingBirthdays;

  static _AgeSummary fromDates(DateTime dob, DateTime target) {
    var years = target.year - dob.year;
    var months = target.month - dob.month;
    var days = target.day - dob.day;

    if (days < 0) {
      days += DateTime(target.year, target.month, 0).day;
      months -= 1;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final diff = target.difference(DateTime(dob.year, dob.month, dob.day));
    final totalDays = diff.inDays;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var nextBirthday = DateTime(today.year, dob.month, dob.day);
    if (!nextBirthday.isAfter(today)) nextBirthday = DateTime(today.year + 1, dob.month, dob.day);
    final nextBirthdayDateTime = DateTime(nextBirthday.year, nextBirthday.month, nextBirthday.day, 8);
    final countdown = nextBirthdayDateTime.difference(now);
    final countdownDays = countdown.inDays;
    final countdownHours = countdown.inHours.remainder(24);
    final countdownMinutes = countdown.inMinutes.remainder(60);

    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    List<_Birthday> upcoming = [];
    for (int i = 1; i <= 10; i++) {
      final date = DateTime(today.year + i, dob.month, dob.day);
      upcoming.add(_Birthday(date.year, dayNames[date.weekday - 1]));
    }

    return _AgeSummary(
      years: years, months: months, days: days,
      totalMonths: years * 12 + months,
      totalWeeks: totalDays ~/ 7,
      totalDays: totalDays,
      totalHours: _formatLarge(diff.inHours),
      totalMinutes: _formatLarge(diff.inMinutes),
      totalSeconds: _formatLarge(diff.inSeconds),
      nextBirthday: nextBirthday,
      daysUntilNextBirthday: nextBirthday.difference(today).inDays,
      yearsAtNextBday: nextBirthday.year - dob.year,
      birthWeekDay: dayNames[dob.weekday - 1],
      zodiacSign: _calculateZodiac(dob.month, dob.day),
      lifeProgress: (years / 80).clamp(0.0, 1.0),
      heartbeats: _formatLarge(totalDays * 24 * 60 * 72),
      breaths: _formatLarge(totalDays * 24 * 60 * 16),
      upcomingBirthdays: upcoming,
      birthdayCountdown: '${countdownDays}d ${countdownHours}h ${countdownMinutes}m',
      notificationPlan: _notificationPlan(nextBirthday),
      estimatedSleep: _formatDurationHours((diff.inHours * 0.33).round()),
      estimatedMeals: _formatLarge((totalDays * 2.4).round()),
      chineseZodiac: _calculateChineseZodiac(dob.year),
      famousPeople: _famousPeopleByDate(dob.month, dob.day),
      historicalEvent: _historicalEventByDate(dob.month, dob.day),
      planetAge: _planetaryAge(years + (months / 12) + (days / 365)),
    );
  }

  static String _calculateZodiac(int m, int d) {
    const signs = ['Capricorn', 'Aquarius', 'Pisces', 'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius'];
    final dates = [20, 19, 21, 20, 21, 21, 23, 23, 23, 23, 22, 22];
    return (d < dates[m - 1]) ? signs[m - 1] : signs[m % 12];
  }

  static String _formatLarge(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    return n.toString();
  }

  static String _notificationPlan(DateTime nextBirthday) {
    final before3 = nextBirthday.subtract(const Duration(days: 3));
    return 'Set alerts on ${before3.day}/${before3.month} (3 days before) and ${nextBirthday.day}/${nextBirthday.month} 8:00 AM';
  }

  static String _formatDurationHours(int hours) {
    final years = hours ~/ (24 * 365);
    final months = (hours % (24 * 365)) ~/ (24 * 30);
    return '$years years $months months';
  }

  static String _calculateChineseZodiac(int year) {
    const animals = ['Rat', 'Ox', 'Tiger', 'Rabbit', 'Dragon', 'Snake', 'Horse', 'Goat', 'Monkey', 'Rooster', 'Dog', 'Pig'];
    return 'Year of the ${animals[(year - 4) % 12]}';
  }

  static String _famousPeopleByDate(int month, int day) {
    const data = {
      '1-1': 'J. D. Salinger, Verne Troyer',
      '2-14': 'Frederick Douglass, Michael Bloomberg',
      '3-14': 'Albert Einstein, Simone Biles',
      '7-18': 'Nelson Mandela, Priyanka Chopra',
      '10-28': 'Bill Gates, Joaquin Phoenix',
      '12-25': 'Isaac Newton, Humphrey Bogart',
    };
    return data['$month-$day'] ?? 'A curated famous birthday list can be fetched via API.';
  }

  static String _historicalEventByDate(int month, int day) {
    const data = {
      '1-1': 'The Euro currency was launched (1999).',
      '3-10': 'Bell made the first successful telephone call (1876).',
      '7-20': 'Apollo 11 landed on the Moon (1969).',
      '11-9': 'Fall of the Berlin Wall (1989).',
      '12-16': 'Victory Day in Bangladesh (1971).',
    };
    return data['$month-$day'] ?? 'No highlighted event in local cache for this date.';
  }

  static String _planetaryAge(double earthYears) {
    final marsAge = earthYears / 1.88;
    final venusAge = earthYears / 0.62;
    return 'Mars: ${marsAge.toStringAsFixed(1)}y | Venus: ${venusAge.toStringAsFixed(1)}y';
  }
}
