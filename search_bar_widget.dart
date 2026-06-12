import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CitySearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback? onLocation;
  final String? hintText;
  final bool showLocationButton;

  const CitySearchBar({
    super.key,
    required this.onSearch,
    this.onLocation,
    this.hintText,
    this.showLocationButton = true,
  });

  @override
  State<CitySearchBar> createState() => _CitySearchBarState();
}

class _CitySearchBarState extends State<CitySearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (value.trim().isNotEmpty) {
        widget.onSearch(value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.search, color: AppTheme.textMuted, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              onSubmitted: widget.onSearch,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search city...',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                _debounce?.cancel();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.close, color: AppTheme.textMuted, size: 18),
              ),
            ),
          if (widget.showLocationButton && widget.onLocation != null)
            GestureDetector(
              onTap: widget.onLocation,
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
