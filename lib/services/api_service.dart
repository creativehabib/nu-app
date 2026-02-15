import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/college.dart';
import '../models/department.dart';

class ApiResult<T> {
  const ApiResult({required this.items, required this.usedFallback});

  final List<T> items;
  final bool usedFallback;
}

class HolidayCalendarData {
  const HolidayCalendarData({
    required this.year,
    required this.holidayMap,
    required this.holidayReasons,
    required this.holidayTypes,
  });

  final int year;
  final Map<int, Set<int>> holidayMap;
  final Map<int, Map<int, String>> holidayReasons;
  final Map<int, Map<int, String>> holidayTypes;
}

class ApiService {
  Future<ApiResult<Department>> fetchDepartments({String? endpoint}) async {
    final uri = Uri.parse(
      endpoint ??
          'https://raw.githubusercontent.com/creativehabib/nu-data/main/departments.json',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Unexpected status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      final items = data
          .map(
            (department) =>
                Department.fromJson(department as Map<String, dynamic>),
          )
          .toList();
      return ApiResult(items: items, usedFallback: false);
    } catch (_) {
      final fallback = _fallbackDepartments
          .map((department) => Department.fromJson(department))
          .toList();
      return ApiResult(items: fallback, usedFallback: true);
    }
  }

  Future<ApiResult<College>> fetchColleges({String? endpoint}) async {
    final uri = Uri.parse(
      endpoint ??
          'https://raw.githubusercontent.com/creativehabib/nu-data/refs/heads/main/affiliated_college.json',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Unexpected status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final items = _extractList(data);
      final colleges = items
          .whereType<Map<String, dynamic>>()
          .map(College.fromJson)
          .toList();
      return ApiResult(items: colleges, usedFallback: false);
    } catch (_) {
      final fallback = _fallbackColleges
          .map((college) => College.fromJson(college))
          .toList();
      return ApiResult(items: fallback, usedFallback: true);
    }
  }

  Future<HolidayCalendarData> fetchNuHolidays({String? endpoint}) async {
    final currentYear = DateTime.now().year;
    final uri = Uri.parse(
      endpoint ??
          'https://raw.githubusercontent.com/creativehabib/nu-data/refs/heads/main/nu-holidays.json',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Unexpected status: ${response.statusCode}');
      }

      final dynamic decoded = jsonDecode(response.body);
      final parsed = _parseHolidayPayload(decoded);
      if (parsed.holidayMap.isEmpty) {
        throw Exception('Holiday payload is empty');
      }
      return parsed;
    } catch (_) {
      return HolidayCalendarData(
        year: currentYear,
        holidayMap: _fallbackHolidayMap(currentYear),
        holidayReasons: _fallbackHolidayReasons(),
        holidayTypes: _fallbackHolidayTypes(),
      );
    }
  }
}

const List<Map<String, dynamic>> _fallbackDepartments = [];
const List<Map<String, dynamic>> _fallbackColleges = [];

List<dynamic> _extractList(dynamic data) {
  if (data is List) {
    return data;
  }
  if (data is Map<String, dynamic>) {
    for (final key in ['data', 'colleges', 'collegeList', 'items', 'holidays']) {
      final value = data[key];
      if (value is List) {
        return value;
      }
    }
  }
  return const [];
}

HolidayCalendarData _parseHolidayPayload(dynamic payload) {
  final currentYear = DateTime.now().year;
  if (payload is List) {
    return _parseHolidayEntries(entries: payload, year: currentYear);
  }

  if (payload is Map<String, dynamic>) {
    final year = _resolveHolidayYear(payload, currentYear);
    final holidayEntries = _extractList(payload);

    if (holidayEntries.isNotEmpty) {
      return _parseHolidayEntries(entries: holidayEntries, year: year);
    }

    final monthMap = _parseMonthBasedHolidayMap(payload);
    return HolidayCalendarData(
      year: year,
      holidayMap: monthMap,
      holidayReasons: const {},
      holidayTypes: const {},
    );
  }

  return HolidayCalendarData(
    year: currentYear,
    holidayMap: const {},
    holidayReasons: const {},
    holidayTypes: const {},
  );
}

HolidayCalendarData _parseHolidayEntries({
  required List<dynamic> entries,
  required int year,
}) {
  final holidayMap = <int, Set<int>>{};
  final holidayReasons = <int, Map<int, String>>{};
  final holidayTypes = <int, Map<int, String>>{};

  for (final item in entries) {
    if (item is! Map<String, dynamic>) {
      continue;
    }

    int? month = _toInt(item['month'] ?? item['m'] ?? item['mm']);
    int? day = _toInt(item['day'] ?? item['dd']);

    final dateFromText = item['date'] ?? item['isoDate'] ?? item['holidayDate'];
    if ((month == null || day == null) && dateFromText is String) {
      final parsedDate = DateTime.tryParse(dateFromText);
      if (parsedDate != null) {
        month ??= parsedDate.month;
        day ??= parsedDate.day;
      }
    }

    if (month == null || day == null || month < 1 || month > 12 || day < 1) {
      continue;
    }

    holidayMap.putIfAbsent(month, () => <int>{}).add(day);

    final reason = _extractHolidayReason(item);
    if (reason.isNotEmpty) {
      holidayReasons.putIfAbsent(month, () => <int, String>{})[day] = reason;
    }

    final holidayType = _extractHolidayType(item);
    if (holidayType.isNotEmpty) {
      holidayTypes.putIfAbsent(month, () => <int, String>{})[day] = holidayType;
    }
  }

  return HolidayCalendarData(
    year: year,
    holidayMap: holidayMap,
    holidayReasons: holidayReasons,
    holidayTypes: holidayTypes,
  );
}

Map<int, Set<int>> _parseMonthBasedHolidayMap(Map<String, dynamic> payload) {
  final result = <int, Set<int>>{};

  for (final entry in payload.entries) {
    final month = _toInt(entry.key);
    final value = entry.value;

    if (month == null || month < 1 || month > 12) {
      continue;
    }

    if (value is List) {
      final days = value
          .map(_toInt)
          .whereType<int>()
          .where((d) => d > 0)
          .toSet();
      if (days.isNotEmpty) {
        result[month] = days;
      }
    }
  }

  return result;
}



String _extractHolidayType(Map<String, dynamic> item) {
  for (final key in ['type', 'holidayType', 'category']) {
    final value = item[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}

String _extractHolidayReason(Map<String, dynamic> item) {
  for (final key in [
    'reason',
    'name',
    'title',
    'holiday',
    'occasion',
    'event',
    'description',
    'details',
  ]) {
    final value = item[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return 'কারণ উল্লেখ নেই';
}

int _resolveHolidayYear(Map<String, dynamic> payload, int fallbackYear) {
  final year = _toInt(payload['year'] ?? payload['calendarYear']);
  return year ?? fallbackYear;
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

Map<int, Set<int>> _fallbackHolidayMap(int year) {
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

Map<int, Map<int, String>> _fallbackHolidayReasons() {
  return {
    1: {1: 'New Year Holiday'},
    2: {21: 'আন্তর্জাতিক মাতৃভাষা দিবস'},
    3: {17: 'জাতির পিতার জন্মবার্ষিকী', 26: 'স্বাধীনতা দিবস'},
    4: {14: 'পহেলা বৈশাখ'},
    5: {1: 'মে দিবস'},
    6: {5: 'ঈদ-উল-আযহা (সম্ভাব্য)'},
    8: {15: 'জাতীয় শোক দিবস'},
    10: {1: 'দুর্গা পূজা (সম্ভাব্য)'},
    12: {16: 'বিজয় দিবস', 25: 'বড়দিন'},
  };
}

Map<int, Map<int, String>> _fallbackHolidayTypes() {
  return {
    6: {5: 'University Holiday'},
  };
}

extension on int {
  bool get isLeapYear {
    if (this % 400 == 0) return true;
    if (this % 100 == 0) return false;
    return this % 4 == 0;
  }
}
