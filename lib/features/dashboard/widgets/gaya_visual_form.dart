import 'package:flutter/material.dart';
import '../../../core/network/dio_client.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/neo_section_card.dart';
import '../../../shared/widgets/neo_upload_box.dart';
import '../../../shared/widgets/neo_text_field.dart';
import '../../../shared/widgets/neo_dropdown_field.dart';
import '../../../shared/widgets/neo_buttons.dart';
import '../../../shared/widgets/neo_watermark_list_field.dart';
import '../dropdown_provider.dart';

class GayaVisualForm extends StatefulWidget {
  final DropdownState dropdownState;
  final List<NeoDropdownOption> dynamicVisualStyles;
  final bool loadingVisualStyles;
  final bool isGenerating;
  final bool isAnalyzing;
  final Future<void> Function(Map<String, dynamic> payload) onGenerate;
  final void Function(Map<String, dynamic> payload) onGenerateExternal;
  final Future<Map<String, String>?> Function(String topic) onAnalyzeCerdas;

  const GayaVisualForm({
    super.key,
    required this.dropdownState,
    required this.dynamicVisualStyles,
    required this.loadingVisualStyles,
    required this.isGenerating,
    required this.isAnalyzing,
    required this.onGenerate,
    required this.onGenerateExternal,
    required this.onAnalyzeCerdas,
  });

  @override
  State<GayaVisualForm> createState() => _GayaVisualFormState();
}

class _GayaVisualFormState extends State<GayaVisualForm> {
  XFile? _refImage;
  final _namaGayaController = TextEditingController();
  final _descController = TextEditingController();
  final _extraController = TextEditingController();
  String _watermarkText = '';

  NeoDropdownOption? _selectedKategori;
  NeoDropdownOption? _selectedMood;
  NeoDropdownOption? _selectedDominasiWarna;
  NeoDropdownOption? _selectedMediumSeni;
  NeoDropdownOption? _selectedPencahayaan;
  NeoDropdownOption? _selectedTekstur;

  bool _showAdvanced = false;
  int _aiStyleIndex = 0;

  @override
  void dispose() {
    _namaGayaController.dispose();
    _descController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  Future<void> _generateAiVisualStyleIdea() async {
    try {
      final res = await dioClient.get('/poster/suggest-visual-style');
      if (res.data != null && res.data['success'] == true && res.data['data'] != null) {
        final pick = Map<String, dynamic>.from(res.data['data']);
        _applyStyleIdea(pick);
        return;
      }
    } catch (_) {}

    final List<Map<String, dynamic>> styleIdeas = [
      {
        'nama': 'Swiss Cyber Neon 2026',
        'kategori': 'Cyberpunk Neon',
        'mood': 'Bold & Impactful',
        'medium': '3D Studio Render',
        'warna': 'Dark Mode & Neon Accent',
        'cahaya': 'Studio Rim Neon Glow',
        'tekstur': 'Smooth Glassmorphism & Matte',
        'desc': 'Kombinasi antara grid tipografi Swiss minimalis kontemporer dengan efek pencahayaan neon 3D yang lembut di latar belakang gelap matte. Negative space 40% untuk kesan sangat mewah.',
        'extra': 'Teks tipografi bold san-serif presisi tinggi, aksen garis neon cyan dan magenta halus.',
      },
    ];

    final pick = styleIdeas[_aiStyleIndex % styleIdeas.length];
    _aiStyleIndex++;
    _applyStyleIdea(pick);
  }

  void _applyStyleIdea(Map<String, dynamic> pick) {
    setState(() {
      _namaGayaController.text = pick['nama'] ?? '';
      _descController.text = pick['desc'] ?? '';
      _extraController.text = pick['extra'] ?? '';

      final kategoriList = widget.dropdownState.groups['gaya_kategori'];
      if (kategoriList != null && kategoriList.isNotEmpty) {
        _selectedKategori = kategoriList.firstWhere(
          (o) => o.value == pick['kategori'],
          orElse: () => kategoriList.first,
        );
      }

      final moodList = widget.dropdownState.groups['gaya_mood'];
      if (moodList != null && moodList.isNotEmpty) {
        _selectedMood = moodList.firstWhere(
          (o) => o.value == pick['mood'],
          orElse: () => moodList.first,
        );
      }

      final mediumList = widget.dropdownState.groups['gaya_medium'];
      if (mediumList != null && mediumList.isNotEmpty) {
        _selectedMediumSeni = mediumList.firstWhere(
          (o) => o.value == pick['medium'],
          orElse: () => mediumList.first,
        );
      }

      final warnaList = widget.dropdownState.groups['gaya_warna'];
      if (warnaList != null && warnaList.isNotEmpty) {
        _selectedDominasiWarna = warnaList.firstWhere(
          (o) => o.value == pick['warna'],
          orElse: () => warnaList.first,
        );
      }

      final cahayaList = widget.dropdownState.groups['gaya_pencahayaan'];
      if (cahayaList != null && cahayaList.isNotEmpty) {
        _selectedPencahayaan = cahayaList.firstWhere(
          (o) => o.value == pick['cahaya'],
          orElse: () => cahayaList.first,
        );
      }

      final teksturList = widget.dropdownState.groups['gaya_tekstur'];
      if (teksturList != null && teksturList.isNotEmpty) {
        _selectedTekstur = teksturList.firstWhere(
          (o) => o.value == pick['tekstur'],
          orElse: () => teksturList.first,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ Ide Gaya Visual AI "${pick['nama']}" diterapkan dari Backend!'),
        backgroundColor: const Color(0xFF9C27B0),
      ),
    );
  }

  void _submitExternal() {
    final namaGaya = _namaGayaController.text.trim();
    if (namaGaya.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Nama Gaya Visual wajib diisi!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    widget.onGenerateExternal({
      'feature': 'gaya_visual',
      'topic': namaGaya,
      'namaGaya': namaGaya,
      'kategori': _selectedKategori?.value ?? 'Modern Minimalis',
      'mood': _selectedMood?.value ?? 'Elegan & Profesional',
      'dominasiWarna': _selectedDominasiWarna?.value ?? 'Dark Mode & Neon Accent',
      'mediumSeni': _selectedMediumSeni?.value ?? '3D Studio Render',
      'pencahayaan': _selectedPencahayaan?.value ?? 'Cinematic Studio Light',
      'tekstur': _selectedTekstur?.value ?? 'Smooth Glassmorphism & Matte',
      'description': _descController.text.trim(),
      'extraDetails': _extraController.text.trim(),
      'watermark': _watermarkText,
      'referenceImage': _refImage,
      'useManualLogo': false,
      'slideCount': 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    final kategoriList = widget.dropdownState.groups['gaya_kategori'] ??
        [
          NeoDropdownOption(id: 'gk1', label: '🏢 Modern Minimalis & Clean', value: 'Modern Minimalis'),
          NeoDropdownOption(id: 'gk2', label: '🌌 Cyberpunk & Futuristic Neon', value: 'Cyberpunk Neon'),
          NeoDropdownOption(id: 'gk3', label: '🎨 Retro & Vintage 90s', value: 'Retro Vintage'),
          NeoDropdownOption(id: 'gk4', label: '🌿 Organic & Nature Minimalist', value: 'Organic Nature'),
          NeoDropdownOption(id: 'gk5', label: '✨ Luxury & Elegant Gold', value: 'Luxury Gold'),
          NeoDropdownOption(id: 'gk6', label: '🎮 Pixel Art & Gaming', value: 'Pixel Art Gaming'),
        ];

    final moodList = widget.dropdownState.groups['gaya_mood'] ??
        [
          NeoDropdownOption(id: 'gm1', label: '💎 Elegan & Profesional', value: 'Elegan & Profesional'),
          NeoDropdownOption(id: 'gm2', label: '🔥 Energetik & Dynamic', value: 'Energetik & Dynamic'),
          NeoDropdownOption(id: 'gm3', label: '🌙 Misterius & Atmospheric', value: 'Misterius & Atmospheric'),
          NeoDropdownOption(id: 'gm4', label: '🌸 Soft & Calming Pastel', value: 'Soft & Calming Pastel'),
          NeoDropdownOption(id: 'gm5', label: '🚀 Bold & Impactful', value: 'Bold & Impactful'),
        ];

    final warnaList = widget.dropdownState.groups['gaya_warna'] ??
        [
          NeoDropdownOption(id: 'gw1', label: '🖤 Dark Mode & Neon Accent', value: 'Dark Mode & Neon Accent'),
          NeoDropdownOption(id: 'gw2', label: '🤍 Light Mode & Clean Monochrome', value: 'Light Mode Monochrome'),
          NeoDropdownOption(id: 'gw3', label: '🌈 Vibrant Multicolor Pastel', value: 'Vibrant Pastel'),
          NeoDropdownOption(id: 'gw4', label: '🍂 Warm Earth Tone & Terracotta', value: 'Warm Earth Tone'),
          NeoDropdownOption(id: 'gw5', label: '🌊 Deep Ocean & Cyan Gradient', value: 'Deep Ocean Cyan'),
        ];

    final mediumList = widget.dropdownState.groups['gaya_medium'] ??
        [
          NeoDropdownOption(id: 'gm1', label: '🔮 3D Studio Render (Octane / Cinema4D)', value: '3D Studio Render'),
          NeoDropdownOption(id: 'gm2', label: '📐 2D Swiss Vector Grid', value: '2D Swiss Vector Grid'),
          NeoDropdownOption(id: 'gm3', label: '📸 Hyperrealistic Photography', value: 'Hyperrealistic Photography'),
          NeoDropdownOption(id: 'gm4', label: '🎨 Oil Painting & Fine Art', value: 'Oil Painting Fine Art'),
          NeoDropdownOption(id: 'gm5', label: '📰 Collage Paper & Cutout', value: 'Collage Paper Cutout'),
        ];

    final cahayaList = widget.dropdownState.groups['gaya_pencahayaan'] ??
        [
          NeoDropdownOption(id: 'gc1', label: '🎬 Cinematic Studio Soft Lighting', value: 'Cinematic Studio Light'),
          NeoDropdownOption(id: 'gc2', label: '☀️ Natural Golden Hour Sunlight', value: 'Natural Golden Hour'),
          NeoDropdownOption(id: 'gc3', label: '💡 Volumetric Rim Light & Fog', value: 'Volumetric Rim Light'),
          NeoDropdownOption(id: 'gc4', label: '🔮 Studio Rim Neon Glow', value: 'Studio Rim Neon Glow'),
        ];

    final teksturList = widget.dropdownState.groups['gaya_tekstur'] ??
        [
          NeoDropdownOption(id: 'gt1', label: '🧊 Smooth Glassmorphism & Frost', value: 'Smooth Glassmorphism & Matte'),
          NeoDropdownOption(id: 'gt2', label: '📜 Rough Paper & Vintage Grain', value: 'Rough Paper & Grain'),
          NeoDropdownOption(id: 'gt3', label: '✨ Metallic Gold & Chrome Reflection', value: 'Metallic Chrome Reflection'),
          NeoDropdownOption(id: 'gt4', label: '🧶 Soft Clay & Fabric Texture', value: 'Soft Clay Fabric'),
        ];

    if (_selectedKategori == null && kategoriList.isNotEmpty) _selectedKategori = kategoriList.first;
    if (_selectedMood == null && moodList.isNotEmpty) _selectedMood = moodList.first;
    if (_selectedDominasiWarna == null && warnaList.isNotEmpty) _selectedDominasiWarna = warnaList.first;
    if (_selectedMediumSeni == null && mediumList.isNotEmpty) _selectedMediumSeni = mediumList.first;
    if (_selectedPencahayaan == null && cahayaList.isNotEmpty) _selectedPencahayaan = cahayaList.first;
    if (_selectedTekstur == null && teksturList.isNotEmpty) _selectedTekstur = teksturList.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Banner Rapat (Tanpa Teks Deskripsi Panjang)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F5FE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.palette_outlined, color: Colors.black, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '🎨 GAYA VISUAL DESIGN SYSTEM',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _generateAiVisualStyleIdea,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5))],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 15),
                      SizedBox(width: 6),
                      Text(
                        '⚡ SARAN AI GAYA VISUAL',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Referensi Moodboard Gambar (Opsional)
        NeoSectionCard(
          title: 'Gambar Moodboard (Opsional)',
          emoji: '🖼️',
          isOptional: true,
          child: NeoUploadBox(
            title: 'Unggah Gambar Moodboard',
            subtitle: 'PNG / JPG',
            initialFile: _refImage,
            onFilePicked: (file) => setState(() => _refImage = file),
          ),
        ),
        const SizedBox(height: 10),

        // Section 1: Identitas Gaya Visual
        NeoSectionCard(
          title: 'Identitas Gaya Visual',
          emoji: '✨',
          backgroundColor: const Color(0xFFE8EAF6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeoTextField(
                key: const ValueKey('gaya_nama'),
                label: 'Nama Gaya Visual *',
                placeholder: 'mis: Swiss Cyber Neon 2026, Luxury Gold...',
                controller: _namaGayaController,
              ),
              const SizedBox(height: 8),
              NeoDropdownField(
                key: const ValueKey('gaya_kategori_dp'),
                label: 'Kategori Gaya',
                options: kategoriList,
                selectedOption: _selectedKategori,
                onSelected: (val) => setState(() => _selectedKategori = val),
              ),
              const SizedBox(height: 8),
              NeoDropdownField(
                key: const ValueKey('gaya_mood_dp'),
                label: 'Mood & Atmosfer',
                options: moodList,
                selectedOption: _selectedMood,
                onSelected: (val) => setState(() => _selectedMood = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Section 2: Spesifikasi Seni & Warna
        NeoSectionCard(
          title: 'Spesifikasi Seni & Warna',
          emoji: '🔮',
          backgroundColor: const Color(0xFFF1F8E9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeoDropdownField(
                key: const ValueKey('gaya_medium_dp'),
                label: 'Medium Seni',
                options: mediumList,
                selectedOption: _selectedMediumSeni,
                onSelected: (val) => setState(() => _selectedMediumSeni = val),
              ),
              const SizedBox(height: 8),
              NeoDropdownField(
                key: const ValueKey('gaya_warna_dp'),
                label: 'Dominasi Warna',
                options: warnaList,
                selectedOption: _selectedDominasiWarna,
                onSelected: (val) => setState(() => _selectedDominasiWarna = val),
              ),
              const SizedBox(height: 8),
              NeoDropdownField(
                key: const ValueKey('gaya_cahaya_dp'),
                label: 'Pencahayaan',
                options: cahayaList,
                selectedOption: _selectedPencahayaan,
                onSelected: (val) => setState(() => _selectedPencahayaan = val),
              ),
              const SizedBox(height: 8),
              NeoDropdownField(
                key: const ValueKey('gaya_tekstur_dp'),
                label: 'Tekstur Surface',
                options: teksturList,
                selectedOption: _selectedTekstur,
                onSelected: (val) => setState(() => _selectedTekstur = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Section 3: Catatan Estetika (Judul Ringkas Tanpa Deskripsi Panjang)
        NeoSectionCard(
          title: 'Catatan Estetika',
          emoji: '📝',
          child: Column(
            children: [
              NeoTextField(
                key: const ValueKey('gaya_desc'),
                label: 'Konsep Estetika',
                placeholder: 'mis: Kombinasi grid tipografi Swiss minimalis dengan neon 3D...',
                maxLines: 3,
                controller: _descController,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Opsi Lanjutan
        InkWell(
          onTap: () => setState(() => _showAdvanced = !_showAdvanced),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('⚙️ OPSI LANJUTAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more, color: Colors.black),
              ],
            ),
          ),
        ),
        if (_showAdvanced) ...[
          const SizedBox(height: 8),
          NeoSectionCard(
            title: 'Detail Ekstra',
            emoji: '🛠️',
            child: Column(
              children: [
                NeoTextField(
                  key: const ValueKey('gaya_extra'),
                  label: 'Detail Tambahan Visual',
                  placeholder: 'mis: Hindari warna terlalu mencolok...',
                  maxLines: 2,
                  controller: _extraController,
                ),
                const SizedBox(height: 8),
                NeoWatermarkListField(
                  key: const ValueKey('gaya_watermark'),
                  initialValue: _watermarkText,
                  onChanged: (val) => setState(() => _watermarkText = val),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Tombol Submit AI Eksternal
        NeoPrimaryButton(
          text: '⚡ BUAT PROMPT GAYA VISUAL',
          icon: const Icon(Icons.copy_all, color: Colors.white),
          onPressed: _submitExternal,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
