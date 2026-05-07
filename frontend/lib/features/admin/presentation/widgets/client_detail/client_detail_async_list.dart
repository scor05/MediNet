import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:frontend/core/widgets/error_view.dart';
import 'package:frontend/features/admin/presentation/widgets/client_detail/client_detail_empty_state.dart';
import 'package:frontend/theme/app_theme.dart';

class ClientDetailAsyncList<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final String listLabel;
  final String emptyLabel;
  final VoidCallback onRetry;
  final VoidCallback onAdd;
  final Widget Function(T item) itemBuilder;

  const ClientDetailAsyncList({
    super.key,
    required this.asyncValue,
    required this.listLabel,
    required this.emptyLabel,
    required this.onRetry,
    required this.onAdd,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                listLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
              ),
            ],
          ),
        ),
        Expanded(
          child: asyncValue.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            ),
            error: (error, _) {
              final message = error is ApiException
                  ? error.message
                  : 'Error inesperado.';

              return ErrorView(message: message, onRetry: onRetry);
            },
            data: (items) {
              if (items.isEmpty) {
                return ClientDetailEmptyState(label: emptyLabel);
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) => itemBuilder(items[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
