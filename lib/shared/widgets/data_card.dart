import 'package:flutter/material.dart';

class DataCard extends StatelessWidget {
  final Widget child;
  final String title;
  final bool isReady;
  const DataCard(
      {super.key,
      required this.child,
      required this.title,
      required this.isReady});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Opacity(
        opacity: isReady ? 1 : 0.5,
        child: Container(
          width: 250,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
