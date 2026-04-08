import 'package:flutter/material.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/get_doctor_calendar.dart';
import '../../data/datasources/calendar_remote_datasource.dart';
import '../../data/repositories/calendar_repository_impl.dart';
import '../widgets/week_view.dart';

class DoctorCalendarPage extends StatefulWidget {
  const DoctorCalendarPage({super.key});

  @override
  State<DoctorCalendarPage> createState() => _DoctorCalendarPageState();
}

class _DoctorCalendarPageState extends State<DoctorCalendarPage> {
  // Inicializa las dependencias
  final _getCalendarUsecase = GetDoctorCalendar(
    CalendarRepositoryImpl(CalendarRemoteDatasource()),
  );

  late DateTime _weekStart;
  List<Appointment> _appointments = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _weekStart = _getMonday(DateTime.now());
    _loadAppointments();
  }

  DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dateFrom = _weekStart;
      final dateTo = _weekStart.add(const Duration(days: 6));
      final result = await _getCalendarUsecase(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      setState(() => _appointments = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _previousWeek() {
    setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
    _loadAppointments();
  }

  void _nextWeek() {
    setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
    _loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousWeek,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextWeek,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : WeekView(weekStart: _weekStart, appointments: _appointments),
    );
  }
}
