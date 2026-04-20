import 'package:flutter/material.dart';
import '../models/combo_data.dart';

/// 기존 Android 앱과 동일한 색상 팔레트
class AppColors {
  AppColors._();
  static const Color primary       = Color(0xFFEDEAE7); // window_background
  static const Color primaryDark   = Color(0xFFDAD8D1); // menu/header background
  static const Color accent        = Color(0xFF707070);
  static const Color textDefault   = Color(0xFF4D4A47); // 기본 텍스트
  static const Color textDisabled  = Color(0xFFA6A19D);
  static const Color editBg        = Color(0xFFF9FBFD); // edittext_background
  static const Color editStroke    = Color(0xFF707070); // edittext_stroke
  static const Color editHint      = Color(0xFFA7A7A7);
  static const Color searchStroke  = Color(0xFFB2B2B2); // box_search_stroke
  static const Color listBg        = Color(0xFFFFFFFF);
  static const Color listStroke    = Color(0xFFA0A0A0);
  static const Color buttonBg      = Color(0xFFBEBCB6); // button_background_2 / footer
  static const Color buttonStroke  = Color(0xFF838282);
  static const Color lineBg        = Color(0xFFAAAAAA);

  // 의미 색상
  static const Color supplyWeight  = Color(0xFF00079C); // 중량
  static const Color supplyVolume  = Color(0xFF9B0000); // 체적
  static const Color dateDefault   = Color(0xFFB1B1B1);
  static const Color dateSoon      = Color(0xFF0056F3); // 임박
  static const Color dateOver      = Color(0xFFCF0000); // 초과
  static const Color meteringDef   = Color(0xFFF47A01); // 검침 기본
}

/// 앱 전체 공통 입력 필드 컴포넌트 (Android 스타일)
/// 높이 29dp, fontSize 14.7, borderRadius 1.3, #f9fbfd bg
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

  static const double height = 29;
  static const double fontSize = 14;
  static const double borderRadius = 1.3;

  static InputDecoration decoration({
    String? hint,
    String? suffixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: fontSize, color: AppColors.editHint),
      suffixText: suffixText,
      suffixStyle: const TextStyle(fontSize: 13, color: AppColors.textDefault),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.editBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.editStroke, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.editStroke, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
        style: const TextStyle(fontSize: fontSize, color: AppColors.textDefault),
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
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
        Expanded(
          child: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFFE5E4DD)],
              ),
              border: Border.all(color: AppColors.searchStroke, width: 1),
              borderRadius: BorderRadius.circular(0.3),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ComboData>(
                isExpanded: true,
                isDense: true,
                value: _findMatchingItem(allItems, selectedItem),
                items: allItems.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.getCdName(), style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault), overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: onChanged,
                icon: const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.accent),
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

  /// Android와 동일한 검색 바: 36dp EditText + 54x36 검색버튼 + 36x36 GPS버튼
  static Widget buildSearchField({
    required TextEditingController controller,
    required VoidCallback onSearch,
    VoidCallback? onGpsSearch,
    String hint = '검색어를 입력하세요',
  }) {
    const double barH = 36;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: barH,
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSearch(),
              style: const TextStyle(fontSize: 18, color: AppColors.textDefault),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.editHint),
                filled: true,
                fillColor: AppColors.editBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppInput.borderRadius), borderSide: const BorderSide(color: AppColors.searchStroke)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppInput.borderRadius), borderSide: const BorderSide(color: AppColors.searchStroke)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppInput.borderRadius), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
                suffixIcon: GestureDetector(
                  onTap: onSearch,
                  child: Container(
                    width: 54,
                    height: barH,
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/search2.png', width: 24, height: 24,
                      errorBuilder: (_, __, ___) => const Icon(Icons.search, size: 22, color: AppColors.accent),
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(maxWidth: 54, maxHeight: barH),
              ),
            ),
          ),
        ),
        if (onGpsSearch != null) ...[
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onGpsSearch,
            child: Container(
              width: 36,
              height: barH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppInput.borderRadius),
              ),
              child: Image.asset('assets/images/location.png', width: 36, height: 36,
                errorBuilder: (_, __, ___) => Container(
                  width: 36, height: barH,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9),
                    borderRadius: BorderRadius.circular(AppInput.borderRadius),
                  ),
                  child: const Icon(Icons.gps_fixed, size: 20, color: Colors.white),
                ),
              ),
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
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 12.7, fontWeight: FontWeight.w500, color: AppColors.textDefault))),
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
              padding: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                color: AppColors.editBg,
                border: Border.all(color: AppColors.editStroke),
                borderRadius: BorderRadius.circular(AppInput.borderRadius),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                _displayDate(value),
                style: const TextStyle(fontSize: AppInput.fontSize, color: AppColors.textDefault),
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

  /// Android 스타일 AppBar: #DAD8D1 배경, 검은색 텍스트, 좌측 정렬
  static AppBar buildAppBar(BuildContext context, String title, {List<Widget>? actions, VoidCallback? onLogout}) {
    final canGoBack = Navigator.of(context).canPop();
    return AppBar(
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      centerTitle: false,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.black,
      elevation: 0,
      leading: canGoBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 22),
              onPressed: () => Navigator.of(context).pop(),
            )
          : GestureDetector(
              onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset('assets/images/home.png', width: 24, height: 24,
                  errorBuilder: (_, __, ___) => const Icon(Icons.home, size: 24, color: Colors.black87),
                ),
              ),
            ),
      actions: [
        if (onLogout != null)
          GestureDetector(
            onTap: onLogout,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset('assets/images/logout.png', width: 22, height: 22,
                errorBuilder: (_, __, ___) => const Icon(Icons.logout, size: 22, color: Colors.black87),
              ),
            ),
          ),
        ...?actions,
      ],
    );
  }

  /// Android 스타일 하단 상태바: #DAD8D1 배경
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
        height: 37,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
        ),
        child: Row(
          children: [
            Text('검침원 : $name', style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
            const Spacer(),
            if (rightText != null && rightText.trim().isNotEmpty)
              Text(rightText, style: const TextStyle(fontSize: 12.7, color: AppColors.textDefault)),
          ],
        ),
      ),
    );
  }
}
