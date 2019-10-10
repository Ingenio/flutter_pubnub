import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
      uuid: 'a0a80f2d-b48d-460c-b3bd-a244a877df1f'));
  final _secondUserClient = PubNub(PubNubConfig(
      'pub-c-9235bd41-31e7-405c-b1bd-8130e8138c88', 'sub-c-6de4a01a-e54a-11e9-9f1b-ce77373a3518',
      presenceTimeout: 120,
      uuid: '127c1ab5-fc7f-4c46-8460-3207b6782007',
      filter: 'uuid != "127c1ab5-fc7f-4c46-8460-3207b6782007"'));

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  @override
  void initState() {
    super.initState();
    _firstUserClient.uuid().then((uuid) {
      print('UUID1: $uuid');
      sendEvent('UUID', uuid);
    });
    _secondUserClient.uuid().then((uuid) => print('UUID2: $uuid'));
    _firstUserClient.onStatusReceived.listen((status) {
      print('Status:${status.toString()}');
      sendEvent('STATUS', status.toString());
    });
    _firstUserClient.onPresenceReceived.listen((presence) {
      print('Presence:${presence.toString()}');
      sendEvent('PRESENCE', presence.toString());
    });
    _firstUserClient.onMessageReceived.listen((message) {
      print('Message:$message');
      sendEvent('MESSAGE', message.toString());
    });

    _firstUserClient.onErrorReceived.listen((error) {
      print('Error:$error');
      sendEvent('ERROR', error.toString());
    });

    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        sendEvent('PUSH MESSAGE', message.toString());
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future sendEvent(String eventName, String message) async {
    int _end = message.length > 70 ? 70 : message.length - 1;
    await _analytics.logEvent(
      name: eventName,
      parameters: <String, dynamic>{
        'message': message.substring(0, _end),
      },
    );
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
          body: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[Text('Pub/Sub/Publish')])),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
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
                    _firstUserClient.subscribe(['Channel', 'Channel-pndebug']);
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
            Padding(
                padding: EdgeInsets.all(
                  8.0,
                ),
                child: Divider(
                  height: 1,
                  color: Colors.black,
                )),
            Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[Text('Channel Group')])),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
              FlatButton(
                  color: Colors.black12,
                  onPressed: () {
                    _firstUserClient.addChannelsToChannelGroup('Group1', ['Channel', 'Channel2']);
                  },
                  child: Text('Add')),
              FlatButton(
                  color: Colors.black12,
                  onPressed: () {
                    _firstUserClient.listChannelsForChannelGroup('Group1').then((channels) {
                      print("Channels in Group 1: $channels");
                    });
                  },
                  child: Text('List')),
              FlatButton(
                  color: Colors.black12,
                  onPressed: () {
                    _firstUserClient.removeChannelsFromChannelGroup('Group1', ['Channel']).then((void arg) {
                      _firstUserClient.listChannelsForChannelGroup('Group1').then((channels) {
                        print("Channels in Group 1 after deletion: $channels");
                      });
                    });
                  },
                  child: Text('Remove')),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
              FlatButton(
                  color: Colors.black12,
                  onPressed: () {
                    _firstUserClient.deleteChannelGroup('Group1');
                  },
                  child: Text('Delete')),
              FlatButton(
                  color: Colors.black12,
                  onPressed: () {
                    _firstUserClient.subscribeToChannelGroups(['Group1']);
                  },
                  child: Text('Subscribe')),
              FlatButton(
                  color: Colors.black12,
                  onPressed: () {
                    _firstUserClient.unsubscribeFromChannelGroups(['Group1']);
                  },
                  child: Text('Unsubscribe')),
            ]),
            Padding(
                padding: EdgeInsets.all(
                  8.0,
                ),
                child: Divider(
                  height: 1,
                  color: Colors.black,
                )),
            Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[Text('History')])),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
              FlatButton(
                  color: Colors.black12,
                  onPressed: () {
                    _firstUserClient.history('Channel', 1).then((items) {
                      if (items != null && items.isNotEmpty) {
                        print("Last Item: $items");
                      } else {
                        print('No items');
                      }
                    });
                  },
                  child: Text('Last')),
            ]),
            Padding(
                padding: EdgeInsets.all(
                  8.0,
                ),
                child: Divider(
                  height: 1,
                  color: Colors.black,
                )),
            Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[Text('Push Notifications')])),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
              FlatButton(
                  color: Colors.black12,
                  onPressed: () {
                    _firebaseMessaging.getToken().then((token) {
                      print("Token: $token");
                      _firstUserClient.addPushNotificationsOnChannels(PushType.FCM, token, ['Channel']);
                    });
                  },
                  child: Text('Add')),
              FlatButton(
                  color: Colors.black12,
                  onPressed: () {
                    _firebaseMessaging.getToken().then((token) {
                      print("Token: $token");
                      _firstUserClient.listPushNotificationChannels(PushType.FCM, token).then((channels) {
                        print("Push Notes Channels: $channels");
                      });
                    });
                  },
                  child: Text('List')),
              FlatButton(
                  color: Colors.black12,
                  onPressed: () {
                    _firebaseMessaging.getToken().then((token) {
                      print("Token: $token");
                      _firstUserClient.removePushNotificationsFromChannels(PushType.FCM, token, ['Channel']);
                    });
                  },
                  child: Text('Remove')),
              FlatButton(
                  color: Colors.black12,
                  onPressed: () {
                    _firebaseMessaging.getToken().then((token) {
                      print("Token: $token");
                      _firstUserClient.removeAllPushNotificationsFromDeviceWithPushToken(PushType.FCM, token);
                    });
                  },
                  child: Text('Remove All')),
            ]),
          ]),
        ),
      );
}
