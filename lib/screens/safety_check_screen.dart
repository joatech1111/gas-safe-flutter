import 'package:flutter/material.dart';
import '../models/safety_customer_result_data.dart';
import '../widgets/common_widgets.dart';
import 'tabs/safety_history_tab.dart';
import 'tabs/safety_contract_tab.dart';
import 'tabs/safety_equip_tab.dart';
import 'tabs/safety_tank_tab.dart';
import 'tabs/safety_saving_tab.dart';

class SafetyCheckScreen extends StatefulWidget {
  final SafetyCustomerResultData customer;
  final int initialTab;
  final String? initialSno;

  const SafetyCheckScreen({super.key, required this.customer, this.initialTab = 0, this.initialSno});

  @override
  State<SafetyCheckScreen> createState() => _SafetyCheckScreenState();
}

class _SafetyCheckScreenState extends State<SafetyCheckScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가스안전관리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: false,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
        ],
      ),
      // Android와 동일: 하단 탭바 (36dp, #DAD8D1 배경)
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: Colors.red,
            indicatorWeight: 2,
            labelColor: Colors.red,
            unselectedLabelColor: AppColors.textDefault,
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            labelStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 14.5),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: '점검이력'),
              Tab(text: '공급계약'),
              Tab(text: '소비설비'),
              Tab(text: '안전관리'),
              Tab(text: '사용시설'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SafetyHistoryTab(customer: widget.customer, onTabChange: _goToTab),
          SafetyContractTab(customer: widget.customer, anzSno: widget.initialSno),
          SafetyEquipTab(customer: widget.customer, anzSno: widget.initialSno),
          SafetyTankTab(customer: widget.customer, anzSno: widget.initialSno),
          SafetySavingTab(customer: widget.customer, anzSno: widget.initialSno),
        ],
      ),
    );
  }

  void _goToTab(int index, {String? sno}) {
    _tabController.animateTo(index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
