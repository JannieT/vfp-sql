// ignore_for_file: public_member_api_docs

import 'package:get_it/get_it.dart';
import 'package:sales_importer/ingest/load_manager.dart';
import 'package:sales_importer/shared/services/express_service.dart';
import 'package:sales_importer/shared/services/operations_service.dart';
import 'package:sales_importer/shared/services/settings_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  final settings = await SettingsService.instance();

  locator
    ..registerSingleton<SettingsService>(settings)
    ..registerSingleton<ExpressService>(ExpressService(locator()))
    ..registerSingleton<OperationsService>(OperationsService(locator()))
    ..registerSingleton<LoadManager>(
      LoadManager(locator(), locator()),
      // dispose: (db) {
      //   db.close();
      // },
    );
}
