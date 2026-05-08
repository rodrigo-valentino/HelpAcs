import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vaccination_controller.dart';

class CustomVaccineDialog extends ConsumerStatefulWidget {
  final dynamic childKey; // A chave do Hive para identificar a criança
  final String groupName; // O grupo etário (ex: "2 meses") onde será adicionada

  const CustomVaccineDialog({
    super.key,
    required this.childKey,
    required this.groupName,
  });

  @override
  ConsumerState<CustomVaccineDialog> createState() => _CustomVaccineDialogState();
}

class _CustomVaccineDialogState extends ConsumerState<CustomVaccineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Chama o controller para adicionar a vacina
      ref.read(vaccinationControllerProvider(widget.childKey).notifier).addCustomVaccine(
        groupName: widget.groupName,
        vaccineName: _nameCtrl.text.trim(),
        observation: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      );
      
      Navigator.of(context).pop(); // Fecha o modal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do Modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Adicionar Vacina Personalizada',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Campo: Nome da Vacina (Obrigatório)
              const Text('Nome da Vacina *', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF34495E))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Ex: Influenza, COVID-19',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // Campo: Observação (Opcional)
              const Text('Observação', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF34495E))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _obsCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Informações adicionais sobre a vacina',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300)
                      )
                    ),
                    child: const Text('Cancelar', style: TextStyle(color: Colors.black87)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Utilize a sua AppColors.primary
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Adicionar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}