import 'package:flutter/material.dart';
import '../models/combo_data.dart';

class CommonWidgets {
  static Widget buildDropdown({
    required String label,
    required List<ComboData> items,
    required ComboData? selectedItem,
    required ValueChanged<ComboData?> onChanged,
    bool addAll = true,
  }) {
    final allItems = <ComboData>[];
    if (addAll) {
      allItems.add(ComboData(cdName: '전체'));
    }
    allItems.addAll(items);

    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ComboData>(
                isExpanded: true,
                isDense: true,
                value: _findMatchingItem(allItems, selectedItem),
                items: allItems.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.getCdName(), style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static ComboData? _findMatchingItem(List<ComboData> items, ComboData? selected) {
    if (selected == null && items.isNotEmpty) return items.first;
    for (final item in items) {
      if (item == selected) return item;
    }
    return items.isNotEmpty ? items.first : null;
  }

  static Widget buildSearchField({
    required TextEditingController controller,
    required VoidCallback onSearch,
    VoidCallback? onGpsSearch,
    String hint = '검색어를 입력하세요',
  }) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade400)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: Colors.grey.shade400)),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
              onSubmitted: (_) => onSearch(),
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onSearch,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF555555), borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.search, size: 18, color: Colors.white),
          ),
        ),
        if (onGpsSearch != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onGpsSearch,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFF4A90D9), borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.gps_fixed, size: 18, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }

  static Widget buildDateField({
    required BuildContext context,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _parseDate(value),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                final formatted = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
                onChanged(formatted);
              }
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                _displayDate(value),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static DateTime _parseDate(String yyyymmdd) {
    try {
      return DateTime(
        int.parse(yyyymmdd.substring(0, 4)),
        int.parse(yyyymmdd.substring(4, 6)),
        int.parse(yyyymmdd.substring(6, 8)),
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  static String _displayDate(String yyyymmdd) {
    if (yyyymmdd.length < 8) return yyyymmdd;
    return '${yyyymmdd.substring(0, 4)}-${yyyymmdd.substring(4, 6)}-${yyyymmdd.substring(6, 8)}';
  }

  static AppBar buildAppBar(BuildContext context, String title, {List<Widget>? actions, VoidCallback? onLogout}) {
    return AppBar(
      title: Text('가스안전관리', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/images/home.png', width: 24, height: 24),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset('assets/images/search.png', width: 22, height: 22),
          ),
        ),
        if (onLogout != null)
          GestureDetector(
            onTap: onLogout,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset('assets/images/logout.png', width: 22, height: 22),
            ),
          ),
        ...?actions,
      ],
    );
  }
}
