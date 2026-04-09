// kv_table.dart
// Purpose: Reusable key-value table with per-row enable toggles, multi-select, and bulk actions (enable/disable/duplicate/delete).

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/kv_pair.dart';

class KVTable extends StatefulWidget {
  const KVTable({
    super.key,
    required this.initial,
    required this.onChanged,
    this.keyHint = 'Key',
    this.valueHint = 'Value',
    this.readOnlyKeys = false,
  });

  final List<KVPair> initial;
  final ValueChanged<List<KVPair>> onChanged;
  final String keyHint;
  final String valueHint;
  final bool readOnlyKeys;

  @override
  State<KVTable> createState() => _KVTableState();
}

class _KVTableState extends State<KVTable> {
  late List<_RowData> _rows;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _rows = widget.initial.map(_RowData.fromPair).toList();
    if (_rows.isEmpty) _rows.add(_RowData.empty());
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  // ─── Notification ────────────────────────────────────────────────────────────

  void _notify() {
    widget.onChanged(
      _rows
          .map((r) => KVPair(
                key: r.keyCtrl.text,
                value: r.valueCtrl.text,
                enabled: r.enabled,
              ))
          .toList(),
    );
  }

  // ─── Single-row operations ───────────────────────────────────────────────────

  void _addRow() {
    setState(() => _rows.add(_RowData.empty()));
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
      if (_rows.isEmpty) _rows.add(_RowData.empty());
      _selected.clear(); // Indices shift — safest to clear selection.
    });
    _notify();
  }

  void _toggleEnabled(int index, bool value) {
    setState(() => _rows[index].enabled = value);
    _notify();
  }

  // ─── Selection ───────────────────────────────────────────────────────────────

  void _toggleSelect(int index, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(index);
      } else {
        _selected.remove(index);
      }
    });
  }

  void _selectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selected.addAll(List.generate(_rows.length, (i) => i));
      } else {
        _selected.clear();
      }
    });
  }

  bool? get _headerCheckboxValue {
    if (_selected.isEmpty) return false;
    if (_selected.length == _rows.length) return true;
    return null; // indeterminate
  }

  // ─── Bulk operations ─────────────────────────────────────────────────────────

  void _enableSelected() {
    setState(() {
      for (final i in _selected) {
        _rows[i].enabled = true;
      }
      _selected.clear();
    });
    _notify();
  }

  void _disableSelected() {
    setState(() {
      for (final i in _selected) {
        _rows[i].enabled = false;
      }
      _selected.clear();
    });
    _notify();
  }

  void _duplicateSelected() {
    final sorted = _selected.toList()..sort();
    final copies = sorted.map((i) {
      return _RowData(
        keyCtrl: TextEditingController(text: _rows[i].keyCtrl.text),
        valueCtrl: TextEditingController(text: _rows[i].valueCtrl.text),
        enabled: _rows[i].enabled,
      );
    }).toList();
    setState(() {
      _rows.addAll(copies);
      _selected.clear();
    });
    _notify();
  }

  void _deleteSelected() {
    // Delete in reverse index order so indices stay valid.
    final toDelete = _selected.toList()..sort((a, b) => b.compareTo(a));
    setState(() {
      for (final i in toDelete) {
        _rows[i].dispose();
        _rows.removeAt(i);
      }
      if (_rows.isEmpty) _rows.add(_RowData.empty());
      _selected.clear();
    });
    _notify();
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selected.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Column header row
        _buildColumnHeaders(),

        // Bulk action bar — only visible when rows are selected
        if (hasSelection) _BulkActionBar(
          count: _selected.length,
          onEnable: _enableSelected,
          onDisable: _disableSelected,
          onDuplicate: _duplicateSelected,
          onDelete: _deleteSelected,
        ),

        // Data rows
        ...List.generate(_rows.length, (i) => _buildRow(i)),

        // Add row button
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingLg,
            AppConstants.spacingXs,
            AppConstants.spacingLg,
            AppConstants.spacingMd,
          ),
          child: TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add, size: 13, color: AppColors.textMuted),
            label: const Text(
              'Add row',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumnHeaders() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        AppConstants.spacingSm,
        AppConstants.spacingLg,
        2,
      ),
      child: Row(
        children: [
          // Select-all checkbox (20px)
          SizedBox(
            width: 20,
            child: Checkbox(
              tristate: true,
              value: _headerCheckboxValue,
              onChanged: _selectAll,
              visualDensity: VisualDensity.compact,
            ),
          ),
          // Enabled column icon (24px)
          SizedBox(
            width: 24,
            child: Center(
              child: Tooltip(
                message: 'Row enabled',
                child: Icon(
                  Icons.toggle_on_outlined,
                  size: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Key column label
          Expanded(
            child: Text(
              widget.keyHint.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          // Value column label
          Expanded(
            child: Text(
              widget.valueHint.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Delete column spacer (24px)
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildRow(int index) {
    final row = _rows[index];
    final isSelected = _selected.contains(index);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      color: isSelected ? AppColors.selectionBackground : Colors.transparent,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg,
        2,
        AppConstants.spacingLg,
        2,
      ),
      child: Row(
        children: [
          // Select checkbox (20px)
          SizedBox(
            width: 20,
            child: Checkbox(
              value: isSelected,
              onChanged: (v) => _toggleSelect(index, v ?? false),
              visualDensity: VisualDensity.compact,
            ),
          ),
          // Enabled checkbox (24px)
          SizedBox(
            width: 24,
            child: Checkbox(
              value: row.enabled,
              onChanged: (v) => _toggleEnabled(index, v ?? true),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 4),
          // Key field
          Expanded(
            child: _RowTextField(
              controller: row.keyCtrl,
              hint: widget.keyHint,
              enabled: row.enabled,
              readOnly: widget.readOnlyKeys,
              onChanged: (_) => _notify(),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          // Value field
          Expanded(
            child: _RowTextField(
              controller: row.valueCtrl,
              hint: widget.valueHint,
              enabled: row.enabled,
              onChanged: (_) => _notify(),
            ),
          ),
          // Delete button (24px)
          SizedBox(
            width: 24,
            child: IconButton(
              icon: const Icon(Icons.close, size: 12),
              color: AppColors.textMuted,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove row',
              onPressed: () => _removeRow(index),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bulk action bar ──────────────────────────────────────────────────────────

class _BulkActionBar extends StatelessWidget {
  const _BulkActionBar({
    required this.count,
    required this.onEnable,
    required this.onDisable,
    required this.onDuplicate,
    required this.onDelete,
  });

  final int count;
  final VoidCallback onEnable;
  final VoidCallback onDisable;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: 3,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.selectionBackground,
        border: Border.all(color: AppColors.selectionBorder),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        children: [
          Text(
            '$count selected',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          _BulkBtn(label: 'Enable', onTap: onEnable),
          const SizedBox(width: 6),
          _BulkBtn(label: 'Disable', onTap: onDisable),
          const SizedBox(width: 6),
          _BulkBtn(label: 'Duplicate', onTap: onDuplicate),
          const Spacer(),
          _BulkBtn(
            label: 'Delete',
            color: AppColors.error,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _BulkBtn extends StatelessWidget {
  const _BulkBtn({
    required this.label,
    required this.onTap,
    this.color = AppColors.textSecondary,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Row text field ───────────────────────────────────────────────────────────

class _RowTextField extends StatelessWidget {
  const _RowTextField({
    required this.controller,
    required this.hint,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 12,
        color: enabled ? AppColors.inputText : AppColors.textMuted,
        fontFamily: 'monospace',
      ),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: enabled ? AppColors.inputBackground : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputBorder),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputBorder),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputBorderFocus),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        hintStyle: const TextStyle(color: AppColors.inputHint, fontSize: 11),
      ),
    );
  }
}

// ─── Row data ─────────────────────────────────────────────────────────────────

class _RowData {
  _RowData({
    required this.keyCtrl,
    required this.valueCtrl,
    required this.enabled,
  });

  factory _RowData.fromPair(KVPair pair) => _RowData(
        keyCtrl: TextEditingController(text: pair.key),
        valueCtrl: TextEditingController(text: pair.value),
        enabled: pair.enabled,
      );

  factory _RowData.empty() => _RowData(
        keyCtrl: TextEditingController(),
        valueCtrl: TextEditingController(),
        enabled: true,
      );

  final TextEditingController keyCtrl;
  final TextEditingController valueCtrl;
  bool enabled;

  void dispose() {
    keyCtrl.dispose();
    valueCtrl.dispose();
  }
}
