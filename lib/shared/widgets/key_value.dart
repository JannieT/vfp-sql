import 'package:flutter/material.dart';

class KeyValue extends StatelessWidget {
  final String left;
  final String right;
  const KeyValue(this.left, this.right, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left),
        const Spacer(),
        Container(
          constraints: const BoxConstraints(
            maxWidth: 160,
          ),
          child: Text(
            right,
            // '/Users/jannie/Desktop/kanok/express/dat1',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
