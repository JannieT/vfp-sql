import 'package:flutter/material.dart';
import 'package:sales_importer/config/config_screen.dart';
import 'package:sales_importer/ingest/feedback_panel.dart';
import 'package:sales_importer/ingest/load_manager.dart';
import 'package:sales_importer/ingest/source_card.dart';
import 'package:sales_importer/ingest/target_card.dart';
import 'package:sales_importer/shared/locator.dart';
import 'package:watch_it/watch_it.dart';

class LoadScreen extends StatefulWidget with WatchItStatefulWidgetMixin {
  const LoadScreen({super.key});

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  final manager = locator<LoadManager>();
  @override
  Widget build(BuildContext context) {
    final loadState = watchPropertyValue((LoadManager m) => m.loadState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Express Data Importer'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: _toolBelt(context),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SourceCard(),
              _actionItem(context, loadState),
              const TargetCard(),
            ],
          ),
          const SizedBox(height: 20),
          const Expanded(child: FeedbackPanel()),
        ],
      ),
    );
  }

  Widget _actionItem(BuildContext context, LoadState state) {
    switch (state) {
      case LoadState.loading:
      case LoadState.action:
        return CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primaryContainer,
        );
      case LoadState.ready:
        return IconButton(
          onPressed: () async {
            await manager.ingest();
          },
          icon: const ActionIcon(Icons.arrow_right_alt),
        );
      case LoadState.error:
        return const ActionIcon(Icons.error);
      case LoadState.done:
        return const ActionIcon(Icons.check_circle);
      default:
        return const ActionIcon(Icons.error);
    }
  }

  List<Widget> _toolBelt(BuildContext context) {
    final tools = <Widget>[
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () async {
          await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ConfigScreen()));
          if (!mounted) return;
          await manager.init();
        },
      ),
      const SizedBox(width: 10),
    ];

    return tools
        .map((e) => Focus(
            descendantsAreFocusable: false, canRequestFocus: false, child: e))
        .toList();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await manager.init();
    });
  }
}

class ActionIcon extends StatelessWidget {
  final IconData icon;

  const ActionIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 32.0,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
