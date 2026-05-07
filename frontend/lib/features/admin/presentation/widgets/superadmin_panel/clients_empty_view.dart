import 'package:flutter/material.dart';

class ClientsEmptyView extends StatelessWidget {
  final bool? filter;

  const ClientsEmptyView({super.key, required this.filter});

  String get _message {
    if (filter == null) return 'No hay clientes registrados';
    if (filter == true) return 'No hay clientes activos';
    return 'No hay clientes inactivos';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 48, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            _message,
            style: const TextStyle(color: Colors.black45, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
