import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ionicons_named/ionicons_named.dart';

class Distance extends StatelessWidget {
  const Distance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ionicons['location_outline'], color: Colors.black54, size: 14),
        Text("Accra", style: TextStyle(color: Colors.black54)),
        SizedBox(width: 3),
        ...List.generate(18, (index) {
          return Expanded(
            child: Container(
              height: 2,
              color: index.isOdd ? Colors.transparent : Colors.black54,
            ),
          );
        }),
        SizedBox(width: 3),
        Icon(
          ionicons['location_outline'],
          color: Theme.of(context).primaryColor,
          size: 14,
        ),
        SizedBox(width: 2),
        Text("Kumasi", style: TextStyle(color: Theme.of(context).primaryColor)),
      ],
    );
  }
}
