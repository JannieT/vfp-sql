// ["CUSCOD", "PRENAM", "CUSNAM"],
class Customer {
  final String code; // CUSCOD
  final String title; // PRENAM
  final String name; // CUSNAM

  Customer({
    required this.code,
    required this.title,
    required this.name,
  });

  @override
  String toString() {
    return 'Customer: $code, $title $name';
  }
}
