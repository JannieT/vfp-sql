import 'package:flutter/material.dart';
import 'package:sales_importer/ingest/load_manager.dart';
import 'package:watch_it/watch_it.dart';

class FeedbackPanel extends StatefulWidget with WatchItStatefulWidgetMixin {
  const FeedbackPanel({super.key});

  @override
  State<FeedbackPanel> createState() => _FeedbackPanelState();
}

class _FeedbackPanelState extends State<FeedbackPanel> {
  final messages = <String>[];

  @override
  Widget build(BuildContext context) {
    registerStreamHandler<LoadManager, String>(
      select: (x) => x.feedback,
      handler: (context, x, cancel) {
        if (x.data == null) return;
        if (x.data == 'clear') {
          messages.clear();
          setState(() {});
          return;
        }
        messages.add(x.data!);
        setState(() {});
      },
    );

    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 4.0),
          child: Text(messages[index],
              style: Theme.of(context).textTheme.bodyLarge),
        );
      },
    );
  }
}
