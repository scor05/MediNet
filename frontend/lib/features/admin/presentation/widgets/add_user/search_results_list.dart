import 'package:flutter/material.dart';
import 'package:frontend/features/client/domain/entities/client_user.dart';

class SearchResultsList extends StatelessWidget {
  final double height;
  final List<ClientUser> results;
  final ValueChanged<ClientUser> onSelect;

  const SearchResultsList({
    super.key,
    required this.height,
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.white,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: results.length,
            itemBuilder: (_, index) {
              final user = results[index];

              return InkWell(
                onTap: () => onSelect(user),
                child: SizedBox(
                  height: 58,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.user.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.user.email,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
