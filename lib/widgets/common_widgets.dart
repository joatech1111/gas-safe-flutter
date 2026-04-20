import 'package:flutter/material.dart';
import '../models/combo_data.dart';

/// 앱 전체 공통 입력 필드 컴포넌트
/// 높이 48px, fontSize 14, borderRadius 4, grey.shade400 border
class AppInput extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final String? suffixText;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;

  const AppInput({
    super.key,
    required this.controller,
    this.hint,
    this.suffixText,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
  });

  static const double height = 25;
  static const double fontSize = 14;
  static const double borderRadius = 4;

  static InputDecoration decoration({
    String? hint,
    String? suffixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: fontSize, color: Colors.grey.shade400),
      suffixText: suffixText,
      suffixStyle: const TextStyle(fontSize: 13, color: Colors.black54),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: maxLines > 1 ? null : height,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        maxLines: maxLines,
        decoration: decoration(hint: hint, suffixText: suffixText, suffixIcon: suffixIcon),
        style: const TextStyle(fontSize: fontSize),
      ),
    );
  }
}

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
            height: AppInput.height,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(AppInput.borderRadius),
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
          child: AppInput(
            controller: controller,
            hint: hint,
            onSubmitted: (_) => onSearch(),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onSearch,
          child: Container(
            width: 48, height: AppInput.height,
            decoration: BoxDecoration(color: const Color(0xFF555555), borderRadius: BorderRadius.circular(AppInput.borderRadius)),
            child: const Icon(Icons.search, size: 20, color: Colors.white),
          ),
        ),
        if (onGpsSearch != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onGpsSearch,
            child: Container(
              width: 48, height: AppInput.height,
              decoration: BoxDecoration(color: const Color(0xFF4A90D9), borderRadius: BorderRadius.circular(AppInput.borderRadius)),
              child: const Icon(Icons.gps_fixed, size: 20, color: Colors.white),
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
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final date = await showKoreanDatePicker(
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
              height: AppInput.height,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(AppInput.borderRadius),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                _displayDate(value),
                style: const TextStyle(fontSize: AppInput.fontSize),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Future<DateTime?> showKoreanDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final now = DateTime.now();
    final safeInitialDate = initialDate.isBefore(firstDate)
        ? firstDate
        : initialDate.isAfter(lastDate)
            ? lastDate
            : initialDate;
    final defaultDate = now.isBefore(firstDate) || now.isAfter(lastDate) ? safeInitialDate : now;

    return showDatePicker(
      context: context,
      initialDate: defaultDate,
      currentDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ko', 'KR'),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.day,
      helpText: '날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
      fieldLabelText: '날짜 입력',
      fieldHintText: 'YYYY-MM-DD',
      errorFormatText: '날짜 형식이 올바르지 않습니다',
      errorInvalidText: '유효한 날짜를 입력하세요',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            datePickerTheme: const DatePickerThemeData(
              headerHeadlineStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              weekdayStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              dayStyle: TextStyle(fontSize: 16),
              yearStyle: TextStyle(fontSize: 16),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
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
    final canGoBack = Navigator.of(context).canPop();
    return AppBar(
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      leading: canGoBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 22),
              onPressed: () => Navigator.of(context).pop(),
            )
          : GestureDetector(
              onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset('assets/images/home.png', width: 24, height: 24),
              ),
            ),
      actions: [
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

  static Widget buildBottomStatusBar({
    required String workerName,
    String? rightText,
  }) {
    final name = workerName.trim().isEmpty ? '(미지정)' : workerName.trim();
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      minimum: const EdgeInsets.only(bottom: 2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border(top: BorderSide(color: Colors.grey.shade500, width: 0.6)),
        ),
        child: Row(
          children: [
            Text('검침원 : $name', style: const TextStyle(fontSize: 12, color: Colors.black87)),
            const Spacer(),
            if (rightText != null && rightText.trim().isNotEmpty)
              Text(rightText, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
