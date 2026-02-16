import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Barre de recherche améliorée avec suggestions (inspirée d'Instacart/Uber Eats)
class SearchBarEnhanced extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<String>? suggestions; // Suggestions statiques (déprécié)
  final List<String> Function(String query)? dynamicSuggestions; // Suggestions dynamiques basées sur la requête

  const SearchBarEnhanced({
    super.key,
    required this.hintText,
    this.onChanged,
    this.onTap,
    this.suggestions,
    this.dynamicSuggestions,
  });

  @override
  State<SearchBarEnhanced> createState() => _SearchBarEnhancedState();
}

class _SearchBarEnhancedState extends State<SearchBarEnhanced> {
  final TextEditingController _controller = TextEditingController();
  bool _showSuggestions = false;
  List<String> _currentSuggestions = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _currentSuggestions = [];
      });
      return;
    }

    List<String> suggestions = [];
    
    // Utiliser les suggestions dynamiques si disponibles
    if (widget.dynamicSuggestions != null) {
      suggestions = widget.dynamicSuggestions!(query);
    } else if (widget.suggestions != null) {
      // Sinon, filtrer les suggestions statiques
      suggestions = widget.suggestions!
          .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    setState(() {
      _currentSuggestions = suggestions;
      _showSuggestions = suggestions.isNotEmpty;
    });
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
              _updateSuggestions(value);
              widget.onChanged?.call(value);
            },
            onTap: () {
              _updateSuggestions(_controller.text);
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
                        _updateSuggestions('');
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
        if (_showSuggestions && _currentSuggestions.isNotEmpty)
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
              children: _currentSuggestions.take(5).map((suggestion) {
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
                      _currentSuggestions = [];
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


