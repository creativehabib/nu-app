class College {
  const College({
    required this.name,
    this.code,
    this.district,
    this.thana,
    this.eiin,
    this.email,
  });

  final String name;
  final String? code;
  final String? district;
  final String? thana;
  final String? eiin;
  final String? email;

  factory College.fromJson(Map<String, dynamic> json) {
    String? readValue(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return null;
    }

    final name = readValue([
          'college_name',
          'collegeName',
          'college',
          'name',
          'collegeTitle',
        ]) ??
        '';

    return College(
      name: name,
      code: readValue(['college_code', 'collegeCode', 'code']),
      district: readValue(['district_name', 'district', 'districtName']),
      thana: readValue(['thana_name', 'thana', 'upazila', 'upazila_name']),
      eiin: readValue(['eiin', 'eiin_no', 'eiinNo']),
      email: readValue(['email', 'college_email', 'collegeEmail']),
    );
  }
}
