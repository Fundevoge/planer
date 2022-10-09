class Date {
  final int year;
  final int month;
  final int day;
  @override
  final int hashCode;

  Date(this.day, this.month, this.year) : hashCode = day * 1000000 + month * 10000 + year;

  Date.fromDateTime(DateTime dateTime)
      : year = dateTime.year,
        month = dateTime.month,
        day = dateTime.day,
        hashCode = dateTime.day * 1000000 + dateTime.month * 10000 + dateTime.year;

  factory Date.now() {
    return Date.fromDateTime(DateTime.now());
  }

  @override
  String toString() {
    return "$day.$month.$year";
  }

  factory Date.fromString(String s) {
    List<String> subStrings = s.split(".");
    return Date(int.parse(subStrings[0]), int.parse(subStrings[1]), int.parse(subStrings[2]));
  }

  DateTime toDateTime() {
    return DateTime(year, month, day);
  }

  @override
  bool operator ==(Object other) {
    return other is Date && hashCode == other.hashCode;
  }
}