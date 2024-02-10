import 'dart:developer';

import 'package:mysql_client/mysql_client.dart';
import 'package:sales_importer/env.dart';
import 'package:sales_importer/ingest/models/customer.dart';
import 'package:sales_importer/ingest/models/invoice.dart';
import 'package:sales_importer/ingest/models/invoice_items.dart';
import 'package:sales_importer/ingest/models/stock.dart';
import 'package:sales_importer/shared/services/settings_service.dart';

class OperationsService {
  late SettingsService config;
  bool get isConnected => _db?.connected ?? false;
  MySQLConnection? _db;

  OperationsService(this.config);

  Future<void> connect() async {
    _db = await MySQLConnection.createConnection(
      host: config.setting(Setting.mysqlHost),
      port: int.tryParse(config.setting(Setting.mysqlPort) ?? '3306') ?? 3306,
      userName: config.setting(Setting.mysqlUser) ?? 'root',
      password: config.setting(Setting.mysqlPassword) ?? 'password',
      databaseName:
          config.setting(Setting.mysqlDatabase) ?? 'operational', // optional
    );

// actually connect to database
    await _db!.connect();
  }

  Future<List<String>> _getIndex(String table, String field) async {
    // no user input edge attack vector here. Relax, Mr. Bobby Tables
    var result = await _db!
        .execute("SELECT TRIM($field) as id FROM $table ORDER BY $field");

    final index = result.rows
        .map<String>((row) => row.typedColAt<String>(0) ?? '')
        .toList();
    return index;
  }

  Future<int> count(String year) async {
    var result = await _db!.execute(
      '''          
    SELECT count(*) AS total, DATE_FORMAT(DOCDAT, "%Y") AS yr
    FROM history_artrn
   	WHERE DATE_FORMAT(DOCDAT, "%Y") = :year
    GROUP BY DATE_FORMAT(DOCDAT, "%Y")
''',
      {"year": year},
    );
    return result.rows.first.typedColAt<int>(0) ?? 0;
  }

  Future<(int, int)> ingestProducts(List<Stock> stock) async {
    final index = await _getIndex("history_stmas", "STKCOD");
    final insertStatement = await _db!.prepare(
      "INSERT INTO history_stmas (STKCOD, STKDES, STKTYP, STKGRP, QUCOD) VALUES (?,?,?,?,?)",
    );
    final updateStatement = await _db!.prepare(
      "UPDATE history_stmas SET STKDES = ? WHERE STKCOD = ?",
    );
    int updated = 0;
    int inserted = 0;
    for (var fresh in stock) {
      if (index.contains(fresh.code)) {
        await updateStatement.execute([fresh.description, fresh.code]);
        updated++;
      } else {
        await insertStatement.execute([
          fresh.code,
          fresh.description,
          fresh.type,
          fresh.group,
          fresh.unit
        ]);
        inserted++;
      }
    }
    return (updated, inserted);
  }

  Future<(int, int)> ingestCustomers(List<Customer> customers) async {
    final index = await _getIndex("history_armas", "CUSCOD");
    final insertStatement = await _db!.prepare(
      "INSERT INTO history_armas (CUSCOD, PRENAM, CUSNAM) VALUES (?,?,?)",
    );
    final updateStatement = await _db!.prepare(
      "UPDATE history_armas SET CUSNAM = ?, PRENAM = ? WHERE CUSCOD = ?",
    );
    int updated = 0;
    int inserted = 0;
    for (var fresh in customers) {
      if (index.contains(fresh.code)) {
        await updateStatement.execute([fresh.name, fresh.title, fresh.code]);
        updated++;
      } else {
        await insertStatement.execute([
          fresh.code,
          fresh.title,
          fresh.name,
        ]);
        inserted++;
      }
    }
    return (updated, inserted);
  }

  Future<int> ingestInvoices(List<Invoice> invoices, String year) async {
    int replacedRowCount = 0;
    await _db!.transactional((conn) async {
      final result = await conn.execute(
          "DELETE FROM history_artrn WHERE DATE_FORMAT(DOCDAT, '%Y') = :year",
          {"year": year});

      replacedRowCount = result.affectedRows.toInt();
      final insertStatement = await conn.prepare(
        "INSERT INTO history_artrn (RECTYP, DOCNUM, DOCDAT, CUSCOD, AMOUNT, DISCAMT, ADVAMT, RCVAMT, AREACOD, CMPLDAT, DOCSTAT, USERID, CHGDAT, DLVBY, CNTYP) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
// (21064, '3', 'IV0304688', '2003-01-07 00:00:00', 'AA0015', 3300.00, 0.00, 0.00, 3300.00, 'หน', '2003-01-29 00:00:00', 'N', 'BIT9', '2003-11-13 00:00:00', '09', '');",
      );
      for (var fresh in invoices) {
        await insertStatement.execute([
          fresh.type,
          fresh.number,
          fresh.date,
          fresh.customer,
          fresh.amount,
          fresh.discount,
          fresh.advance,
          fresh.receive,
          fresh.area,
          fresh.complete,
          fresh.status,
          fresh.user,
          fresh.updated,
          fresh.delivery,
          fresh.reverseType
        ]);
      }
    });
    return replacedRowCount;
  }

  Future<int> ingestInvoiceItems(
    List<InvoiceItem> itemsForYear,
    String year,
  ) async {
    int replacedRowCount = 0;
    await _db!.transactional((conn) async {
      // delete the existing rows
      final result = await conn.execute(
          "DELETE FROM history_stcrd WHERE DATE_FORMAT(DOCDAT, '%Y') = :year",
          {"year": year});
      replacedRowCount = result.affectedRows.toInt();

      // add fresh rows
      final insertStatement = await conn.prepare(
        "INSERT INTO history_stcrd (DOCNUM, STKCOD, TRNQTY, UNITPR, TFACTOR, TRNVAL, TQUCOD, FREE, XUNITPR, DOCDAT, PEOPLE) VALUES (?,?,?,?,?,?,?,?,?,?,?)",
      );

      for (var fresh in itemsForYear) {
        try {
          await insertStatement.execute([
            fresh.number,
            fresh.stock,
            fresh.quantity.toInt(),
            fresh.unitPrice,
            fresh.factor,
            fresh.value,
            fresh.unit,
            fresh.free,
            fresh.extendedPrice,
            fresh.date,
            fresh.people,
          ]);
        } catch (e) {
          // swallow individual row anomalies
          log('Error: $fresh');
        }
      }
    });

    return replacedRowCount;
  }
}
