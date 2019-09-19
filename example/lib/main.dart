import 'package:flutter/material.dart';
import 'package:flutter_pubnub/pubnub.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _firstUserClient = PubNub(PubNubConfig('first_user_publish_key', 'first_user_subscribe_key'));
  final _secondUserClient = PubNub(PubNubConfig('second_user_publish_key', 'second_user_subscribe_key',
      presenceTimeout: 120,
      uuid: '127c1ab5-fc7f-4c46-8460-3207b6782007',
      filter: 'uuid != "127c1ab5-fc7f-4c46-8460-3207b6782007"'));

  @override
  void initState() {
    super.initState();
    _firstUserClient.uuid().then((uuid) => print('UUID1: $uuid'));
    _secondUserClient.uuid().then((uuid) => print('UUID2: $uuid'));
    _firstUserClient.onStatusReceived.listen((status) => print('Status:${status.toString()}'));
    _firstUserClient.onPresenceReceived.listen((presence) => print('Presence:${presence.toString()}'));
    _firstUserClient.onMessageReceived.listen((message) => print('Message:$message'));
    _firstUserClient.onErrorReceived.listen((error) => print('Error:$error'));
  }

  @override
  void dispose() {
    print('Unsubscribe all');
    _firstUserClient.unsubscribeAll();
    _secondUserClient.unsubscribeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('PubNub'),
          ),
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                FlatButton(
                    color: Colors.black12,
                    onPressed: () {
                      _firstUserClient.unsubscribe('Channel');
                      _secondUserClient.unsubscribe('Channel');
                    },
                    child: Text('Unsubscribe')),
                FlatButton(
                    color: Colors.black12,
                    onPressed: () {
                      _firstUserClient.subscribe(['Channel']);
                      _secondUserClient.subscribe(['Channel']);
                    },
                    child: Text('Subscribe')),
                FlatButton(
                    color: Colors.black12,
                    onPressed: () {
                      _firstUserClient.publish('Channel', {'message': 'Hello World!'});
                      _secondUserClient.publish('Channel', {'message': 'Hello First User!'},
                          metadata: {'uuid': '127c1ab5-fc7f-4c46-8460-3207b6782007'});
                      _firstUserClient.presence('Channel', {'state': 'AFK'});
                    },
                    child: Text('Send Message'))
              ])
            ],
          )),
        ),
      );
}
