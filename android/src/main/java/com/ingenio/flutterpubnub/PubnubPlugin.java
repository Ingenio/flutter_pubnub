package com.ingenio.flutterpubnub;


import android.os.Handler;
import android.os.Looper;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.pubnub.api.PNConfiguration;
import com.pubnub.api.PubNub;
import com.pubnub.api.callbacks.PNCallback;
import com.pubnub.api.callbacks.SubscribeCallback;
import com.pubnub.api.enums.PNOperationType;
import com.pubnub.api.enums.PNReconnectionPolicy;
import com.pubnub.api.enums.PNStatusCategory;
import com.pubnub.api.models.consumer.PNPublishResult;
import com.pubnub.api.models.consumer.PNStatus;
import com.pubnub.api.models.consumer.presence.PNSetStateResult;
import com.pubnub.api.models.consumer.pubsub.PNMessageResult;
import com.pubnub.api.models.consumer.pubsub.PNPresenceEventResult;

import java.util.Collections;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executor;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * PubnubPlugin
 */
public class PubnubPlugin implements MethodCallHandler {

  private static final String METHOD_CHANNEL_NAME = "flutter.ingenio.com/pubnub_plugin";
  private static final String MESSAGE_CHANNEL_NAME = "flutter.ingenio.com/pubnub_message";
  private static final String STATUS_CHANNEL_NAME = "flutter.ingenio.com/pubnub_status";
  private static final String PRESENCE_CHANNEL_NAME = "flutter.ingenio.com/pubnub_presence";
  private static final String ERROR_CHANNEL_NAME = "flutter.ingenio.com/pubnub_error";

  private static final String SUBSCRIBE_METHOD = "subscribe";
  private static final String PUBLISH_METHOD = "publish";
  private static final String PRESENCE_METHOD = "presence";
  private static final String UNSUBSCRIBE_METHOD = "unsubscribe";
  private static final String DISPOSE_METHOD = "dispose";
  private static final String UUID_METHOD = "uuid";

  private static final String CLIENT_ID_KEY = "clientId";
  private static final String CHANNELS_KEY = "channels";
  private static final String STATE_KEY = "state";
  private static final String CHANNEL_KEY = "channel";
  private static final String MESSAGE_KEY = "message";
  private static final String METADATA_KEY = "metadata";
  private static final String PUBLISH_CONFIG_KEY = "publishKey";
  private static final String SUBSCRIBE_CONFIG_KEY = "subscribeKey";
  private static final String AUTH_CONFIG_KEY = "authKey";
  private static final String PRESENCE_TIMEOUT_KEY = "presenceTimeout";
  private static final String UUID_KEY = "uuid";
  private static final String FILTER_KEY = "filter";
  private static final String ERROR_OPERATION_KEY = "operation";
  private static final String ERROR_KEY = "error";
  private static final String EVENT_KEY = "event";
  private static final String OCCUPANCY_KEY = "occupancy";

  private static  final Map<PNStatusCategory, Integer> categoriesAsNumber =
          new EnumMap<PNStatusCategory, Integer>(PNStatusCategory.class) {{
            put(PNStatusCategory.PNUnknownCategory, 0);
            put(PNStatusCategory.PNAcknowledgmentCategory, 1);
            put(PNStatusCategory.PNAccessDeniedCategory, 2);
            put(PNStatusCategory.PNTimeoutCategory, 3);
            put(PNStatusCategory.PNNetworkIssuesCategory, 4);
            put(PNStatusCategory.PNConnectedCategory, 5);
            put(PNStatusCategory.PNReconnectedCategory, 6);
            put(PNStatusCategory.PNDisconnectedCategory, 7);
            put(PNStatusCategory.PNUnexpectedDisconnectCategory, 8);
            put(PNStatusCategory.PNCancelledCategory, 9);
            put(PNStatusCategory.PNBadRequestCategory, 10);
            put(PNStatusCategory.PNMalformedFilterExpressionCategory, 11);
            put(PNStatusCategory.PNMalformedResponseCategory, 12);
            put(PNStatusCategory.PNDecryptionErrorCategory, 13);
            put(PNStatusCategory.PNTLSConnectionFailedCategory, 14);
            put(PNStatusCategory.PNTLSUntrustedCertificateCategory, 15);
            put(PNStatusCategory.PNRequestMessageCountExceededCategory, 16);
            put(PNStatusCategory.PNReconnectionAttemptsExhausted, 0);
          }};

  private static final Map<PNOperationType, Integer> operationAsNumber =
          new EnumMap<PNOperationType, Integer>(PNOperationType.class) {{
            put(PNOperationType.PNSubscribeOperation, 1);
            put(PNOperationType.PNUnsubscribeOperation, 2);
            put(PNOperationType.PNPublishOperation, 3);
            put(PNOperationType.PNHistoryOperation, 4);
            put(PNOperationType.PNFetchMessagesOperation, 5);
            put(PNOperationType.PNDeleteMessagesOperation, 6);
            put(PNOperationType.PNWhereNowOperation, 7);
            put(PNOperationType.PNHeartbeatOperation, 8);
            put(PNOperationType.PNSetStateOperation, 9);
            put(PNOperationType.PNAddChannelsToGroupOperation, 10);
            put(PNOperationType.PNRemoveChannelsFromGroupOperation, 11);
            put(PNOperationType.PNChannelGroupsOperation, 12);
            put(PNOperationType.PNRemoveGroupOperation, 13);
            put(PNOperationType.PNChannelsForGroupOperation, 14);
            put(PNOperationType.PNPushNotificationEnabledChannelsOperation, 15);
            put(PNOperationType.PNAddPushNotificationsOnChannelsOperation, 16);
            put(PNOperationType.PNRemovePushNotificationsFromChannelsOperation, 17);
            put(PNOperationType.PNRemoveAllPushNotificationsOperation, 18);
            put(PNOperationType.PNTimeOperation, 19);
            put(PNOperationType.PNHereNowOperation, 0);
            put(PNOperationType.PNGetState, 20);
            put(PNOperationType.PNAccessManagerAudit, 0);
            put(PNOperationType.PNAccessManagerGrant, 0);
          }};

  private Map<String, PubNub> clients = new HashMap<>();

  private MessageStreamHandler messageStreamHandler;
  private StatusStreamHandler statusStreamHandler;
  private ErrorStreamHandler errorStreamHandler;
  private PresenceStreamHandler presenceStreamHandler;

  private PubnubPlugin() {
    System.out.println("PubnubFlutterPlugin constructor");
    messageStreamHandler = new MessageStreamHandler();
    statusStreamHandler = new StatusStreamHandler();
    errorStreamHandler = new ErrorStreamHandler();
    presenceStreamHandler = new PresenceStreamHandler();
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    System.out.println("PubnubFlutterPlugin registerWith");

    PubnubPlugin instance = new PubnubPlugin();

    new MethodChannel(registrar.messenger(), METHOD_CHANNEL_NAME)
            .setMethodCallHandler(instance);

    new EventChannel(registrar.messenger(), MESSAGE_CHANNEL_NAME)
            .setStreamHandler(instance.messageStreamHandler);

    new EventChannel(registrar.messenger(), STATUS_CHANNEL_NAME)
            .setStreamHandler(instance.statusStreamHandler);

    new EventChannel(registrar.messenger(), PRESENCE_CHANNEL_NAME)
            .setStreamHandler(instance.presenceStreamHandler);

    new EventChannel(registrar.messenger(), ERROR_CHANNEL_NAME)
            .setStreamHandler(instance.errorStreamHandler);

  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    try {
      handleMethodCall(call, result);
    } catch (Exception e) {
      result.error("Unexpected error!", e.getMessage(), e);
    }
  }

  private void handleMethodCall(final MethodCall call, Result result) {
    final String clientId = call.argument(CLIENT_ID_KEY);
    switch (call.method) {
      case SUBSCRIBE_METHOD:
        handleSubscribe(clientId, call, result);
        break;

      case PUBLISH_METHOD:
        handlePublish(clientId, call, result);
        break;

      case PRESENCE_METHOD:
        handlePresence(clientId, call, result);
        break;

      case UNSUBSCRIBE_METHOD:
        handleUnsubscribe(clientId, call, result);
        break;
      case DISPOSE_METHOD:
        handleDispose(result);
        break;

      case UUID_METHOD:
        handleUuid(clientId, call, result);
        break;

      default:
        result.notImplemented();
        break;
    }
  }

  private PubNub getClient(String clientId, final MethodCall call) {
    if (!clients.containsKey(clientId)) {
      clients.put(clientId, createClient(clientId, call));
    }
    return clients.get(clientId);
  }

  private PubNub createClient(final String clientId, final MethodCall call) {
    System.out.println("PubnubPlugin createClient: " + clientId);
    PNConfiguration config = configFromCall(call);
    PubNub client  = new PubNub(config);
    client.addListener(new ClientCallback(clientId));
    return client;
  }

  private PNConfiguration configFromCall(MethodCall call) {
    final String publishKey = call.argument(PUBLISH_CONFIG_KEY);
    if (publishKey == null) {
      throw new IllegalArgumentException("Publish Key can't be null");
    }
    final String subscribeKey = call.argument(SUBSCRIBE_CONFIG_KEY);
    if (subscribeKey == null) {
      throw new IllegalArgumentException("Subscribe Key can't be null");
    }
    final String authKey = call.argument(AUTH_CONFIG_KEY);
    final Integer presenceTimeout = call.argument(PRESENCE_TIMEOUT_KEY);
    final String uuid = call.argument(UUID_KEY);
    final String filter = call.argument(FILTER_KEY);


    PNConfiguration config = new PNConfiguration()
            .setReconnectionPolicy(PNReconnectionPolicy.LINEAR)
            .setPublishKey(publishKey)
            .setSubscribeKey(subscribeKey);

    if(authKey != null && !authKey.isEmpty()) {
      config.setAuthKey(authKey);
    }

    if(uuid != null && !uuid.isEmpty()) {
      config.setUuid(uuid);
    }

    if(filter != null && !filter.isEmpty()) {
      config.setFilterExpression(filter);
    }

    if (presenceTimeout != null) {
      config.setPresenceTimeout(presenceTimeout);
    }

    return config;
  }

  private void handleSubscribe(final String clientId, MethodCall call, Result result) {
    PubNub client = getClient(clientId, call);
    List<String> channels = call.argument(CHANNELS_KEY);
    if (channels == null || channels.isEmpty()) {
      throw new IllegalArgumentException("Subscribe channels can't be null or empty");
    }
    System.out.println("SUBSCRIBE CLIENT: " + clientId);
    client.subscribe().channels(channels).withPresence().execute();
    result.success(true);
  }

  private void handlePresence(final String clientId, final MethodCall call, Result result) {
    Map<String, String> state = call.argument(STATE_KEY);
    List<String> channels = call.argument(CHANNELS_KEY);
    PubNub client = getClient(clientId, call);
    if (state == null || state.isEmpty()) {
      throw new IllegalArgumentException("Presence state can't be null or empty");
    }
    if (channels == null || channels.isEmpty()) {
      throw new IllegalArgumentException("Presence channels can't be null or empty");
    }
    System.out.println("SET PRESENCE STATE FOR CLIENT: " + clientId);
    client.setPresenceState().channels(channels).state(state).async(new PNCallback<PNSetStateResult>() {
      @Override
      public void onResponse(final PNSetStateResult result, PNStatus status) {
        handleStatus(clientId, status);
      }
    });
    result.success(true);
  }

  private void handleDispose(Result result) {
    for(PubNub client : clients.values()) {
      client.unsubscribeAll();
      client.disconnect();
      client.destroy();
    }
    clients.clear();
    result.success(true);
  }

  private void handleUuid(final String clientId, MethodCall call, Result result) {
    PubNub client = getClient(clientId, call);
    result.success(client.getConfiguration().getUuid());
  }

  private void handleUnsubscribe(final String clientId, MethodCall call, Result result) {
    List<String> channels = call.argument(CHANNELS_KEY);
    PubNub client = getClient(clientId, call);
    if (channels == null || channels.isEmpty()) {
      client.unsubscribeAll();
    } else {
      client.unsubscribe().channels(channels).execute();
    }
    result.success(true);
  }

  private void handlePublish(final String clientId, MethodCall call, Result result) {
    List<String> channels = call.argument(CHANNELS_KEY);
    if (channels == null || channels.isEmpty()) {
      throw new IllegalArgumentException("Publish channels can't be null or empty");
    }
    Map message = call.argument(MESSAGE_KEY);
    if (message == null || message.isEmpty()) {
      throw new IllegalArgumentException("Publish message can't be null or empty");
    }
    Map metadata = call.argument(METADATA_KEY);
    PubNub client = getClient(clientId, call);

    for(String channel : channels) {
      client.publish().channel(channel).message(message).meta(metadata).async(new PNCallback<PNPublishResult>() {
        @Override
        public void onResponse(PNPublishResult result, PNStatus status) {
          handleStatus(clientId, status);
        }
      });
    }


    result.success(true);
  }

  private void handleStatus(String clientId, PNStatus status) {

    System.out.println("Client " + clientId + " status: " + status);
    if(status.isError()) {
      Map<String, Object> map = new HashMap<>();
      map.put(ERROR_OPERATION_KEY, operationAsNumber.get(status.getOperation()));
      map.put(ERROR_KEY, status.getErrorData().toString());
      errorStreamHandler.sendError(clientId, map);
    } else {
      statusStreamHandler.sendStatus(clientId, status);
    }
  }

  private class ClientCallback extends SubscribeCallback {

    private final String clientId;

    ClientCallback(String clientId) {
      this.clientId = clientId;
    }

    @Override
    public void status(PubNub pubnub, PNStatus status) {
      System.out.println("CLIENT " + clientId + " IN STATUS:" + status.toString());
      statusStreamHandler.sendStatus(clientId, status);
    }

    @Override
    public void message(PubNub pubnub, PNMessageResult message) {
      System.out.println("CLIENT " + clientId + " IN MESSAGE");
      messageStreamHandler.sendMessage(clientId, message);
    }

    @Override
    public void presence(PubNub pubnub, PNPresenceEventResult presence) {
      System.out.println("CLIENT " + clientId + " IN PRESENCE");
      presenceStreamHandler.sendPresence(clientId, presence);
    }
  }


  public abstract static class BaseStreamHandler implements EventChannel.StreamHandler {
    private EventChannel.EventSink sink;
    Executor executor = new MainThreadExecutor();

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
      this.sink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
      this.sink = null;
    }
  }

  public static class MessageStreamHandler extends BaseStreamHandler {

    void sendMessage(final String clientId, final PNMessageResult message) {
      if (super.sink != null) {
        System.out.println("publisher: " + message.getPublisher());
        final Map<String, Object> map = new HashMap<String, Object>() {{
          put(CLIENT_ID_KEY, clientId);
          put(UUID_KEY, message.getPublisher());
          put(CHANNEL_KEY, message.getChannel());
          put(MESSAGE_KEY, message.getMessage().toString());
        }};
        executor.execute(new Runnable() {
          @Override
          public void run() {
            MessageStreamHandler.super.sink.success(map);
          }
        });

      }
    }
  }

  public static class StatusStreamHandler extends BaseStreamHandler {

    private static final String STATUS_CATEGORY_KEY = "category";
    private static final String STATUS_OPERATION_KEY = "operation";

    void sendStatus(final String clientId, final PNStatus status) {
      if (super.sink != null) {
        final Map<String, Object> map = new HashMap<String, Object>() {{
          put(CLIENT_ID_KEY, clientId);
          put(STATUS_CATEGORY_KEY, categoriesAsNumber.get(status.getCategory()));
          PNOperationType operationType = status.getOperation();
          put(STATUS_OPERATION_KEY,
                  operationType == null ? null : operationAsNumber.get(status.getOperation()));
          put(UUID_KEY, status.getUuid());
          put(CHANNELS_KEY, status.getAffectedChannels());
        }};
        executor.execute(new Runnable() {
          @Override
          public void run() {
            StatusStreamHandler.super.sink.success(map);
          }
        });

      }
    }
  }

  public static class PresenceStreamHandler extends BaseStreamHandler {

    void sendPresence(final String clientId, final PNPresenceEventResult presence) {
      System.out.println(presence.toString());
      if (super.sink != null) {
        final Map<String, Object> map = new HashMap<String, Object>() {{
          put(CLIENT_ID_KEY, clientId);
          put(CHANNEL_KEY, presence.getChannel());
          put(EVENT_KEY, presence.getEvent());
          put(UUID_KEY, presence.getUuid());
          put(OCCUPANCY_KEY, presence.getOccupancy());
          JsonElement state = presence.getState();
          put(STATE_KEY, state == null ? new HashMap<String,String>() :
                  new Gson().fromJson(state, Map.class));

        }};
        executor.execute(new Runnable() {
          @Override
          public void run() {
            PresenceStreamHandler.super.sink.success(map);
          }
        });

      }
    }
  }

  public static class ErrorStreamHandler extends BaseStreamHandler {

    void sendError(String clientId, final Map<String, Object> map) {
      if (super.sink != null) {
        map.put(CLIENT_ID_KEY, clientId);
        executor.execute(new Runnable() {
          @Override
          public void run() {
            ErrorStreamHandler.super.sink.success(map);
          }
        });
      }
    }
  }

  private static class MainThreadExecutor implements Executor {

    final Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void execute(Runnable command) {
      handler.post(command);
    }
  }
}

