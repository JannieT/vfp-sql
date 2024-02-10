import 'dart:convert';
import 'dart:typed_data';

import 'package:dbf_reader/dbf_reader.dart';
import 'package:enough_convert/latin.dart';
import 'package:sales_importer/env.dart';
import 'package:sales_importer/ingest/models/invoice.dart';
import 'package:sales_importer/ingest/models/customer.dart';
import 'package:sales_importer/ingest/models/invoice_items.dart';
import 'package:sales_importer/ingest/models/stock.dart';
import 'package:sales_importer/shared/services/settings_service.dart';

class ExpressService {
  late String _dataPath;
  final SettingsService service;
  final thaiCodec = const Latin11Codec(allowInvalid: true);
  final latinCodec = const Latin1Codec(allowInvalid: true);

  ExpressService(this.service) {
    setPath();
  }

  void setPath() {
    _dataPath = service.setting(Setting.expressPath) ?? '';
  }

  Future<MapEntry> getBusiestYear() async {
    // _dump(Xp.stmas);
    final db = _dbfFor(Xp.artrn);
    List<Row> rows = await db.select();
    final years = <String, int>{};
    for (var row in rows) {
      if (row.isDeleted) continue;

      final dateCol = row.get(2).value as String;
      final year = dateCol.substring(0, 4);
      years.update(year, (value) => value + 1, ifAbsent: () => 1);
    }
    final busiestYear =
        years.entries.reduce((a, b) => a.value > b.value ? a : b);
    return busiestYear;
  }

  Future<List<Stock>> getStock() async {
    final db = _dbfFor(Xp.stmas);
    final rows = await db.select();
    return rows.where(_notDeleted).map(_stockFromRow).toList();
  }

  bool _notDeleted(Row row) {
    return !row.isDeleted;
  }

  Stock _stockFromRow(Row row) {
    return Stock(
      code: _decode(row.get(0)),
      description: _decode(row.get(1)),
      type: _decode(row.get(3)),
      group: _decode(row.get(5)),
      unit: _decode(row.get(12)),
    );
  }

  Future<List<Customer>> getCustomer() async {
    final db = _dbfFor(Xp.armas);
    final rows = await db.select();
    return rows.where(_notDeleted).map(_customerFromRow).toList();
  }

  Customer _customerFromRow(Row row) {
    return Customer(
      code: _decode(row.get(0)),
      title: _decode(row.get(2)),
      name: _decode(row.get(3)),
    );
  }

  Future<List<Invoice>> getInvoice() async {
    final db = _dbfFor(Xp.artrn);
    final rows = await db.select();
    return rows.where(_notDeleted).map(_invoiceFromRow).toList();
  }

  Invoice _invoiceFromRow(Row row) {
    return Invoice(
      type: _decode(row.get(0)),
      number: _decode(row.get(1)),
      date: _date(row.get(2)),
      customer: _decode(row.get(9)),
      amount: _amount(row.get(17)),
      discount: _amount(row.get(19)),
      advance: _amount(row.get(22)),
      receive: _amount(row.get(29)),
      area: _decode(row.get(12)),
      complete: _date(row.get(33)),
      status: _decode(row.get(34)),
      user: _decode(row.get(50)),
      updated: _date(row.get(51)),
      delivery: _decode(row.get(48)),
      reverseType: _decode(row.get(5)),
    );
  }

  Future<List<InvoiceItem>> getInvoiceItems() async {
    final db = _dbfFor(Xp.stcrd);
    final rows = await db.select();
    return rows.where(_notDeleted).map(_invoiceItemFromRow).toList();
  }

  InvoiceItem _invoiceItemFromRow(Row row) {
    return InvoiceItem(
      number: _decode(row.get(2)),
      stock: _decode(row.get(0)),
      quantity: _amount(row.get(14)),
      unitPrice: _amount(row.get(17)),
      factor: _amount(row.get(16)),
      value: _amount(row.get(20)),
      unit: _decode(row.get(15)),
      free: _decode(row.get(9)),
      extendedPrice: _amount(row.get(24)),
      date: _date(row.get(4)),
      people: _decode(row.get(11)),
    );
  }

  double _amount(DataPacket col) {
    var bytes = _bytes(col);

    ByteData byteData = ByteData.view(bytes.buffer);
    double decimal = byteData.getFloat64(0, Endian.little);
    return decimal;
  }

  Uint8List _bytes(DataPacket col) {
    List<int> ints = [0, 0, 0, 0, 0, 0, 0, 0];
    final bytes = latin1.encode(col.value as String);
    for (var i = 0; i < bytes.length; i++) {
      ints[8 - bytes.length + i] = bytes[i];
    }
    return Uint8List.fromList(ints);
  }

  DateTime _date(DataPacket col) {
    late DateTime date;
    try {
      date = col.getDateTime();
    } catch (e) {
      date = DateTime(1899, 12, 30, 0, 0, 0);
    }
    return date;
  }

  String _decode(DataPacket col) {
    final value = col.value as String;
    final raw = latinCodec.encode(value.trim());
    return thaiCodec.decode(raw);
  }

  DBF _dbfFor(Xp table) => DBF(fileName: '$_dataPath/${table.fileName}');

  void dump(Xp table) {
    final db = _dbfFor(table);
    db.showStructure();
  }
}

enum Xp {
  artrn,
  stcrd,
  armas,
  stmas;

  String get fileName => '${name.toUpperCase()}.DBF';
}
