import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/medications_provider.dart';
import '../widgets/dose_progress_ring.dart';
import 'add_medication_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    if (h < 20) return 'Good Evening';
    return 'Good Night';
  }

  String _today() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _fmt(String t) {
    final p = t.split(':');
    final h = int.parse(p[0]);
    final m = p[1];
    return '${h % 12 == 0 ? 12 : h % 12}:$m ${h >= 12 ? "PM" : "AM"}';
  }

  int _timeToMinutes(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final meds = context.watch<MedicationsProvider>();
    final today = _today();
    final doses = meds.getTodaysDoses();
    final taken = doses.where((d) => d.taken).length;
    final nowMinutes = DateTime.now().hour * 60 + DateTime.now().minute;
    final upcoming = doses
        .where((d) => !d.taken && _timeToMinutes(d.time) >= nowMinutes)
        .toList()
      ..sort(
          (a, b) => _timeToMinutes(a.time).compareTo(_timeToMinutes(b.time)));
    final nextDose = upcoming.isNotEmpty ? upcoming.first : null;
    final specialCount = doses.where((d) => d.special).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 44,
              ),
              decoration:
                  const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_greeting()},',
                            style: const TextStyle(
                                fontSize: 18, color: Color(0xCCFFFFFF))),
                        Text('${auth.currentUser?.name ?? "there"}!',
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ]),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 1.5),
                    ),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
          ),

          // ── Today's schedule card ────────────────────────────────────
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -12),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TODAY'S SCHEDULE",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    Row(children: [
                      DoseProgressRing(taken: taken, total: doses.length),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doses.isEmpty
                                    ? 'No medications\nscheduled today'
                                    : taken == doses.length
                                        ? 'All done for\ntoday!'
                                        : '${doses.length - taken} dose${doses.length - taken != 1 ? "s" : ""}\nremaining',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.text,
                                    height: 1.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                nextDose != null
                                    ? 'Next dose: ${_fmt(nextDose.time)} · ${nextDose.medication.name}'
                                    : doses.isEmpty
                                        ? 'No doses today'
                                        : 'No more remaining doses today',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.4),
                              ),
                              if (specialCount > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '$specialCount special dose${specialCount != 1 ? "s" : ""} scheduled today',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                            ]),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),

          // ── Section header ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Today's Doses",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppColors.primary),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddMedicationScreen())),
                  ),
                ],
              ),
            ),
          ),

          // ── Dose list / empty state ──────────────────────────────────
          if (doses.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Column(children: [
                  const Icon(Icons.calendar_today,
                      size: 36, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  const Text('No medications scheduled',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddMedicationScreen())),
                    child: const Text('+ Add Medication',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final dose = doses[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Material(
                      color: dose.taken ? AppColors.secondary : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        splashColor: AppColors.primary.withOpacity(0.12),
                        hoverColor: AppColors.secondary.withOpacity(0.15),
                        onTap: () => meds.markDoseTaken(
                            dose.medication.id, today, dose.time),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: dose.taken
                                    ? AppColors.accent
                                    : AppColors.border,
                                width: 1.5),
                          ),
                          child: Row(children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: dose.taken
                                    ? AppColors.accent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: dose.taken
                                        ? AppColors.accent
                                        : AppColors.border,
                                    width: 2),
                              ),
                              child: dose.taken
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_fmt(dose.time)} — ${dose.medication.name}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: dose.taken
                                            ? AppColors.textSecondary
                                            : AppColors.text,
                                        decoration: dose.taken
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    if (dose.special)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Text('Special dose',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                  ]),
                            ),
                            Text(dose.medication.dosage,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                          ]),
                      ),
                    ),
                  ),
                  );
                },
                childCount: doses.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
