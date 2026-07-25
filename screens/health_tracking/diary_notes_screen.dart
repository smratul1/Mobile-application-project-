import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class DiaryNotesScreen extends StatefulWidget {
  const DiaryNotesScreen({super.key});

  @override
  State<DiaryNotesScreen> createState() => _DiaryNotesScreenState();
}

class _DiaryNotesScreenState extends State<DiaryNotesScreen> {
  final List<Map<String, String>> _notes = [
    {'title': 'Feeling better today', 'body': 'After taking the new dosage I feel much more energetic.', 'date': '2026-07-24'},
  ];
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _addNote() {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() {
      _notes.insert(0, {
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'date': DateTime.now().toString().split(' ').first,
      });
      _titleCtrl.clear();
      _bodyCtrl.clear();
      _adding = false;
    });
  }

  void _deleteNote(int index) {
    setState(() => _notes.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 20),
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: Colors.white)),
                  const Text('Diary Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  IconButton(onPressed: _adding ? null : () => setState(() => _adding = !_adding), icon: const Icon(Icons.add, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_adding) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'Title', border: InputBorder.none), style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            TextField(controller: _bodyCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Write your note...', border: InputBorder.none)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: ElevatedButton(onPressed: _addNote, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('Save'))),
                                const SizedBox(width: 12),
                                Expanded(child: ElevatedButton(onPressed: () => setState(() => _adding = false), style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.text), child: const Text('Cancel'))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ..._notes.asMap().entries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.value['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                                const SizedBox(height: 4),
                                Text(e.value['body']!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                                const SizedBox(height: 6),
                                Text(e.value['date']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          IconButton(visualDensity: VisualDensity.compact, onPressed: () => _deleteNote(e.key), icon: const Icon(Icons.delete_outline, color: AppColors.destructive, size: 18)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
