import 'package:frontend/features/calendar/presentation/models/secretary_calendar_item.dart';

class CalendarCollisionPlacement {
  final SecretaryCalendarItem item;
  final int column;
  final int columnCount;

  const CalendarCollisionPlacement({
    required this.item,
    required this.column,
    required this.columnCount,
  });
}

List<CalendarCollisionPlacement> layoutCalendarCollisions(
  List<SecretaryCalendarItem> items,
) {
  if (items.isEmpty) return const [];

  final sorted = [...items]
    ..sort((a, b) {
      final start = a.startMinute.compareTo(b.startMinute);
      return start != 0 ? start : a.endMinute.compareTo(b.endMinute);
    });
  final result = <CalendarCollisionPlacement>[];
  var cluster = <SecretaryCalendarItem>[];
  var clusterEnd = -1;

  void placeCluster() {
    if (cluster.isEmpty) return;
    final columnEnds = <int>[];
    final columns = <SecretaryCalendarItem, int>{};

    for (final item in cluster) {
      var column = columnEnds.indexWhere((end) => end <= item.startMinute);
      if (column == -1) {
        column = columnEnds.length;
        columnEnds.add(item.endMinute);
      } else {
        columnEnds[column] = item.endMinute;
      }
      columns[item] = column;
    }

    for (final item in cluster) {
      result.add(
        CalendarCollisionPlacement(
          item: item,
          column: columns[item]!,
          columnCount: columnEnds.length,
        ),
      );
    }
  }

  for (final item in sorted) {
    if (cluster.isNotEmpty && item.startMinute >= clusterEnd) {
      placeCluster();
      cluster = [];
      clusterEnd = -1;
    }
    cluster.add(item);
    if (item.endMinute > clusterEnd) clusterEnd = item.endMinute;
  }
  placeCluster();

  return result;
}
