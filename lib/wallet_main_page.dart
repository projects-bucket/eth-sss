import 'package:etherwallet/components/wallet/balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'components/dialog/alert.dart';
import 'components/menu/main_menu.dart';
import 'components/wallet/change_network.dart';
import 'context/wallet/wallet_provider.dart';
import 'components/wallet/sssbutton.dart';
import 'package:ntcdcrypto/ntcdcrypto.dart';

class WalletMainPage extends HookWidget {
  const WalletMainPage(this.title, {Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final store = useWallet(context);
    final address = store.state.address;
    final network = store.state.network;
    TextEditingController share1 = new TextEditingController();
    final share2 = TextEditingController();

    constructKey(String share1, String share2) {
      SSS sss = new SSS();
      var s1 = sss.combine([share1, share2], true);
      print(s1);
      return s1;
    }

    useEffect(() {
      store.initialise();
    }, []);

    useEffect(
      () => store.listenTransfers(address, network),
      [address, network],
    );

    return Scaffold(
      drawer: MainMenu(
        network: network,
        address: address,
        onReset: () => Alert(
            title: 'Warning',
            text:
                'Without your seed phrase or private key you cannot restore your wallet balance',
            actions: [
              TextButton(
                child: const Text('cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('reset'),
                onPressed: () async {
                  await store.resetWallet();
                  Navigator.popAndPushNamed(context, '/');
                },
              )
            ]).show(context),
        onRevealKey: () => Alert(
            title: 'Private key',
            text:
                'WARNING: In production environment the private key should be protected with password.\r\n\r\n${store.getPrivateKey() ?? "-"}',
            actions: [
              TextButton(
                child: const Text('close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('copy and close'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: store.getPrivateKey()));
                  Navigator.of(context).pop();
                },
              ),
            ]).show(context),
      ),
      appBar: AppBar(
        title: Text(title),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: !store.state.loading
                  ? () async {
                      await store.refreshBalance();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Balance updated'),
                        duration: Duration(milliseconds: 800),
                      ));
                    }
                  : null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed('/transfer', arguments: store.state.network);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /*ChangeNetwork(
              onChange: store.changeNetwork,
              currentValue: store.state.network,
              loading: store.state.loading,
            ),*/

            Balance(
              address: store.state.address,
              ethBalance: store.state.ethBalance,
              tokenBalance: store.state.tokenBalance,
              symbol: network.config.symbol,
            ),
            const SizedBox(height: 10),
            Container(
              child: Text(
                  "Use below buttons to Implement Secret Sharing Algorithm"),
            ),
            const SizedBox(height: 10),
            sssbutton(pkey: store.getPrivateKey()),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
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
                                var keyv = await constructKey(
                                    share1.text, share2.text);
                                Alert(
                                    title: 'Your Private key',
                                    text:
                                        'WARNING: Keep It Safe.\r\n\r\n${keyv}',
                                    actions: [
                                      TextButton(
                                        child: const Text('close'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      TextButton(
                                        child: const Text('copy and close'),
                                        onPressed: () {
                                          Clipboard.setData(
                                              ClipboardData(text: keyv));
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ]).show(context);
                              },
                              child: Text('Get Key'))
                        ],
                      );
                    },
                  );
                },
                child: Text("Reconstruct Key"))
          ],
        ),
      ),
    );
  }
}
