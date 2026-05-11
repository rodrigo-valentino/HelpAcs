import 'package:hive/hive.dart';

part 'vaccine_record_model.g.dart';

@HiveType(typeId: 3) 
class VaccineRecord {
  @HiveField(0)
  String name; 

  @HiveField(1)
  int doseNumber; 

  @HiveField(2)
  bool applied; 

  @HiveField(3)
  bool isCustom; 

  @HiveField(4)
  String? observation;

  @HiveField(5)
  String group; 

  VaccineRecord({
    required this.name,
    required this.doseNumber,
    this.applied = false,
    this.isCustom = false,
    this.observation,
    required this.group,
  });
}