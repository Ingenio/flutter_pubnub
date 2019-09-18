import 'dart:async';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

/// PubNub Plugin. This plugin is not intended to implement all PubNub functionalities but rather take a minimal approach
/// for solving most general use cases
/// Main areas covered by the plugin are
/// - Instantiate the plugin passing the required PubNub authentication information
/// - Pass a filter expression when instantiating the plugin
/// - Subscribe to one or more channels
/// - Unsubscribe from one channel or all channels
/// - Publish a message to a channel
/// - Retrieve UUID if was not set during the plugin instantiation
/// {@tool sample}
///
/// Instantiate plugin without a filter expression:
///
/// ```dart
/// _pubNubFlutter = PubNubFlutter('pub-c-2d1121f9-06c1-4413-8d2e-0000000000',
///        'sub-c-324ae474-ecfd-11e8-91a4-00000000000',
///        uuid: '127c1ab5-fc7f-4c46-8460-3207b6782007');
/// ```
/// Instantiate plugin with a filter expression:
///
/// ```dart
/// _pubNubFlutter = PubNubFlutter('pub-c-2d1121f9-06c1-4413-8d2e-0000000000',
///        'sub-c-324ae474-ecfd-11e8-91a4-00000000000',
///        uuid: '127c1ab5-fc7f-4c46-8460-3207b6782007',
///        filter: 'uuid != "127c1ab5-fc7f-4c46-8460-3207b6782007"');
/// ```
///
/// It is also possible to pass a PubNub authKey if such mechanism is used on the PubNub side for additional security.
///
/// ```dart
/// _pubNubFlutter = PubNubFlutter('pub-c-2d1121f9-06c1-4413-8d2e-0000000000',
///        'sub-c-324ae474-ecfd-11e8-91a4-00000000000',
///        authKey: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx',
///        uuid: '127c1ab5-fc7f-4c46-8460-3207b6782007');
/// ```
///
/// Finally, it is also possible to set a presence timeout value in order to be informed of possible/unexpected disconnections:
///
/// ```dart
/// _pubNubFlutter = PubNubFlutter('pub-c-2d1121f9-06c1-4413-8d2e-0000000000',
///        'sub-c-324ae474-ecfd-11e8-91a4-00000000000',
///        presenceTimeOut: 120,
///        uuid: '127c1ab5-fc7f-4c46-8460-3207b6782007');
/// ```
///
/// Subscribe to a channel:
///
/// ``` dart
/// _pubNubFlutter.subscribe(['test_channel']);
/// ```
///
/// Unsubscribe from a channel:
///
/// ``` dart
/// _pubNubFlutter.unsubscribe(channel: 'test_channel');
/// ```
///
///  Unsubscribe from all channels:
///
/// ``` dart
/// _pubNubFlutter.unsubscribeAll();
/// ```
///
/// Publish a message to a channel:
///
/// ``` dart
///    _pubNubFlutter.publish(
///                            {'message': 'Hello World'},
///                            'test_channel',
///                          );
/// ```
///
/// Publish a message to a channel passing metadata optional filter expression acts upon:
///
/// ``` dart
///    _pubNubFlutter.publish(
///                            {'message': 'Hello World'},
///                            'test_channel',
///                            metadata: {
///                             'uuid': '127c1ab5-fc7f-4c46-8460-3207b6782007'
///                           }
///                          );
/// ```
///
/// Listen for Messages:
///
/// ``` dart
/// _pubNubFlutter.onMessageReceived
///        .listen((message) => print('Message:$message'));
/// ```
///
/// Listen for Status:
///
/// ``` dart
///  _pubNubFlutter.onStatusReceived
///        .listen((status) => print('Status:${status.toString()}'));
/// ```
/// Listen to Presence:
///
/// ``` dart
/// _pubNubFlutter.onPresenceReceived
///        .listen((presence) => print('Presence:${presence.toString()}'));
/// ```
///
/// Listen for Errors:
///
/// ``` dart
/// _pubNubFlutter.onErrorReceived.listen((error) => print('Error:$error'));
/// ```
///
///  {@end-tool}
///
///
///
///
///

const _clientIdKey = 'clientId';

class PubNubConfig {
  static final _publishKey = 'publishKey';
  static final _subscribeKey = 'subscribeKey';
  static final _authKey = 'authKey';
  static final _presenceTimeoutKey = 'presenceTimeout';
  static final _uuidKey = 'uuid';
  static final _filterKey = 'filter';
  static final _uuid = Uuid();

  PubNubConfig(this.publishKey, this.subscribeKey, {this.authKey, this.presenceTimeout, this.uuid, this.filter});

  final String publishKey;
  final String subscribeKey;
  final String authKey;
  final int presenceTimeout;
  final String uuid;
  final String filter;

  Map<String, dynamic> toMap() => {
        _clientIdKey: _uuid.v4(options: {'rng': UuidUtil.cryptoRNG}),
        _publishKey: publishKey,
        _subscribeKey: subscribeKey,
        _uuidKey: uuid,
        _filterKey: filter,
        _authKey: authKey,
        if (presenceTimeout != null) _presenceTimeoutKey: presenceTimeout
      };
}

class PubNub {
  //  Channels Names
  static const _methodChannelName = 'flutter.ingenio.com/pubnub_plugin';
  static const _messageChannelName = 'flutter.ingenio.com/pubnub_message';
  static const _statusChannelName = 'flutter.ingenio.com/pubnub_status';
  static const _presenceChannelName = 'flutter.ingenio.com/pubnub_presence';
  static const _errorChannelName = 'flutter.ingenio.com/pubnub_error';

  //  Methods Names
  static const _subscribeMethod = 'subscribe';
  static const _presenceMethod = 'presence';
  static const _publishMethod = 'publish';
  static const _unsubscribeMethod = 'unsubscribe';
  static const _disposeMethod = 'dispose';
  static const _uuidMethod = 'uuid';

  // Arguments keys
  static const _channelsKey = 'channels';
  static const _stateKey = 'state';
  static const _messageKey = 'message';
  static const _channelKey = 'channel';
  static const _metadataKey = 'metadata';

  static const _statusCategoryKey = 'category';
  static const _statusOperationKey = 'operation';
  static const _errorOperationKey = 'operation';

  static final MethodChannel _channel = const MethodChannel(_methodChannelName);

  static final clients = Map<String, PubNub>();

  static final _messageChannelStream = const EventChannel(_messageChannelName).receiveBroadcastStream();
  static final _statusChannelStream = const EventChannel(_statusChannelName).receiveBroadcastStream();
  static final _presenceChannelStream = const EventChannel(_presenceChannelName).receiveBroadcastStream();
  static final _errorChannelStream = const EventChannel(_errorChannelName).receiveBroadcastStream();

  /// Create the plugin, UUID and filter expressions are optional and can be used for tracking purposes and filtering purposes, for instance can disable getting messages on the same UUID.
  PubNub(PubNubConfig config) : this.config = config.toMap() {
    clients[_clientIdKey] = this;
  }

  final Map<String, dynamic> config;

  Future<dynamic> _invokeMethod(
    String method, [
    Map<dynamic, dynamic> arguments,
  ]) {
    arguments ??= <dynamic, dynamic>{};
    arguments.addAll(config);
    return _channel.invokeMethod(method, arguments);
  }

  /// Subscribe to a list of channels
  Future<void> subscribe(List<String> channels) async {
    return await _invokeMethod(_subscribeMethod, {_channelsKey: channels});
  }

  /// Set Presence State on a specified channel
  Future<void> presence(String channel, Map<String, String> state) async {
    return await _invokeMethod(_presenceMethod, {_stateKey: state, _channelKey: channel});
  }

  /// Publishes a message on a specified channel, some metadata can be passed and used in conjunction with filter expressions
  Future<void> publish(String channel, Map message, {Map metadata}) async {
    return await _invokeMethod(
        _publishMethod, {_messageKey: message, _channelKey: channel, if (metadata != null) _metadataKey: metadata});
  }

  /// Unsubscribes from a single channel
  Future<void> unsubscribe(String channel) async {
    return await _invokeMethod(_unsubscribeMethod, {_channelKey: channel});
  }

  /// Dispose/destroy pubnub clients
  Future<void> dispose() async {
    return await _invokeMethod(_disposeMethod);
  }

  /// Unsubscribes from all channels
  Future<void> unsubscribeAll() async {
    return await _invokeMethod(_unsubscribeMethod);
  }

  /// Get the UUID configured for PubNub. Note that when the UUID is passed  in the plugin creation, the returned UUID is the same
  /// If the UUID has not been passed in the plugin creation, then PubNub assigns a new UUID. This may be important for tracking how many devices/clients are using the API and
  /// may impact how much the service costs
  Future<String> uuid() async {
    return await _invokeMethod(_uuidMethod);
  }

  bool _clientFilter(dynamic event) => event[_clientIdKey] == config[_clientIdKey];

  /// Fires whenever the a message is received.
  Stream<Map> get onMessageReceived {
    return _messageChannelStream.where(_clientFilter).map((dynamic event) => _parseMessage(event));
  }

  /// Fires whenever the status changes.
  Stream<Map> get onStatusReceived {
    return _statusChannelStream.where(_clientFilter).map((dynamic event) => _parseStatus(event));
  }

  /// Fires whenever the presence changes.
  Stream<Map> get onPresenceReceived {
    return _presenceChannelStream.where(_clientFilter).map((dynamic event) => _parsePresence(event));
  }

  /// Fires whenever an error is received.
  Stream<Map> get onErrorReceived {
    return _errorChannelStream.where(_clientFilter).map((dynamic event) => _parseError(event));
  }

  /// Fires whenever a status is received.
  Map _parseStatus(Map status) {
    status[_statusCategoryKey] = PNStatusCategory.values[status[_statusCategoryKey] ?? 0];
    status[_statusOperationKey] = PNOperationType.values[status[_statusOperationKey] ?? 0];
    return status;
  }

  /// Fires whenever presence is received
  Map _parsePresence(Map presence) {
    return presence;
  }

  /// Fires whenever a PubNub error is received
  Map _parseError(Map error) {
    error[_errorOperationKey] = PNOperationType.values[error[_errorOperationKey] ?? 0];
    return error;
  }

  /// Fires whenever a message is received
  Map _parseMessage(Map message) {
    return message;
  }
}

/// Values for the status category. Not this is an intersection of both iOS and Android enums as both have different values
enum PNStatusCategory {
  PNUnknownCategory,
  PNAcknowledgmentCategory,
  PNAccessDeniedCategory,
  PNTimeoutCategory,
  PNNetworkIssuesCategory,
  PNConnectedCategory,
  PNReconnectedCategory,
  PNDisconnectedCategory,
  PNUnexpectedDisconnectCategory,
  PNCancelledCategory,
  PNBadRequestCategory,
  PNMalformedFilterExpressionCategory,
  PNMalformedResponseCategory,
  PNDecryptionErrorCategory,
  PNTLSConnectionFailedCategory,
  PNTLSUntrustedCertificateCategory,
  PNRequestMessageCountExceededCategory,
}

/// Operation type coming back in the status
enum PNOperationType {
  PNUnknownOperation,
  PNSubscribeOperation,
  PNUnsubscribeOperation,
  PNPublishOperation,
  PNHistoryOperation,
  PNFetchMessagesOperation,
  PNDeleteMessagesOperation,
  PNWhereNowOperation,
  PNHeartbeatOperation,
  PNSetStateOperation,
  PNAddChannelsToGroupOperation,
  PNRemoveChannelsFromGroupOperation,
  PNChannelGroupsOperation,
  PNRemoveGroupOperation,
  PNChannelsForGroupOperation,
  PNPushNotificationEnabledChannelsOperation,
  PNAddPushNotificationsOnChannelsOperation,
  PNRemovePushNotificationsFromChannelsOperation,
  PNRemoveAllPushNotificationsOperation,
  PNTimeOperation,
  PNGetStateOperation
}
