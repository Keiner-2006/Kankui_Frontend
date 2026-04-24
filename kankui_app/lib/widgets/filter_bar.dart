import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Enum para los tipos de filtro de fecha
enum DateFilter {
  today('Hoy'),
  week('Esta semana'),
  month('Este mes'),
  custom('Personalizado');

  final String label;
  const DateFilter(this.label);
}

/// Widget para filtrar datos por rango de fechas
class FilterBar extends StatefulWidget {
  final DateFilter selectedFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final ValueChanged<DateFilter> onFilterChanged;
  final ValueChanged<DateTimeRange>? onCustomRangeSelected;

  const FilterBar({
    super.key,
    required this.selectedFilter,
    this.customStartDate,
    this.customEndDate,
    required this.onFilterChanged,
    this.onCustomRangeSelected,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  late DateFilter _currentFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.selectedFilter;
    _startDate = widget.customStartDate;
    _endDate = widget.customEndDate;
  }

  @override
  void didUpdateWidget(FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFilter != oldWidget.selectedFilter) {
      _currentFilter = widget.selectedFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botones de filtro rápido
          ...DateFilter.values.map((filter) {
            final isSelected = _currentFilter == filter;
            return _FilterChip(
              label: filter.label,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _currentFilter = filter;
                });
                widget.onFilterChanged(filter);
              },
            );
          }).toList(),

          const Spacer(),

          // Mostrar rango personalizado si está seleccionado
          if (_currentFilter == DateFilter.custom && _startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A6E5C),
                ),
              ),
            ),

          // Botón para seleccionar rango personalizado
          if (_currentFilter == DateFilter.custom)
            TextButton.icon(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: DateTimeRange(
                    start: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
                    end: _endDate ?? DateTime.now(),
                  ),
                );
                if (picked != null) {
                  setState(() {
                    _startDate = picked.start;
                    _endDate = picked.end;
                  });
                  widget.onCustomRangeSelected?.call(picked);
                }
              },
              icon: const Icon(Icons.date_range, size: 16),
              label: const Text('Seleccionar', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD4730A),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4730A) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4730A) : const Color(0xFFD4956A),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF5C2E00),
          ),
        ),
      ),
    );
  }
}
