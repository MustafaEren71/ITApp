import 'package:hive/hive.dart';
part 'assignment.g.dart';

@HiveType(typeId: 2)
class Assignment extends HiveObject {
  @HiveField(0)
  String employeeName;
  @HiveField(1)
  String productName;
  @HiveField(2)
  int quantity;
  @HiveField(3)
  String date;
  @HiveField(4)
  String? shelf;
  @HiveField(5)
  String? unit;

  Assignment({
    required this.employeeName,
    required this.productName,
    required this.quantity,
    required this.date,
    this.shelf,
    this.unit,
  });
} 