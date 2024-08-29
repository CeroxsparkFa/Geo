extension Today on DateTime {

  DateTime toDay() {
    return DateTime(year, month, day);
  }

  bool isAtSameDayAs(DateTime date) {
    return toDay().isAtSameMomentAs(date.toDay());
  }
}