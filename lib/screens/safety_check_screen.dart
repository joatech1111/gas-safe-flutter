import 'package:flutter/material.dart';
import '../models/safety_customer_result_data.dart';
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
    final cuName = widget.customer.cuNameView ?? widget.customer.cuName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('가스경영안전관리', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
        ],
      ),
      // Android와 동일: 하단 탭바
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(top: BorderSide(color: Colors.grey.shade400)),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: Colors.red,
          indicatorWeight: 3,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.black54,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: '점검이력'),
            Tab(text: '공급계약'),
            Tab(text: '소비설비'),
            Tab(text: '저장탱크'),
            Tab(text: '사용시설'),
          ],
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
