import 'package:flutter/material.dart';

class SearchInputField<T> extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;

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
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
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
                ? IconButton(icon: const Icon(Icons.close), onPressed: onClear)
                : null,
          ),
        ),
        if (showResults)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 220),
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
                    ),
                    subtitle: Text(
                      subtitleBuilder(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
