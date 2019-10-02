import 'package:flutter/material.dart';
import 'package:flutter_pubnub/pubnub.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _firstUserClient = PubNub(PubNubConfig(
      'pub-c-9235bd41-31e7-405c-b1bd-8130e8138c88', 'sub-c-6de4a01a-e54a-11e9-9f1b-ce77373a3518',
      secretKey: 'sec-c-MDMyMDU0ODMtZDE2Zi00NWRmLTk4YzItZDg1ODFkNzkzMTFh'));
  final _secondUserClient = PubNub(PubNubConfig(
      'pub-c-9235bd41-31e7-405c-b1bd-8130e8138c88', 'sub-c-6de4a01a-e54a-11e9-9f1b-ce77373a3518',
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
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                  FlatButton(
                      color: Colors.black12,
                      onPressed: () {
                        _firstUserClient.unsubscribe(['Channel']);
                        _secondUserClient.unsubscribe(['Channel']);
                      },
                      child: Text('Unsubscribe')),
                  FlatButton(
                      color: Colors.black12,
                      onPressed: () {
                        _firstUserClient.subscribe(['Channel', 'Channel2']);
                        _secondUserClient.subscribe(['Channel']);
                      },
                      child: Text('Subscribe')),
                  FlatButton(
                      color: Colors.black12,
                      onPressed: () {
                        _firstUserClient.publish(['Channel', 'Channel2'], {'message': 'Hello World!'});
                        //_secondUserClient.publish(['Channel'], {'message': 'Hello First User!'},
                        //   metadata: {'uuid': '127c1ab5-fc7f-4c46-8460-3207b6782007'});
                        // _firstUserClient.presence(['Channel'], {'state': 'AFK'});
                      },
                      child: Text('Send Message')),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                  FlatButton(
                      color: Colors.black12,
                      onPressed: () {
                        _firstUserClient.addChannelsToChannelGroup('Group1', ['Channel', ' Channel2']);
//                        _firstUserClient.listChannelsForChannelGroup('Group1').then((channels) {
//                          print("Channels in Group 1: $channels");
//                        });
                        //_secondUserClient.publish(['Channel'], {'message': 'Hello First User!'},
                        //   metadata: {'uuid': '127c1ab5-fc7f-4c46-8460-3207b6782007'});
                        // _firstUserClient.presence(['Channel'], {'state': 'AFK'});
                      },
                      child: Text('Channel Group')),
                ])
              ]),
            )),
      );
}
