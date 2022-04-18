import 'package:flutter/material.dart';
import 'package:ntcdcrypto/ntcdcrypto.dart';

class sssbutton extends StatelessWidget {
  const sssbutton({Key? key, required this.pkey}) : super(key: key);
  final pkey;

  sssa() async {
    SSS sss = new SSS();
    String keyval = pkey.toString();
    List<String> arr = sss.create(2, 3, keyval, true);
    print(arr);
    return arr;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          var res = await sssa();
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Wrap(
                children: [
                  for (var i in res)
                    ListTile(
                      leading: Text('Share' + res.indexOf(i).toString()),
                      title: Text(i.toString()),
                    ),
                ],
              );
            },
          );
        },
        child: Text("Secret Share"));
  }
}
