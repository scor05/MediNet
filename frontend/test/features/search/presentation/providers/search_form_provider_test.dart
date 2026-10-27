import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/search/presentation/providers/search_form_provider.dart';
import 'package:frontend/features/user/domain/entities/doctor_search_result.dart';

void main() {
  test('a doctor is enough to search the public calendar', () {
    const state = SearchFormState(
      selectedDoctor: DoctorSearchResult(
        id: 7,
        name: 'Dra. Rivera',
        specialty: 'Medicina general',
      ),
    );

    expect(state.canSearch, isTrue);
    expect(state.selectedClinic, isNull);
  });
}
