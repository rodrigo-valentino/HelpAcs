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