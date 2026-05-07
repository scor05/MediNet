import 'package:flutter/material.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';

class UserSearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final ClientUser? selectedUser;
  final ValueChanged<String> onChanged;

  const UserSearchField({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.selectedUser,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: isSearching
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : selectedUser != null
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
      onChanged: onChanged,
    );
  }
}
