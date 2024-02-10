import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sales_importer/shared/services/express_service.dart';
import 'package:sales_importer/shared/services/operations_service.dart';

class LoadManager extends ChangeNotifier {
  final _messenger = StreamController<String>();
  Stream<String> get feedback => _messenger.stream;

  final ExpressService _salesService;
  final OperationsService _operationsService;
  LoadManager(this._salesService, this._operationsService);

  bool _sourceIsReady = false;
  bool get sourceIsReady => _sourceIsReady;

  bool _targetIsReady = false;
  bool get targetIsReady => _targetIsReady;

  LoadState _loadState = LoadState.loading;
  LoadState get loadState => _loadState;

  String _busiestYear = '';
  String get busiestYear => _busiestYear;

  int _historyCount = 0;
  int get historyCount => _historyCount;

  int _salesCount = 0;
  int get salesCount => _salesCount;

  Future<void> ingest() async {
    _loadState = LoadState.action;
    notifyListeners();
    try {
      await _doCustomers(); // ARMAS
      await _doStock(); // STMAS
      await _doInvoices(); // ARTRN
      await _doInvoiceItems(); // STCRD

      _loadState = LoadState.done;
    } catch (e, s) {
      log(s.toString());
      _messenger.add('Error: $e');
      _loadState = LoadState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> _doCustomers() async {
    final customers = await _salesService.getCustomer();
    final result = await _operationsService.ingestCustomers(customers);
    _messenger.add('Updated ${result.$1} customers, added ${result.$2}');
  }

  Future<void> _doStock() async {
    final stock = await _salesService.getStock();
    final result = await _operationsService.ingestProducts(stock);
    _messenger.add('Updated ${result.$1} products, added ${result.$2}');
  }

  Future<void> _doInvoices() async {
    final invoices = await _salesService.getInvoice();
    final invoicesForYear = invoices
        .where((inv) => inv.date.year.toString() == _busiestYear)
        .toList();
    final replaced =
        await _operationsService.ingestInvoices(invoicesForYear, _busiestYear);
    _messenger.add(
        'Replaced $replaced invoices for $_busiestYear with ${invoicesForYear.length} new ones');
    _historyCount = invoicesForYear.length;
    notifyListeners();
  }

  Future<void> _doInvoiceItems() async {
    final items = await _salesService.getInvoiceItems();
    final itemsForYear = items
        .where((item) => item.date.year.toString() == _busiestYear)
        .toList();
    final replaced =
        await _operationsService.ingestInvoiceItems(itemsForYear, _busiestYear);
    _messenger.add(
        'Replaced $replaced invoice items for $_busiestYear with ${itemsForYear.length} new ones');
  }

  Future<void> init() async {
    _loadState = LoadState.loading;
    _sourceIsReady = false;
    _targetIsReady = false;
    _messenger.add('clear');
    _salesService.setPath();
    notifyListeners();

    try {
      final result = await _salesService.getBusiestYear();
      _busiestYear = result.key;
      _salesCount = result.value;
      _sourceIsReady = true;
    } catch (e) {
      _sourceIsReady = false;
      _loadState = LoadState.error;
      _messenger.add('Error: $e');
      return;
    } finally {
      notifyListeners();
    }

    try {
      await _operationsService.connect();
      _targetIsReady = _operationsService.isConnected;
      _historyCount = await _operationsService.count(_busiestYear);
      _loadState = LoadState.ready;
    } catch (e) {
      _targetIsReady = false;
      _loadState = LoadState.error;
      _messenger.add('Error: $e');
      return;
    } finally {
      notifyListeners();
    }

    _messenger.add('Express records for $_busiestYear is ready for import');
  }
}

enum LoadState { loading, ready, action, done, error }
