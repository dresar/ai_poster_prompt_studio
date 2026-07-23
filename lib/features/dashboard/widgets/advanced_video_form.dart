import 'package:flutter/material.dart';
import '../../../core/theme/neo_theme.dart';
import '../../../shared/widgets/neo_section_card.dart';
import '../../../shared/widgets/neo_text_field.dart';
import '../../../shared/widgets/neo_buttons.dart';
import '../../../shared/widgets/neo_dropdown_field.dart';
import '../dropdown_provider.dart';

class AdvancedVideoForm extends StatefulWidget {
  final DropdownState dropdownState;
  final bool isGenerating;
  final bool isAnalyzing;
  final Future<void> Function(Map<String, dynamic> payload) onGenerate;
  final void Function(Map<String, dynamic> payload) onGenerateExternal;
  final Future<Map<String, dynamic>?> Function(String topic, int duration) onAnalyzeStoryboard;

  const AdvancedVideoForm({
    super.key,
    required this.dropdownState,
    required this.isGenerating,
    required this.isAnalyzing,
    required this.onGenerate,
    required this.onGenerateExternal,
    required this.onAnalyzeStoryboard,
  });

  @override
  State<AdvancedVideoForm> createState() => _AdvancedVideoFormState();
}

class _AdvancedVideoFormState extends State<AdvancedVideoForm> {
  // ── Controllers ──────────────────────────────────────────────
  final _topicCtrl = TextEditingController();
  final _sinopsisCtrl = TextEditingController();
  final _konfliktCtrl = TextEditingController();
  final _resolusiCtrl = TextEditingController();
  final _emosiCtrl = TextEditingController();

  // ── Dropdown state keys ──────────────────────────────────────
  int _durasi = 30;
  String _gaya = 'auto';
  String _jenisCerita = 'auto';
  String _kamera = 'auto';
  String _lokasi = 'auto';
  String _transisi = 'auto';
  String _moodAudio = 'auto';

  // ── Selected characters from DB ──────────────────────────────
  final List<String> _selectedCharIds = [];   // selected character IDs
  final List<String> _selectedCharLabels = []; // selected character labels

  // ── Scenes ───────────────────────────────────────────────────
  List<Map<String, dynamic>> _scenes = [
    _blankScene(1),
  ];
  int _selectedSceneIdx = 0;

  static Map<String, dynamic> _blankScene(int num) => {
    'sceneNumber': num,
    'title': 'Scene $num',
    'goal': '',
    'duration': 10,
    'action': '',
    'emotion': 'auto',
    'camera': 'auto',
    'transition': 'auto',
    'dialogue': '',
    'soundEffect': '',
  };

  @override
  void dispose() {
    _topicCtrl.dispose();
    _sinopsisCtrl.dispose();
    _konfliktCtrl.dispose();
    _resolusiCtrl.dispose();
    _emosiCtrl.dispose();
    super.dispose();
  }

  // ── AI Storyboard Auto-fill ───────────────────────────────────
  void _runAutoStoryboard() async {
    final topic = _topicCtrl.text.trim();
    if (topic.isEmpty) return;
    final result = await widget.onAnalyzeStoryboard(topic, _durasi);
    if (result == null) return;
    setState(() {
      if (result['projectSummary'] != null) {
        _sinopsisCtrl.text = result['projectSummary']['description'] ?? '';
      }
      if (result['storyBible'] != null) {
        final sb = result['storyBible'];
        _jenisCerita = sb['storyType'] ?? 'auto';
        _konfliktCtrl.text = sb['conflict'] ?? '';
        _resolusiCtrl.text = sb['resolution'] ?? '';
        _emosiCtrl.text = sb['emotionalArc'] ?? '';
      }
      if (result['sceneBreakdown'] != null) {
        _scenes = (result['sceneBreakdown'] as List)
            .map((sc) => Map<String, dynamic>.from(sc as Map))
            .toList();
        _selectedSceneIdx = 0;
      }
    });
  }

  // ── AI fill single field ─────────────────────────────────────
  void _aiRecommend(TextEditingController ctrl, String hint) {
    // Placeholder — triggers same storyboard flow or sets AI placeholder text
    if (_topicCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi judul/topik dulu agar AI bisa merekomendasikan.'), backgroundColor: Colors.orange),
      );
      return;
    }
    ctrl.text = '🤖 AI akan mengisi ini saat Generate...';
    setState(() {});
  }

  void _addScene() {
    setState(() {
      final num = _scenes.length + 1;
      _scenes.add(_blankScene(num));
      _selectedSceneIdx = _scenes.length - 1;
    });
  }

  void _deleteScene(int idx) {
    if (_scenes.length <= 1) return;
    setState(() {
      _scenes.removeAt(idx);
      for (int i = 0; i < _scenes.length; i++) _scenes[i]['sceneNumber'] = i + 1;
      _selectedSceneIdx = 0;
    });
  }

  void _submit() {
    widget.onGenerate({
      'feature': 'advanced_video',
      'topic': _topicCtrl.text.trim().isEmpty ? 'Film Tanpa Judul' : _topicCtrl.text.trim(),
      'description': _sinopsisCtrl.text.trim(),
      'duration': _durasi,
      'storyBible': {
        'storyType': _jenisCerita,
        'narrative': _sinopsisCtrl.text.trim(),
        'conflict': _konfliktCtrl.text.trim(),
        'resolution': _resolusiCtrl.text.trim(),
        'emotionalArc': _emosiCtrl.text.trim(),
      },
      'selectedCharacters': _selectedCharIds,
      'sceneBreakdown': _scenes,
      'style': _gaya,
      'cameraStyle': _kamera,
      'locationStyle': _lokasi,
      'transitionStyle': _transisi,
      'audioMood': _moodAudio,
    });
  }

  void _submitExternal() {
    widget.onGenerateExternal({
      'feature': 'advanced_video',
      'topic': _topicCtrl.text.trim().isEmpty ? 'Film Tanpa Judul' : _topicCtrl.text.trim(),
      'description': _sinopsisCtrl.text.trim(),
      'duration': _durasi,
      'storyBible': {
        'storyType': _jenisCerita,
        'narrative': _sinopsisCtrl.text.trim(),
        'conflict': _konfliktCtrl.text.trim(),
        'resolution': _resolusiCtrl.text.trim(),
        'emotionalArc': _emosiCtrl.text.trim(),
      },
      'selectedCharacters': _selectedCharIds,
      'sceneBreakdown': _scenes,
      'style': _gaya,
      'cameraStyle': _kamera,
      'locationStyle': _lokasi,
      'transitionStyle': _transisi,
      'audioMood': _moodAudio,
    });
  }

  // ── Helper: dropdown option lookup ───────────────────────────
  NeoDropdownOption _selected(String groupKey, String value) {
    final opts = _opts(groupKey);
    return opts.firstWhere((o) => o.value == value, orElse: () => opts.first);
  }

  List<NeoDropdownOption> _opts(String groupKey) =>
      widget.dropdownState.groups[groupKey] ?? [];

  // ── Helper: compact AI Button for text field ─────────────────
  Widget _aiBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5))],
      ),
      alignment: Alignment.center,
      child: Image.asset('assets/1.png', width: 16, height: 16),
    ),
  );

  // ── Compact text field with AI button ───────────────────────
  Widget _field({
    required String label,
    required TextEditingController ctrl,
    String hint = '',
    int maxLines = 1,
    bool withAI = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
            ),
            if (withAI) ...[
              const SizedBox(width: 6),
              _aiBtn(() => _aiRecommend(ctrl, hint)),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  // ── Compact dropdown ─────────────────────────────────────────
  Widget _dropdown({
    required String label,
    required String groupKey,
    required String value,
    required void Function(String val, String lbl) onChanged,
  }) {
    final opts = _opts(groupKey);
    if (opts.isEmpty) return const SizedBox.shrink();
    final sel = _selected(groupKey, value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
        const SizedBox(height: 4),
        NeoDropdownField(
          label: '',
          options: opts,
          selectedOption: sel,
          onSelected: (opt) => setState(() => onChanged(opt.value, opt.label)),
        ),
      ],
    );
  }

  // ── Scene text field compact (stateful) ─────────────────────
  Widget _sceneField(int sceneIdx, String key, String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black54)),
        const SizedBox(height: 3),
        TextFormField(
          key: ValueKey('scene_${sceneIdx}_$key'),
          initialValue: (_scenes[sceneIdx][key] ?? '').toString(),
          maxLines: maxLines,
          onChanged: (val) => _scenes[sceneIdx][key] = val,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black26),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentScene = _scenes.isNotEmpty ? _scenes[_selectedSceneIdx] : null;
    final chars = _opts('fokus_karakter_video');

    return Column(
      children: [
        // ── 1. Project ───────────────────────────────────────────
        NeoSectionCard(
          title: 'Proyek & Konsep',
          emoji: '🎬',
          backgroundColor: const Color(0xFFF3E5F5),
          child: Column(
            children: [
              _field(label: 'Judul / Topik', ctrl: _topicCtrl, hint: 'cth: Pelarian Alex dari Lab'),
              const SizedBox(height: 10),
              _field(label: 'Sinopsis', ctrl: _sinopsisCtrl, hint: 'Ringkasan cerita...', maxLines: 2),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Durasi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<int>(
                            value: _durasi,
                            isExpanded: true,
                            underline: const SizedBox(),
                            isDense: true,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
                            items: const [5, 8, 10, 15, 30, 60, 90, 120]
                                .map((d) => DropdownMenuItem(value: d, child: Text('$d detik')))
                                .toList(),
                            onChanged: (v) { if (v != null) setState(() => _durasi = v); },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dropdown(
                      label: 'Gaya Visual',
                      groupKey: 'gaya_video',
                      value: _gaya,
                      onChanged: (v, l) => _gaya = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: NeoSecondaryButton(
                  text: '✨ Analisis AI & Storyboard Otomatis',
                  isLoading: widget.isAnalyzing,
                  icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.black),
                  onPressed: _runAutoStoryboard,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── 2. Alur Cerita ───────────────────────────────────────
        NeoSectionCard(
          title: 'Alur Cerita',
          emoji: '📖',
          child: Column(
            children: [
              _dropdown(
                label: 'Jenis Cerita',
                groupKey: 'jenis_cerita_video',
                value: _jenisCerita,
                onChanged: (v, l) => _jenisCerita = v,
              ),
              const SizedBox(height: 10),
              _field(label: 'Konflik', ctrl: _konfliktCtrl, hint: 'Masalah utama cerita...', maxLines: 2),
              const SizedBox(height: 10),
              _field(label: 'Resolusi / Ending', ctrl: _resolusiCtrl, hint: 'Bagaimana berakhir...', maxLines: 2),
              const SizedBox(height: 10),
              _field(label: 'Emosi Arc', ctrl: _emosiCtrl, hint: 'cth: Tenang → Tegang → Lega'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── 3. Karakter dari DB ──────────────────────────────────
        NeoSectionCard(
          title: 'Karakter',
          emoji: '👤',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih karakter dari database:', style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 8),
              if (chars.isEmpty)
                const Text('Belum ada karakter di database.', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: chars.map((c) {
                    final isSelected = _selectedCharIds.contains(c.value);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedCharIds.remove(c.value);
                            _selectedCharLabels.remove(c.label);
                          } else {
                            _selectedCharIds.add(c.value);
                            _selectedCharLabels.add(c.label);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.white,
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected ? null : const [BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (c.icon != null && c.icon!.isNotEmpty) ...[
                              ClipOval(
                                child: c.icon!.startsWith('http')
                                    ? Image.network(c.icon!, width: 18, height: 18, fit: BoxFit.cover)
                                    : Image.asset(c.icon!, width: 18, height: 18, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              c.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.check, size: 12, color: Colors.white),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (_selectedCharIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: NeoTheme.accentGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: NeoTheme.accentGreen, width: 1),
                  ),
                  child: Text(
                    '✅ ${_selectedCharIds.length} terpilih: ${_selectedCharLabels.join(', ')}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── 4. Setting Visual ────────────────────────────────────
        NeoSectionCard(
          title: 'Setting Visual',
          emoji: '🎥',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _dropdown(label: 'Kamera', groupKey: 'gerakan_kamera_video', value: _kamera, onChanged: (v, l) => _kamera = v)),
                  const SizedBox(width: 10),
                  Expanded(child: _dropdown(label: 'Lokasi', groupKey: 'lokasi_video', value: _lokasi, onChanged: (v, l) => _lokasi = v)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _dropdown(label: 'Transisi', groupKey: 'transisi_video', value: _transisi, onChanged: (v, l) => _transisi = v)),
                  const SizedBox(width: 10),
                  Expanded(child: _dropdown(label: 'Mood Audio', groupKey: 'mood_audio_video', value: _moodAudio, onChanged: (v, l) => _moodAudio = v)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── 5. Scene Builder ─────────────────────────────────────
        NeoSectionCard(
          title: 'Scene Builder',
          emoji: '🎞️',
          backgroundColor: const Color(0xFFE8F5E9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _scenes.asMap().entries.map((e) {
                    final idx = e.key;
                    final active = _selectedSceneIdx == idx;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSceneIdx = idx),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8, bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? Colors.black : Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: active ? null : const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                        ),
                        child: Text(
                          'S${idx + 1} · ${_scenes[idx]['duration']}s',
                          style: TextStyle(
                            color: active ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Scene Edit Panel
              if (currentScene != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SCENE #${_selectedSceneIdx + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: NeoTheme.accentPink),
                          ),
                          if (_scenes.length > 1)
                            GestureDetector(
                              onTap: () => _deleteScene(_selectedSceneIdx),
                              child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _sceneField(_selectedSceneIdx, 'title', 'Judul Scene'),
                      const SizedBox(height: 8),
                      _sceneField(_selectedSceneIdx, 'action', 'Aksi Visual', maxLines: 2),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _sceneField(_selectedSceneIdx, 'dialogue', 'Dialogue/VO')),
                          const SizedBox(width: 8),
                          Expanded(child: _sceneField(_selectedSceneIdx, 'soundEffect', 'Sound FX')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Quick presets kamera
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Preset kamera:', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ...['Close Up', 'Wide Shot', 'Tracking', 'Aerial'].map((p) => GestureDetector(
                            onTap: () => setState(() => _scenes[_selectedSceneIdx]['camera'] = p),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _scenes[_selectedSceneIdx]['camera'] == p ? Colors.black : Colors.grey[100],
                                border: Border.all(color: Colors.black45),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                p,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: _scenes[_selectedSceneIdx]['camera'] == p ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeoSecondaryButton(
                    text: '+ Scene',
                    icon: const Icon(Icons.add, size: 14),
                    onPressed: _addScene,
                  ),
                  Text(
                    '${_scenes.length} scene · ${_scenes.fold<int>(0, (s, sc) => s + (sc['duration'] as int? ?? 10))}s total',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: NeoPrimaryButton(
                text: '⚡ GENERATE (AI BAWAAN)',
                isLoading: widget.isGenerating,
                onPressed: _submit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NeoPrimaryButton(
                text: '📋 SALIN PROMPT (AI LAIN)',
                onPressed: _submitExternal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
