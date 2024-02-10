//     "RECTYP",
//     "DOCNUM",
//     "DOCDAT",
//     "CUSCOD",
//     "AMOUNT",
//     "DISCAMT",
//     "ADVAMT",
//     "RCVAMT",
//     "AREACOD",
//     "CMPLDAT",
//     "DOCSTAT",
//     "USERID",
//     "CHGDAT",
//     "DLVBY",
//     "CNTYP"

class Invoice {
  final String type;
  final String number;
  final DateTime date;
  final String customer;
  final double amount;
  final double discount;
  final double advance;
  final double receive;
  final String area;
  final DateTime complete;
  final String status;
  final String user;
  final DateTime updated;
  final String delivery;
  final String reverseType;

  Invoice({
    required this.type,
    required this.number,
    required this.date,
    required this.customer,
    required this.amount,
    required this.discount,
    required this.advance,
    required this.receive,
    required this.area,
    required this.complete,
    required this.status,
    required this.user,
    required this.updated,
    required this.delivery,
    required this.reverseType,
  });

  @override
  String toString() {
    return 'Invoice{type: $type, number: $number, date: $date, customer: $customer, amount: $amount, discount: $discount, advance: $advance, receive: $receive, area: $area, complete: $complete, status: $status, user: $user, updated: $updated, delivery: $delivery, reverseType: $reverseType}';
  }
}
