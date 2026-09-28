import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/calendar/presentation/providers/staff_realtime_provider.dart';

void main() {
  test('doctor target subscribes only to its private doctor channel', () {
    const target = StaffRealtimeTarget.doctor(12);

    expect(target.channelNames, ['private-doctors.12']);
  });

  test('secretary target deduplicates and sorts organization channels', () {
    final target = StaffRealtimeTarget.secretary(13, [8, 3, 8]);

    expect(target.channelNames, [
      'private-organizations.3',
      'private-organizations.8',
    ]);
    expect(target, StaffRealtimeTarget.secretary(13, [3, 8]));
  });
}
