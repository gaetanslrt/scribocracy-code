import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:scribocracy_new/models/note.dart';
import 'package:scribocracy_new/providers.dart';
import 'package:scribocracy_new/services/ai_service.dart';
import 'package:scribocracy_new/services/pdf_generator.dart'; // Assurez-vous d'avoir ce fichier
import 'package:scribocracy_new/theme.dart';

class EditScreen extends ConsumerStatefulWidget {
  final Note? note;
  const EditScreen({super.key, this.note});

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isDirty = false;
  bool _isProcessingAI = false;
  
  List<String> _evidenceImages = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _availableTags = ["URGENT", "INTEL", "MONEY", "TARGET", "ARCHIVE"];
  List<String> _selectedTags = [];

  // GEO_INTEL VARIABLES
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    
    if (widget.note != null) {
      _evidenceImages = List.from(widget.note!.images);
      _selectedTags = List.from(widget.note!.tags);
      _latitude = widget.note!.latitude;
      _longitude = widget.note!.longitude;
    }
  }

  @override
  void deactivate() {
    if (_isDirty) _saveNote();
    super.deactivate();
  }

  // --- LOGIQUE GEO_INTEL ---
  Future<void> _acquireLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw "GPS_DISABLED";

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw "PERMISSION_DENIED";
      }
      if (permission == LocationPermission.deniedForever) throw "PERMISSION_DENIED_PERMANENTLY";

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isDirty = true;
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("TARGET LOCKED"), duration: Duration(seconds: 1)));

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("GEO_ERROR: $e"), backgroundColor: AppTheme.dangerRed));
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  // --- LOGIQUE AI (NEURAL LINK) ---
  void _showNeuralMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.carbon,
      shape: const BeveledRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("NEURAL_LINK_COMMANDS", style: TextStyle(color: AppTheme.neonCyan, fontFamily: 'Orbitron', letterSpacing: 2)),
              const Divider(color: Colors.white24),
              _buildNeuralOption("COMPRESS_DATA", "SUMMARIZE", Icons.compress),
              _buildNeuralOption("HOSTILE_REWRITE", "INTIMIDATE", Icons.dangerous),
              _buildNeuralOption("SYNTAX_OPTIMIZE", "CLEANUP", Icons.auto_fix_high),
              _buildNeuralOption("EXTRACT_ENTITIES", "EXTRACT", Icons.data_array),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeuralOption(String label, String command, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.holoWhite),
      title: Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'ShareTechMono')),
      onTap: () {
        Navigator.pop(context);
        _executeNeuralLink(command);
      },
    );
  }

  Future<void> _executeNeuralLink(String command) async {
    final text = _contentController.text;
    if (text.isEmpty) return;

    setState(() => _isProcessingAI = true);
    await Future.delayed(const Duration(milliseconds: 500)); 

    final result = await ref.read(aiServiceProvider).processText(text, command);

    setState(() => _isProcessingAI = false);
    if (result != null && mounted) _showNeuralResult(result);
  }

  void _showNeuralResult(String result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.voidBlack,
        shape: BeveledRectangleBorder(side: const BorderSide(color: AppTheme.neonCyan), borderRadius: BorderRadius.circular(10)),
        title: const Text("OUTPUT_RECEIVED", style: TextStyle(color: AppTheme.neonCyan, fontFamily: 'Orbitron')),
        content: SingleChildScrollView(child: Text(result, style: const TextStyle(color: Colors.white, fontFamily: 'ShareTechMono'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("DISCARD", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () {
              setState(() { _contentController.text += "\n\n--- AI_LOG ---\n$result"; _isDirty = true; });
              Navigator.pop(ctx);
            }, child: const Text("APPEND", style: TextStyle(color: AppTheme.neonCyan))),
          TextButton(onPressed: () {
              setState(() { _contentController.text = result; _isDirty = true; });
              Navigator.pop(ctx);
            }, child: const Text("OVERWRITE", style: TextStyle(color: AppTheme.dangerRed))),
        ],
      ),
    );
  }

  // --- LOGIQUE PDF ---
  Future<void> _exportPdf() async {
      if (_isDirty) _saveNote();
      final currentData = Note(
        title: _titleController.text,
        content: _contentController.text,
        modifiedTime: DateTime.now(),
        images: _evidenceImages,
        tags: _selectedTags,
        latitude: _latitude,
        longitude: _longitude,
      );
      await PdfGenerator.generateAndPrint(currentData);
  }

  // --- LOGIQUE IMAGES ---
  Future<void> _captureEvidence() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(image.path);
      final savedImage = await File(image.path).copy('${directory.path}/$fileName');
      setState(() { _evidenceImages.add(savedImage.path); _isDirty = true; });
    } catch (e) { debugPrint("EVIDENCE_CAPTURE_FAILED: $e"); }
  }

  // --- SAUVEGARDE ---
  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty && _evidenceImages.isEmpty) return;
    
    final db = ref.read(databaseProvider);
    if (widget.note != null) {
      final updated = Note(
        title: title, content: content, modifiedTime: DateTime.now(), 
        images: _evidenceImages, tags: _selectedTags, latitude: _latitude, longitude: _longitude
      )..id = widget.note!.id;
      db.saveNote(updated);
    } else {
      final newNote = Note(
        title: title, content: content, modifiedTime: DateTime.now(), 
        images: _evidenceImages, tags: _selectedTags, latitude: _latitude, longitude: _longitude
      );
      db.saveNote(newNote);
    }
  }

  void _markDirty() { if (!_isDirty) setState(() => _isDirty = true); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_sharp, color: AppTheme.neonCyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isDirty ? "UNSAVED_DATA..." : "SECURE_CONNECTION", 
             style: TextStyle(fontFamily: 'Orbitron', fontSize: 12, letterSpacing: 3, color: _isDirty ? AppTheme.dangerRed : Colors.grey)),
        actions: [
          // 1. BOUTON CAMERA (Direct Access)
          IconButton(
            onPressed: _captureEvidence,
            icon: const Icon(Icons.add_a_photo_outlined, color: AppTheme.neonCyan),
            tooltip: "QUICK_EVIDENCE",
          ),
          
          // 2. MENU DÉROULANT CYBERPUNK (Les 3 autres options)
          Theme(
            data: Theme.of(context).copyWith(
              // Personnalisation du menu pour le rendre "Carbon"
              popupMenuTheme: PopupMenuThemeData(
                color: AppTheme.carbon,
                shape: BeveledRectangleBorder(
                  side: const BorderSide(color: AppTheme.neonCyan, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontFamily: 'ShareTechMono', color: Colors.white),
              ),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onSelected: (value) {
                switch (value) {
                  case 'GPS': _acquireLocation(); break;
                  case 'AI': _showNeuralMenu(); break;
                  case 'PDF': _exportPdf(); break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'GPS',
                  child: Row(
                    children: [
                      Icon(_latitude != null ? Icons.gps_fixed : Icons.gps_not_fixed, color: AppTheme.dangerRed, size: 20),
                      const SizedBox(width: 10),
                      Text(_latitude != null ? "TARGET_LOCKED" : "ACQUIRE_GPS"),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'AI',
                  child: Row(
                    children: [
                      Icon(Icons.psychology, color: AppTheme.neonCyan, size: 20),
                      SizedBox(width: 10),
                      Text("NEURAL_LINK"),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                const PopupMenuItem<String>(
                  value: 'PDF',
                  child: Row(
                    children: [
                      Icon(Icons.output, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text("EXFIL_DATA (PDF)"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: AppTheme.neonCyan.withOpacity(0.1), width: 1),
                right: BorderSide(color: AppTheme.neonCyan.withOpacity(0.1), width: 1),
              )
            ),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                if (_isProcessingAI) const LinearProgressIndicator(color: AppTheme.neonCyan, backgroundColor: AppTheme.carbon),

                // BARRE DE STATUS GPS
                if (_latitude != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    margin: const EdgeInsets.only(bottom: 10),
                    color: AppTheme.dangerRed.withOpacity(0.1),
                    child: Row(
                      children: [
                        const Icon(Icons.satellite_alt, size: 14, color: AppTheme.dangerRed),
                        const SizedBox(width: 8),
                        Text(
                          "LAT: ${_latitude!.toStringAsFixed(4)}  LNG: ${_longitude!.toStringAsFixed(4)}",
                          style: const TextStyle(fontFamily: 'ShareTechMono', fontSize: 12, color: AppTheme.dangerRed, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),

                // TAGS
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableTags.length,
                    itemBuilder: (context, index) {
                      final tag = _availableTags[index];
                      final isSelected = _selectedTags.contains(tag);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(tag, style: TextStyle(
                            fontFamily: 'ShareTechMono', 
                            fontSize: 12,
                            color: isSelected ? Colors.black : AppTheme.neonCyan
                          )),
                          selected: isSelected,
                          selectedColor: AppTheme.neonCyan,
                          backgroundColor: Colors.transparent,
                          shape: BeveledRectangleBorder(side: const BorderSide(color: AppTheme.neonCyan, width: 1), borderRadius: BorderRadius.circular(5)),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) { _selectedTags.add(tag); } else { _selectedTags.remove(tag); }
                              _isDirty = true;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 15),

                // TITRE (FOND TRANSPARENT)
                TextField(
                  controller: _titleController,
                  onChanged: (_) => _markDirty(),
                  cursorColor: AppTheme.dangerRed, 
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                  decoration: const InputDecoration(
                    hintText: 'HEADER_TITLE',
                    filled: false, // <--- C'est ici que la magie opère (fond transparent)
                    border: InputBorder.none, 
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white12),
                  ),
                ),
                
                Container(height: 1, width: double.infinity, color: AppTheme.neonCyan.withOpacity(0.3)),
                const SizedBox(height: 10),

                // IMAGES
                if (_evidenceImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _evidenceImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.neonCyan.withOpacity(0.5)),
                                  image: DecorationImage(image: FileImage(File(_evidenceImages[index])), fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: 0, right: 0,
                                child: GestureDetector(
                                  onTap: () { setState(() { _evidenceImages.removeAt(index); _isDirty = true; }); },
                                  child: Container(color: Colors.black87, child: const Icon(Icons.close, color: AppTheme.dangerRed, size: 20)),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // CONTENU (FOND TRANSPARENT)
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    onChanged: (_) => _markDirty(),
                    maxLines: null,
                    cursorColor: AppTheme.neonCyan,
                    cursorWidth: 5,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.holoWhite, height: 1.6), 
                    decoration: const InputDecoration(
                      hintText: 'Initiate protocol...',
                      filled: false, // <--- Fond transparent ici aussi
                      border: InputBorder.none, 
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}