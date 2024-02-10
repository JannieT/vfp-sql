class Stock {
  final String code; // STKCOD
  final String description; // STKDES
  final String type; // STKTYP
  final String group; // STKGRP
  final String unit; // QUCOD

  Stock({
    required this.code,
    required this.description,
    required this.type,
    required this.group,
    required this.unit,
  });

  @override
  String toString() {
    return 'Stock{code: $code, description: $description, type: $type, group: $group, unit: $unit}';
  }
}
