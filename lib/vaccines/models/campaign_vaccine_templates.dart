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

  /// Idade da criança, em meses, a partir da qual esta vacina de campanha
  /// fica disponível para ser marcada.
  final int ageMonths;

  const CampaignVaccineTemplate({required this.name, required this.ageMonths});
}

const List<CampaignVaccineTemplate> campaignVaccineTemplates = [
  CampaignVaccineTemplate(name: 'Influenza (Gripe)', ageMonths: 6),
  CampaignVaccineTemplate(name: 'Influenza (Gripe)', ageMonths: 7),
  CampaignVaccineTemplate(name: 'COVID-19', ageMonths: 6),
  CampaignVaccineTemplate(name: 'COVID-19', ageMonths: 7),
];