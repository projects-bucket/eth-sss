import 'package:etherwallet/components/dialog/alert.dart';
import 'package:etherwallet/components/wallet/transfer_form.dart';
import 'package:etherwallet/context/transfer/wallet_transfer_provider.dart';

import 'package:etherwallet/model/network_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'components/wallet/sssbutton.dart';
import 'package:ntcdcrypto/ntcdcrypto.dart';

import 'components/wallet/loading.dart';

class WalletTransferPage extends HookWidget {
  const WalletTransferPage({
    Key? key,
    required this.title,
    required this.network,
  }) : super(key: key);

  final String title;
  final NetworkType network;

  constructKey(String share1, String share2) {
    SSS sss = new SSS();
    var s1 = sss.combine([share1, share2], true);
    print(s1);
    return s1;
  }

  @override
  Widget build(BuildContext context) {
    final transferStore = useWalletTransfer(context);

    final qrcodeAddress = useState('');
    TextEditingController share1 = new TextEditingController();
    TextEditingController share2 = new TextEditingController();

    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: !transferStore.state.loading
                  ? () {
                      Navigator.of(context).pushNamed(
                        '/qrcode_reader',
                        arguments: (scannedAddress) {
                          qrcodeAddress.value = scannedAddress.toString();
                        },
                      );
                    }
                  : null,
            ),
        ],
      ),
      body: transferStore.state.loading
          ? const Loading()
          : TransferForm(
              address: qrcodeAddress.value,
              onSubmit: (address, amount) async {
                print(transferStore.getPrivateKey());
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Wrap(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        const SizedBox(
                          height: 8.0,
                        ),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text('Enter Key Shares')),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            decoration:
                                InputDecoration(hintText: 'Key Share 1'),
                            autofocus: true,
                            controller: share1,
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: TextField(
                            decoration:
                                InputDecoration(hintText: 'Key Share 2'),
                            autofocus: true,
                            controller: share2,
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            var pkey =
                                await constructKey(share1.text, share2.text);
                            print(pkey);
                            try {
                              if (pkey.toString() ==
                                  transferStore.getPrivateKey().toString()) {
                                Navigator.of(context).pop();
                                final success = await transferStore.transfer(
                                  network,
                                  address,
                                  amount,
                                );

                                if (success) {
                                  Navigator.popUntil(
                                      context, ModalRoute.withName('/'));
                                }
                              } else {
                                Navigator.popUntil(
                                    context, ModalRoute.withName('/'));
                                Alert(
                                    title: "Error transferring funds",
                                    text: "Invalid Key Sahres",
                                    actions: [
                                      TextButton(
                                        child: const Text('close'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ]).show(context);
                              }
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: Text('Sign Transaction'),
                        )
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}
