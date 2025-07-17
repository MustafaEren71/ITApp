import 'package:hive/hive.dart';
part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String brand;
  @HiveField(3)
  String type;
  @HiveField(4)
  int stock;
  @HiveField(5)
  int received;
  @HiveField(6)
  String date;
  @HiveField(7)
  String? shelf;
  @HiveField(8)
  String? unit;
  @HiveField(9)
  String? desc;
  @HiveField(10)
  bool isAssigned;
  @HiveField(11)
  String? assignedTo;
  String? imei;
  String? serialNo;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.stock,
    required this.received,
    required this.date,
    this.shelf,
    this.unit,
    this.desc,
    this.isAssigned = false,
    this.assignedTo,
    this.imei,
    this.serialNo,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    brand: json['brand'] as String,
    type: json['type'] as String,
    stock: json['stock'] as int,
    received: json['received'] as int,
    date: json['date'] as String,
    shelf: json['shelf'] as String?,
    unit: json['unit'] as String?,
    desc: json['desc'] as String?,
    isAssigned: json['isAssigned'] as bool,
    assignedTo: json['assignedTo'] as String?,
    imei: json['imei'] as String?,
    serialNo: json['serialNo'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'type': type,
    'stock': stock,
    'received': received,
    'date': date,
    'shelf': shelf,
    'unit': unit,
    'desc': desc,
    'isAssigned': isAssigned,
    'assignedTo': assignedTo,
    'imei': imei,
    'serialNo': serialNo,
  };
} 