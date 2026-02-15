import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Barre de recherche améliorée avec suggestions (inspirée d'Instacart/Uber Eats)
class SearchBarEnhanced extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<String>? suggestions;

  const SearchBarEnhanced({
    super.key,
    required this.hintText,
    this.onChanged,
    this.onTap,
    this.suggestions,
  });

  @override
  State<SearchBarEnhanced> createState() => _SearchBarEnhancedState();
}

class _SearchBarEnhancedState extends State<SearchBarEnhanced> {
  final TextEditingController _controller = TextEditingController();
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            onChanged: (value) {
              setState(() {
                _showSuggestions = value.isNotEmpty && widget.suggestions != null;
              });
              widget.onChanged?.call(value);
            },
            onTap: () {
              setState(() {
                _showSuggestions = _controller.text.isNotEmpty && widget.suggestions != null;
              });
              widget.onTap?.call();
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.bodySecondary.copyWith(
                color: AppColors.textTertiary,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _showSuggestions = false;
                        });
                        widget.onChanged?.call('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if (_showSuggestions && widget.suggestions != null && widget.suggestions!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: widget.suggestions!.take(5).map((suggestion) {
                return ListTile(
                  leading: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                  title: Text(
                    suggestion, 
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    _controller.text = suggestion;
                    setState(() {
                      _showSuggestions = false;
                    });
                    widget.onChanged?.call(suggestion);
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}


