import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_input_decoration.dart';
import '../providers/campaign_controller.dart';

class CampaignVaccineDialog extends ConsumerStatefulWidget {
  final int childKey;

  const CampaignVaccineDialog({super.key, required this.childKey});

  @override
  ConsumerState<CampaignVaccineDialog> createState() => _CampaignVaccineDialogState();
}

class _CampaignVaccineDialogState extends ConsumerState<CampaignVaccineDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  int _selectedYear = DateTime.now().year;

  // Sugestões Iniciais
  static const List<String> _suggestions = [
    'Influenza (Gripe)',
    'COVID-19',
    'Poliomielite (Campanha)',
    'Sarampo (Campanha)',
  ];

  // Gera os anos para o dropdown (ex: de 2020 até o ano atual + 1)
  List<int> get _years {
    final current = DateTime.now().year;
    return List<int>.generate(10, (index) => current + 1 - index);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nova Vacina de Campanha', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Nome da vacina *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              
              // AUTOCOMPLETE ELEGANTE
              RawAutocomplete<String>(
                textEditingController: _nameCtrl,
                focusNode: FocusNode(),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _suggestions; // Mostra todas ao clicar
                  }
                  return _suggestions.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: AppInputDecoration.outlined(
                      hint: 'Digite ou selecione uma vacina',
                      prefixIcon: Icons.vaccines,
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 96, // Ajuste para caber no dialog
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              title: Text(option),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              const Text('Ano da campanha *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _selectedYear,
                decoration: AppInputDecoration.outlined(hint: '', prefixIcon: Icons.calendar_today),
                items: _years.map((year) => DropdownMenuItem(value: year, child: Text(year.toString()))).toList(),
                onChanged: (val) => setState(() => _selectedYear = val!),
              ),

              const SizedBox(height: 16),

              // Alerta Visual de Segurança
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vacinas de campanha não contam como atrasadas no calendário oficial.',
                        style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await ref.read(campaignControllerProvider).addCampaignVaccine(
                            childKey: widget.childKey,
                            vaccineName: _nameCtrl.text.trim(),
                            year: _selectedYear,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Adicionar'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}