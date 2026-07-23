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

class KarakterForm extends StatefulWidget {
  final DropdownState dropdownState;
  final List<NeoDropdownOption> dynamicVisualStyles;
  final bool loadingVisualStyles;
  final bool isGenerating;
  final bool isAnalyzing;
  final Future<void> Function(Map<String, dynamic> payload) onGenerate;
  final void Function(Map<String, dynamic> payload) onGenerateExternal;
  final Future<Map<String, String>?> Function(String topic) onAnalyzeCerdas;

  const KarakterForm({
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
  State<KarakterForm> createState() => _KarakterFormState();
}

class _KarakterFormState extends State<KarakterForm> {
  XFile? _refImage;
  final _namaController = TextEditingController();
  final _spesiesController = TextEditingController();
  final _descController = TextEditingController();
  final _extraController = TextEditingController();
  String _watermarkText = '';

  NeoDropdownOption? _selectedJenis;
  NeoDropdownOption? _selectedKategori;
  NeoDropdownOption? _selectedUsia;
  NeoDropdownOption? _selectedKepribadian;
  NeoDropdownOption? _selectedGaya;
  NeoDropdownOption? _selectedWarna;
  NeoDropdownOption? _selectedPlatform;

  bool _showAdvanced = false;
  int _aiIdeaIndex = 0;

  @override
  void dispose() {
    _namaController.dispose();
    _spesiesController.dispose();
    _descController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  Future<void> _generateAiCharacterIdea() async {
    try {
      final res = await dioClient.get('/poster/suggest-character');
      if (res.data != null && res.data['success'] == true && res.data['data'] != null) {
        final pick = Map<String, dynamic>.from(res.data['data']);
        _applyIdea(pick);
        return;
      }
    } catch (_) {}

    final List<Map<String, dynamic>> ideas = [
      {
        'nama': 'Pipo si Penguin Explorer',
        'spesies': 'Penguin Kaisar Antartika',
        'jenis': 'Hewan',
        'kategori': 'Maskot Brand',
        'gaya': '3D Pixar Disney Style',
        'usia': 'Anak-anak',
        'kepribadian': 'Ceria, Energik, Ramah',
        'warna': 'Kuning & Biru',
        'platform': 'Poster, Logo, Banner & Video',
        'desc': 'Memakai jaket explorer warna oranye terang dengan bulu domba, kacamata aviator emas di dahi, membawa tas ransel petualang cokelat tua tempat simpan peta. Di leher menggantung kompas emas mengkilap.',
      },
      {
        'nama': 'Kiko si Rubah Cyber',
        'spesies': 'Rubah Ekor Merah Futuristis',
        'jenis': 'Hewan',
        'kategori': 'Karakter Game',
        'gaya': '3D Cute Isometric',
        'usia': 'Remaja',
        'kepribadian': 'Keren, Cool, Misterius',
        'warna': 'Merah & Oranye',
        'platform': 'YouTube 16:9 Widescreen',
        'desc': 'Memakai hoodie neon cyberpunk transparan dengan pola hologram glowing, visor futuristis cyan di mata, dan sneakers high-top menyala. Ekor rubah berujung putih bersinar lembut.',
      },
    ];

    final pick = ideas[_aiIdeaIndex % ideas.length];
    _aiIdeaIndex++;
    _applyIdea(pick);
  }

  void _applyIdea(Map<String, dynamic> pick) {
    setState(() {
      _namaController.text = pick['nama'] ?? '';
      _spesiesController.text = pick['spesies'] ?? '';
      _descController.text = pick['desc'] ?? '';

      final jenisList = widget.dropdownState.groups['karakter_jenis'];
      if (jenisList != null && jenisList.isNotEmpty) {
        _selectedJenis = jenisList.firstWhere(
          (o) => o.value == pick['jenis'],
          orElse: () => jenisList.first,
        );
      }

      final kategoriList = widget.dropdownState.groups['karakter_kategori'];
      if (kategoriList != null && kategoriList.isNotEmpty) {
        _selectedKategori = kategoriList.firstWhere(
          (o) => o.value == pick['kategori'],
          orElse: () => kategoriList.first,
        );
      }

      final gayaList = widget.dropdownState.groups['karakter_gaya_ilustrasi'];
      if (gayaList != null && gayaList.isNotEmpty) {
        _selectedGaya = gayaList.firstWhere(
          (o) => o.value == pick['gaya'],
          orElse: () => gayaList.first,
        );
      }

      final usiaList = widget.dropdownState.groups['karakter_usia'];
      if (usiaList != null && usiaList.isNotEmpty) {
        _selectedUsia = usiaList.firstWhere(
          (o) => o.value == pick['usia'],
          orElse: () => usiaList.first,
        );
      }

      final kepribadianList = widget.dropdownState.groups['karakter_kepribadian'];
      if (kepribadianList != null && kepribadianList.isNotEmpty) {
        _selectedKepribadian = kepribadianList.firstWhere(
          (o) => o.value == pick['kepribadian'],
          orElse: () => kepribadianList.first,
        );
      }

      final warnaList = widget.dropdownState.groups['palet_warna_edukasi'];
      if (warnaList != null && warnaList.isNotEmpty) {
        _selectedWarna = warnaList.firstWhere(
          (o) => o.value == pick['warna'],
          orElse: () => warnaList.first,
        );
      }

      final platformList = widget.dropdownState.groups['karakter_platform'];
      if (platformList != null && platformList.isNotEmpty) {
        _selectedPlatform = platformList.firstWhere(
          (o) => o.value == pick['platform'],
          orElse: () => platformList.first,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ Ide Karakter AI "${pick['nama']}" diterapkan dari Backend!'),
        backgroundColor: const Color(0xFFFF9800),
      ),
    );
  }

  void _submitExternal() {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Nama Karakter wajib diisi!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    widget.onGenerateExternal({
      'feature': 'karakter',
      'topic': nama,
      'namaKarakter': nama,
      'spesies': _spesiesController.text.trim(),
      'jenisKarakter': _selectedJenis?.value ?? 'Hewan',
      'kategori': _selectedKategori?.value ?? 'Maskot Brand',
      'usiaVisual': _selectedUsia?.value ?? 'Dewasa',
      'kepribadian': _selectedKepribadian?.value ?? 'Ceria, Ramah',
      'gayaIlustrasi': _selectedGaya?.value ?? '3D Cartoon',
      'warnaUtama': _selectedWarna?.value ?? 'auto',
      'platform': _selectedPlatform?.value ?? 'Poster, Logo, Banner & Video',
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
    final jenisList = widget.dropdownState.groups['karakter_jenis'] ??
        [
          NeoDropdownOption(id: 'kj1', label: '🐱 Hewan (Animal Mascot)', value: 'Hewan'),
          NeoDropdownOption(id: 'kj2', label: '👤 Manusia (Human Character)', value: 'Manusia'),
          NeoDropdownOption(id: 'kj3', label: '🐉 Makhluk Fantasi (Fantasy Creature)', value: 'Makhluk Fantasi'),
          NeoDropdownOption(id: 'kj4', label: '🤖 Robot / Android', value: 'Robot'),
        ];

    final kategoriList = widget.dropdownState.groups['karakter_kategori'] ??
        [
          NeoDropdownOption(id: 'kk1', label: '🏆 Maskot Brand', value: 'Maskot Brand'),
          NeoDropdownOption(id: 'kk2', label: '📚 Karakter Edukasi', value: 'Karakter Edukasi'),
          NeoDropdownOption(id: 'kk3', label: '📖 Tokoh Cerita / Komik', value: 'Tokoh Cerita'),
          NeoDropdownOption(id: 'kk4', label: '🎮 Karakter Game / Avatar', value: 'Karakter Game'),
          NeoDropdownOption(id: 'kk5', label: '🌐 Influencer Virtual', value: 'Influencer Virtual'),
        ];

    final usiaList = widget.dropdownState.groups['karakter_usia'] ??
        [
          NeoDropdownOption(id: 'ku1', label: '👶 Anak-anak (Cute / Chibi)', value: 'Anak-anak'),
          NeoDropdownOption(id: 'ku2', label: '🧑 Remaja (Young & Trendy)', value: 'Remaja'),
          NeoDropdownOption(id: 'ku3', label: '👨 Dewasa (Mature & Professional)', value: 'Dewasa'),
          NeoDropdownOption(id: 'ku4', label: '👴 Lansia (Wise & Elder)', value: 'Lansia'),
        ];

    final kepribadianList = widget.dropdownState.groups['karakter_kepribadian'] ??
        [
          NeoDropdownOption(id: 'kp1', label: '✨ Ceria, Energik & Ramah', value: 'Ceria, Energik, Ramah'),
          NeoDropdownOption(id: 'kp2', label: '🧠 Bijak, Cerdas & Penolong', value: 'Bijak, Cerdas, Penolong'),
          NeoDropdownOption(id: 'kp3', label: '🔥 Pemberani, Tangguh & Explorer', value: 'Pemberani, Tangguh, Penjelajah'),
          NeoDropdownOption(id: 'kp4', label: '🎨 Kreatif, Unik & Eksentrik', value: 'Kreatif, Unik, Eksentrik'),
          NeoDropdownOption(id: 'kp5', label: '😎 Keren, Cool & Misterius', value: 'Keren, Cool, Misterius'),
        ];

    final gayaList = widget.dropdownState.groups['karakter_gaya_ilustrasi'] ??
        [
          NeoDropdownOption(id: 'kg1', label: '🧸 3D Pixar / Disney Style', value: '3D Pixar Disney Style'),
          NeoDropdownOption(id: 'kg2', label: '🎨 3D Cute Isometric Render', value: '3D Cute Isometric'),
          NeoDropdownOption(id: 'kg3', label: '✏️ 2D Flat Vector Modern', value: '2D Flat Vector'),
          NeoDropdownOption(id: 'kg4', label: '🎌 Anime / Manga Chibi', value: 'Anime Chibi Style'),
          NeoDropdownOption(id: 'kg5', label: '🖌️ Claymation 3D', value: 'Claymation 3D'),
        ];

    final warnaList = widget.dropdownState.groups['palet_warna_edukasi'] ??
        [
          NeoDropdownOption(id: 'kw1', label: '✨ Otomatis (AI Harmonis)', value: 'auto'),
          NeoDropdownOption(id: 'kw2', label: '🟡 Kuning & Biru Cerah', value: 'Kuning & Biru'),
          NeoDropdownOption(id: 'kw3', label: '🔴 Merah & Oranye Energik', value: 'Merah & Oranye'),
          NeoDropdownOption(id: 'kw4', label: '🟢 Hijau Tropis & Alam', value: 'Hijau Tropis'),
          NeoDropdownOption(id: 'kw5', label: '🟣 Ungu Pastel & Pink Soft', value: 'Ungu Pastel & Pink'),
        ];

    final platformList = widget.dropdownState.groups['karakter_platform'] ??
        [
          NeoDropdownOption(id: 'pf1', label: '🌐 All-in-One (Poster Edukasi, Logo, Banner & Video)', value: 'Poster, Logo, Banner & Video'),
          NeoDropdownOption(id: 'pf2', label: '📚 Poster & Infografis Edukasi', value: 'Poster Edukasi'),
          NeoDropdownOption(id: 'pf3', label: '🏷️ Brand Mascot & Logo Design', value: 'Logo & Brand Mascot'),
          NeoDropdownOption(id: 'pf4', label: '📢 Banner Promosi & Billboard (16:9)', value: 'Banner 16:9'),
          NeoDropdownOption(id: 'pf5', label: '🎬 Video Shorts & YouTube Widescreen (16:9)', value: 'YouTube 16:9 Widescreen'),
        ];

    if (_selectedJenis == null && jenisList.isNotEmpty) _selectedJenis = jenisList.first;
    if (_selectedKategori == null && kategoriList.isNotEmpty) _selectedKategori = kategoriList.first;
    if (_selectedUsia == null && usiaList.isNotEmpty) _selectedUsia = usiaList.first;
    if (_selectedKepribadian == null && kepribadianList.isNotEmpty) _selectedKepribadian = kepribadianList.first;
    if (_selectedGaya == null && gayaList.isNotEmpty) _selectedGaya = gayaList.first;
    if (_selectedWarna == null && warnaList.isNotEmpty) _selectedWarna = warnaList.first;
    if (_selectedPlatform == null && platformList.isNotEmpty) _selectedPlatform = platformList.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Banner Rapat (Tanpa Teks Deskripsi Panjang)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.face_retouching_natural, color: Colors.black, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '🎭 KARAKTER BIBLE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _generateAiCharacterIdea,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800),
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
                        '⚡ SARAN AI KARAKTER',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Referensi Gambar Karakter (Opsional)
        NeoSectionCard(
          title: 'Sketsa / Referensi (Opsional)',
          emoji: '📸',
          isOptional: true,
          child: NeoUploadBox(
            title: 'Unggah Gambar Referensi',
            subtitle: 'PNG / JPG',
            initialFile: _refImage,
            onFilePicked: (file) => setState(() => _refImage = file),
          ),
        ),
        const SizedBox(height: 10),

        // Section 1: Identitas Karakter
        NeoSectionCard(
          title: 'Identitas Karakter',
          emoji: '🐣',
          backgroundColor: const Color(0xFFFFF3E0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeoTextField(
                key: const ValueKey('karakter_nama'),
                label: 'Nama Karakter *',
                placeholder: 'mis: Pipo si Penguin, Koko, Roxy...',
                controller: _namaController,
              ),
              const SizedBox(height: 8),
              NeoDropdownField(
                key: const ValueKey('karakter_jenis_dp'),
                label: 'Jenis Karakter',
                options: jenisList,
                selectedOption: _selectedJenis,
                onSelected: (val) => setState(() => _selectedJenis = val),
              ),
              const SizedBox(height: 8),
              NeoDropdownField(
                key: const ValueKey('karakter_kategori_dp'),
                label: 'Kategori Karakter',
                options: kategoriList,
                selectedOption: _selectedKategori,
                onSelected: (val) => setState(() => _selectedKategori = val),
              ),
              const SizedBox(height: 8),
              NeoTextField(
                key: const ValueKey('karakter_spesies'),
                label: 'Spesies / Ras Spesifik',
                placeholder: 'mis: Penguin Kaisar, Rubah Merah...',
                controller: _spesiesController,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Section 2: Gaya & Kepribadian
        NeoSectionCard(
          title: 'Gaya & Kepribadian',
          emoji: '🎨',
          backgroundColor: const Color(0xFFF3E5F5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeoDropdownField(
                key: const ValueKey('karakter_gaya_dp'),
                label: 'Gaya Ilustrasi',
                options: gayaList,
                selectedOption: _selectedGaya,
                onSelected: (val) => setState(() => _selectedGaya = val),
              ),
              const SizedBox(height: 8),
              NeoDropdownField(
                key: const ValueKey('karakter_usia_dp'),
                label: 'Usia Visual',
                options: usiaList,
                selectedOption: _selectedUsia,
                onSelected: (val) => setState(() => _selectedUsia = val),
              ),
              const SizedBox(height: 8),
              NeoDropdownField(
                key: const ValueKey('karakter_kepribadian_dp'),
                label: 'Kepribadian Utama',
                options: kepribadianList,
                selectedOption: _selectedKepribadian,
                onSelected: (val) => setState(() => _selectedKepribadian = val),
              ),
              const SizedBox(height: 8),
              NeoDropdownField(
                key: const ValueKey('karakter_warna_dp'),
                label: 'Palet Warna',
                options: warnaList,
                selectedOption: _selectedWarna,
                onSelected: (val) => setState(() => _selectedWarna = val),
              ),
              const SizedBox(height: 8),
              NeoDropdownField(
                key: const ValueKey('karakter_platform_dp'),
                label: 'Target Platform',
                options: platformList,
                selectedOption: _selectedPlatform,
                onSelected: (val) => setState(() => _selectedPlatform = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Section 3: Pakaian & Aksesori (Header & Judul Ringkas Tanpa Deskripsi Panjang)
        NeoSectionCard(
          title: 'Pakaian & Aksesori',
          emoji: '👕',
          child: Column(
            children: [
              NeoTextField(
                key: const ValueKey('karakter_desc'),
                label: 'Pakaian & Aksesori Wajib',
                placeholder: 'mis: Jaket petualang biru, kacamata aviator, tas ransel...',
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
                  key: const ValueKey('karakter_extra'),
                  label: 'Detail Tambahan Visual',
                  placeholder: 'mis: Bekas luka kecil di pipi kiri...',
                  maxLines: 2,
                  controller: _extraController,
                ),
                const SizedBox(height: 8),
                NeoWatermarkListField(
                  key: const ValueKey('karakter_watermark'),
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
          text: '⚡ BUAT PROMPT KARAKTER',
          icon: const Icon(Icons.copy_all, color: Colors.white),
          onPressed: _submitExternal,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
