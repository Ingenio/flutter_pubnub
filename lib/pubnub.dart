import 'dart:async';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

const _clientIdKey = 'clientId';

class PubNubConfig {
  static final _publishKey = 'publishKey';
  static final _subscribeKey = 'subscribeKey';
  static final _authKey = 'authKey';
  static final _presenceTimeoutKey = 'presenceTimeout';
  static final _uuidKey = 'uuid';
  static final _filterKey = 'filter';
  static final _uuid = Uuid();

  PubNubConfig(this.publishKey, this.subscribeKey,
      {this.authKey, this.presenceTimeout, this.uuid, this.filter});

  final String publishKey;
  final String subscribeKey;
  final String authKey;
  final int presenceTimeout;
  final String uuid;
  final String filter;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> args = {
      _clientIdKey: _uuid.v4(options: {'rng': UuidUtil.cryptoRNG}),
      _publishKey: publishKey,
      _subscribeKey: subscribeKey,
      _uuidKey: uuid,
      _filterKey: filter,
      _authKey: authKey
    };

    if (presenceTimeout != null) {
      args[_presenceTimeoutKey] = presenceTimeout;
    }

    return args;
  }
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
  static const _metadataKey = 'metadata';

  static const _statusCategoryKey = 'category';
  static const _statusOperationKey = 'operation';
  static const _errorOperationKey = 'operation';

  static final MethodChannel _channel = const MethodChannel(_methodChannelName);

  static final clients = Map<String, PubNub>();

  static final _messageChannelStream =
      const EventChannel(_messageChannelName).receiveBroadcastStream();
  static final _statusChannelStream =
      const EventChannel(_statusChannelName).receiveBroadcastStream();
  static final _presenceChannelStream =
      const EventChannel(_presenceChannelName).receiveBroadcastStream();
  static final _errorChannelStream =
      const EventChannel(_errorChannelName).receiveBroadcastStream();

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
  Future<void> presence(
      List<String> channels, Map<String, String> state) async {
    return await _invokeMethod(
        _presenceMethod, {_stateKey: state, _channelsKey: channels});
  }

  /// Publishes a message on a specified channel, some metadata can be passed and used in conjunction with filter expressions
  Future<void> publish(List<String> channels, Map message,
      {Map metadata}) async {
    Map args = {_messageKey: message, _channelsKey: channels};

    if (metadata != null) {
      args[_metadataKey] = metadata;
    }

    return await _invokeMethod(_publishMethod, args);
  }

  /// Unsubscribes from a single channel
  Future<void> unsubscribe(List<String> channels) async {
    return await _invokeMethod(_unsubscribeMethod, {_channelsKey: channels});
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

  bool _clientFilter(dynamic event) =>
      event[_clientIdKey] == config[_clientIdKey];

  /// Fires whenever the a message is received.
  Stream<Map> get onMessageReceived {
    return _messageChannelStream
        .where(_clientFilter)
        .map((dynamic event) => _parseMessage(event));
  }

  /// Fires whenever the status changes.
  Stream<Map> get onStatusReceived {
    return _statusChannelStream
        .where(_clientFilter)
        .map((dynamic event) => _parseStatus(event));
  }

  /// Fires whenever the presence changes.
  Stream<Map> get onPresenceReceived {
    return _presenceChannelStream
        .where(_clientFilter)
        .map((dynamic event) => _parsePresence(event));
  }

  /// Fires whenever an error is received.
  Stream<Map> get onErrorReceived {
    return _errorChannelStream
        .where(_clientFilter)
        .map((dynamic event) => _parseError(event));
  }

  /// Fires whenever a status is received.
  Map _parseStatus(Map status) {
    status[_statusCategoryKey] = PNStatusCategory.values[
        status[_statusCategoryKey] ?? PNStatusCategory.PNUnknownCategory.index];
    status[_statusOperationKey] = PNOperationType.values[
        status[_statusOperationKey] ?? PNOperationType.PNUnknownOperation.index];
    return status;
  }

  /// Fires whenever presence is received
  Map _parsePresence(Map presence) {
    return presence;
  }

  /// Fires whenever a PubNub error is received
  Map _parseError(Map error) {
    error[_errorOperationKey] = PNOperationType.values[
        error[_errorOperationKey] ?? PNOperationType.PNUnknownOperation.index];
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
