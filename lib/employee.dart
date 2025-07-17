import 'package:hive/hive.dart';
part 'employee.g.dart';

@HiveType(typeId: 1)
class Employee extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String surname;
  @HiveField(2)
  String? department;
  @HiveField(3)
  String? position;
  @HiveField(4)
  String? email;
  @HiveField(5)
  String? phone;

  Employee({
    required this.name,
    required this.surname,
    this.department,
    this.position,
    this.email,
    this.phone,
  });
} 