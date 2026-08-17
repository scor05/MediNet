import 'dart:math' as math;

import 'package:flutter/material.dart';

class SearchInputField<T> extends StatefulWidget {
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
  final VoidCallback onEmptyFocus;

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
    required this.onEmptyFocus,
    this.compact = false,
  });

  @override
  State<SearchInputField<T>> createState() => _SearchInputFieldState<T>();
}

class _SearchInputFieldState<T> extends State<SearchInputField<T>> {
  static const _maxResults = 16;
  static const _visibleResults = 4;
  static const _resultTileHeight = 64.0;

  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    final hasFocus = _focusNode.hasFocus;

    if (_hasFocus != hasFocus && mounted) {
      setState(() => _hasFocus = hasFocus);
    }

    if (hasFocus &&
        widget.controller.text.trim().isEmpty &&
        widget.selectedItem == null) {
      widget.onEmptyFocus();
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedResults = widget.results.take(_maxResults).toList();
    final showResults =
        _hasFocus && displayedResults.isNotEmpty && widget.selectedItem == null;
    final visibleCount = math.min(displayedResults.length, _visibleResults);
    final resultsHeight =
        (visibleCount * _resultTileHeight) + math.max(0, visibleCount - 1);

    return TextFieldTapRegion(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            style: widget.compact ? const TextStyle(fontSize: 16) : null,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hintText,
              isDense: widget.compact,
              contentPadding: widget.compact
                  ? const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                  : null,
              suffixIcon: widget.loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : widget.selectedItem != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClear,
                      iconSize: widget.compact ? 18 : 24,
                    )
                  : null,
            ),
          ),
          if (showResults)
            Container(
              height: resultsHeight,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: displayedResults.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: Theme.of(context).dividerColor),
                  itemBuilder: (context, index) {
                    final item = displayedResults[index];
                    return SizedBox(
                      height: _resultTileHeight,
                      child: ListTile(
                        dense: true,
                        title: Text(
                          widget.titleBuilder(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: widget.compact
                              ? const TextStyle(fontSize: 13)
                              : null,
                        ),
                        subtitle: Text(
                          widget.subtitleBuilder(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: widget.compact
                              ? const TextStyle(fontSize: 12)
                              : null,
                        ),
                        onTap: () => widget.onSelected(item),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
