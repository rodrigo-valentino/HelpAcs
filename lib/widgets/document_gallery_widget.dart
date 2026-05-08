import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 📂 GALERIA DE DOCUMENTOS / IMAGENS
///
/// Widget genérico para exibir, adicionar e remover imagens locais.
/// - Totalmente standalone (sem AppSpacing, AppRadius, etc)
/// - Compatível com armazenamento local por path
class DocumentGalleryWidget extends StatefulWidget {
  final String title;
  final List<String> imagePaths;
  final ValueChanged<String> onAddImage;
  final ValueChanged<int> onRemoveImage;
  final int maxImages;

  const DocumentGalleryWidget({
    super.key,
    required this.title,
    required this.imagePaths,
    required this.onAddImage,
    required this.onRemoveImage,
    this.maxImages = 2,
  });

  @override
  State<DocumentGalleryWidget> createState() =>
      _DocumentGalleryWidgetState();
}

class _DocumentGalleryWidgetState extends State<DocumentGalleryWidget> {
  final ImagePicker _picker = ImagePicker();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // IMAGE PICK
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Future<void> _pickImage(ImageSource source) async {
    if (widget.imagePaths.length >= widget.maxImages) {
      _showSnack('Máximo de ${widget.maxImages} imagens');
      return;
    }

    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (file != null) {
      widget.onAddImage(file.path);
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // UI HELPERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover imagem'),
        content: const Text('Deseja remover esta imagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              widget.onRemoveImage(index);
              Navigator.pop(context);
            },
            child: const Text(
              'Remover',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _openImage(String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(File(path)),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BUILD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(
          title: widget.title,
          canAdd: widget.imagePaths.length < widget.maxImages,
          onAdd: _showAddOptions,
        ),
        const SizedBox(height: 12),
        if (widget.imagePaths.isEmpty)
          const _EmptyState()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.imagePaths.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final path = widget.imagePaths[index];

              return GestureDetector(
                onTap: () => _openImage(path),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () => _confirmDelete(index),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMPONENTES AUXILIARES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _Header extends StatelessWidget {
  final String title;
  final bool canAdd;
  final VoidCallback onAdd;

  const _Header({
    required this.title,
    required this.canAdd,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (canAdd)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAdd,
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: const [
          Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Nenhuma imagem adicionada',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
