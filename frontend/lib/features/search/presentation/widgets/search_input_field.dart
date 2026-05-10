import 'package:flutter/material.dart';

class SearchInputField<T> extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool compact;

  final bool loading;
  final T? selectedItem;
  final List<T> results;

  final String Function(T item) titleBuilder;
  final String Function(T item) subtitleBuilder;

  final ValueChanged<String> onChanged;
  final ValueChanged<T> onSelected;
  final VoidCallback onClear;

  const SearchInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.loading,
    required this.selectedItem,
    required this.results,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.onChanged,
    required this.onSelected,
    required this.onClear,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final showResults = results.isNotEmpty && selectedItem == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: compact ? const TextStyle(fontSize: 13) : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            isDense: compact,
            contentPadding: compact
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                : null,
            suffixIcon: loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : selectedItem != null
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClear,
                    iconSize: compact ? 18 : 24,
                  )
                : null,
          ),
        ),
        if (showResults)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: BoxConstraints(maxHeight: compact ? 160 : 220),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: results.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                itemBuilder: (context, index) {
                  final item = results[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      titleBuilder(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: compact ? const TextStyle(fontSize: 13) : null,
                    ),
                    subtitle: Text(
                      subtitleBuilder(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: compact ? const TextStyle(fontSize: 12) : null,
                    ),
                    onTap: () => onSelected(item),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
