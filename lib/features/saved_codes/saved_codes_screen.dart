import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/utils/file_directory_helper.dart';
import 'package:path/path.dart' as p;
import '../../core/theme/neo_theme.dart';

class SavedCodesScreen extends StatefulWidget {
  const SavedCodesScreen({Key? key}) : super(key: key);

  @override
  State<SavedCodesScreen> createState() => _SavedCodesScreenState();
}

class _SavedCodesScreenState extends State<SavedCodesScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    try {
      final appDir = await FileDirectoryHelper.getPublicDirectory();
      if (await appDir.exists()) {
        final files = appDir.listSync().where((f) => f is File && (f.path.endsWith('.txt') || f.path.endsWith('.json'))).toList();
        // Sort by modified date descending
        files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        setState(() {
          _files = files;
        });
      }
    } catch (e) {
      debugPrint('Error loading files: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        _loadFiles();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  void _openEditor(File file) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CodeEditorScreen(file: file, onSaved: _loadFiles),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      appBar: AppBar(
        title: const Text('📂 File Tersimpan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: NeoTheme.accentYellow,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 3)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                    ),
                    child: const Text('Belum ada file yang didownload.', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _files.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final file = _files[index] as File;
                    final fileName = p.basename(file.path);
                    return InkWell(
                      onTap: () => _openEditor(file),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                        ),
                        child: Row(
                          children: [
                            Icon(fileName.endsWith('.json') ? Icons.data_object : Icons.description, size: 32, color: NeoTheme.accentBlue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Terakhir diubah: ${file.statSync().modified.toString().substring(0, 16)}',
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus File?'),
                                    content: Text('Yakin ingin menghapus $fileName?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          _deleteFile(file);
                                        },
                                        child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class CodeEditorScreen extends StatefulWidget {
  final File file;
  final VoidCallback onSaved;

  const CodeEditorScreen({Key? key, required this.file, required this.onSaved}) : super(key: key);

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  late TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.file.readAsStringSync());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveFile() async {
    setState(() => _isSaving = true);
    try {
      await widget.file.writeAsString(_controller.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File berhasil disimpan!')));
      widget.onSaved();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTheme.bgBase,
      appBar: AppBar(
        title: Text(p.basename(widget.file.path), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: NeoTheme.accentPink,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 3)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveFile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
          ),
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }
}
