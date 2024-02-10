// DOCNUM
// STKCOD
// TRNQTY
// UNITPR
// TFACTOR
// TRNVAL
// TQUCOD
// FREE
// XUNITPR
// DOCDAT
// PEOPLE

class InvoiceItem {
  final String number;
  final String stock;
  final double quantity;
  final double unitPrice;
  final double factor;
  final double value;
  final String unit;
  final String free;
  final double extendedPrice;
  final DateTime date;
  final String people;

  InvoiceItem({
    required this.number,
    required this.stock,
    required this.quantity,
    required this.unitPrice,
    required this.factor,
    required this.value,
    required this.unit,
    required this.free,
    required this.extendedPrice,
    required this.date,
    required this.people,
  });

  @override
  String toString() {
    return 'InvoiceItem{number: $number, stock: $stock, quantity: $quantity, unitPrice: $unitPrice, factor: $factor, value: $value, unit: $unit, free: $free, extendedPrice: $extendedPrice, date: $date, people: $people}';
  }
}
