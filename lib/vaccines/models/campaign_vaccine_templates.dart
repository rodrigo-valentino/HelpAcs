/// Vacinas de campanha PADRÃO — aparecem automaticamente no tab de
/// Campanhas de cada paciente, como um toggle (marcar se tomou ou não),
/// calculadas pela idade da criança em meses.
///
/// Diferente do Calendário Vacinal oficial (que agora é editável pelo
/// usuário via CalendarManagementPage), esta lista é fixa no código de
/// propósito — são poucos itens e mudam raramente. Se no futuro isso
/// também precisar ser editável pelo usuário, dá para promover para o
/// mesmo padrão de catálogo (VaccineGroupModel/VaccineDefinitionModel)
/// usado no calendário oficial.
class CampaignVaccineTemplate {
  final String name;
  final int? ageMonths;
  final int? ageYears;

  const CampaignVaccineTemplate({
    required this.name,
    this.ageMonths,
    this.ageYears,
  });

  int get totalMonths => ageMonths ?? (ageYears! * 12);
}

const List<CampaignVaccineTemplate> campaignVaccineTemplates = [
  CampaignVaccineTemplate(name: 'Influenza (Gripe)', ageMonths: 6),
  CampaignVaccineTemplate(name: 'Influenza (Gripe)', ageMonths: 7),
  CampaignVaccineTemplate(name: 'COVID-19', ageMonths: 6),
  CampaignVaccineTemplate(name: 'COVID-19', ageMonths: 7),

  CampaignVaccineTemplate(name: 'DENGUE 1ª DOSE', ageYears: 10),
  CampaignVaccineTemplate(name: 'DENGUE 2ª DOSE', ageYears: 10),
];