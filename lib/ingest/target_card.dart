import 'package:flutter/material.dart';
import 'package:sales_importer/ingest/load_manager.dart';
import 'package:sales_importer/shared/widgets/data_card.dart';
import 'package:sales_importer/shared/widgets/key_value.dart';
import 'package:watch_it/watch_it.dart';

class TargetCard extends StatelessWidget with WatchItMixin {
  const TargetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isReady = watchPropertyValue((LoadManager m) => m.targetIsReady);
    final busiestYear = watchPropertyValue((LoadManager m) => m.busiestYear);
    final historyCount = watchPropertyValue((LoadManager m) => m.historyCount);
    return DataCard(
      isReady: isReady,
      title: 'Kanok Data',
      child: Column(
        children: [
          KeyValue("Year", busiestYear),
          KeyValue("Records", historyCount.toString()),
        ],
      ),
    );
  }
}
