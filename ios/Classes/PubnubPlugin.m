#import "PubnubPlugin.h"

@interface PubnubPlugin () <PNObjectEventListener>

@property (nonatomic, strong) NSMutableDictionary<NSString*, PubNub*> *clients;
@end

@implementation PubnubPlugin

NSString *const PUBNUB_METHOD_CHANNEL_NAME = @"flutter.ingenio.com/pubnub_plugin";
NSString *const PUBNUB_MESSAGE_CHANNEL_NAME = @"flutter.ingenio.com/pubnub_message";
NSString *const PUBNUB_STATUS_CHANNEL_NAME = @"flutter.ingenio.com/pubnub_status";
NSString *const PUBNUB_PRESENCE_CHANNEL_NAME = @"flutter.ingenio.com/pubnub_presence";
NSString *const PUBNUB_ERROR_CHANNEL_NAME = @"flutter.ingenio.com/pubnub_error";
NSString *const PUBNUB_MESSAGE_ACTION_CHANNEL_NAME = @"flutter.ingenio.com/message_action";

NSString *const SUBSCRIBE_METHOD = @"subscribe";
NSString *const PUBLISH_METHOD = @"publish";
NSString *const PRESENCE_METHOD = @"presence";
NSString *const UNSUBSCRIBE_METHOD = @"unsubscribe";
NSString *const DISPOSE_METHOD = @"dispose";
NSString *const UUID_METHOD = @"uuid";
NSString *const RECONNECT_METHOD = @"reconnect";

NSString *const ADD_CHANNELS_TO_CHANNEL_GROUP_METHOD = @"addChannelsToChannelGroup";
NSString *const LIST_CHANNELS_FOR_CHANNEL_GROUP_METHOD = @"listChannelsForChannelGroup";
NSString *const REMOVE_CHANNELS_FOR_CHANNEL_GROUP_METHOD = @"removeChannelsFromChannelGroup";
NSString *const DELETE_CHANNEL_GROUP_METHOD = @"deleteChannelGroup";
NSString *const SUBSCRIBE_TO_CHANNEL_GROUP_METHOD = @"subscribeToChannelGroups";
NSString *const UNSUBSCRIBE_FROM_CHANNEL_GROUP_METHOD = @"unsubscribeFromChannelGroups";
NSString *const HISTORY_METHOD = @"history";
NSString *const ADD_PUSH_NOTIFICATIONS_ON_CHANNELS_METHOD = @"addPushNotificationsOnChannels";
NSString *const LIST_PUSH_NOTIFICATION_CHANNELS_METHOD = @"listPushNotificationChannels";
NSString *const REMOVE_PUSH_NOTIFICATIONS_FROM_CHANNELS_METHOD = @"removePushNotificationsFromChannels";
NSString *const REMOVE_ALL_PUSH_NOTIFICATIONS_FROM_DEVICE_AITH_PUSH_TOKEN_METHOD = @"removeAllPushNotificationsFromDeviceWithPushToken";
NSString *const SIGNAL_METHOD = @"signal";
NSString *const ADD_MESSAGE_ACTION_METHOD = @"addMessageAction";

NSString *const CLIENT_ID_KEY = @"clientId";
NSString *const CHANNELS_KEY = @"channels";
NSString *const STATE_KEY = @"state";
NSString *const CHANNEL_KEY = @"channel";
NSString *const MESSAGE_KEY = @"message";
NSString *const METADATA_KEY = @"metadata";
NSString *const PUBLISH_CONFIG_KEY = @"publishKey";
NSString *const SUBSCRIBE_CONFIG_KEY = @"subscribeKey";
NSString *const AUTH_CONFIG_KEY = @"authKey";
NSString *const PRESENCE_TIMEOUT_KEY = @"presenceTimeout";
NSString *const UUID_KEY = @"uuid";
NSString *const FILTER_KEY = @"filter";
NSString *const ERROR_OPERATION_KEY = @"operation";
NSString *const ERROR_KEY = @"error";
NSString *const EVENT_KEY = @"event";
NSString *const OCCUPANCY_KEY = @"occupancy";
NSString *const STATUS_CATEGORY_KEY = @"category";
NSString *const STATUS_OPERATION_KEY = @"operation";
NSString *const CHANNEL_GROUP_KEY = @"channelGroup";
NSString *const CHANNEL_GROUPS_KEY = @"channelGroups";
NSString *const LIMIT_KEY = @"limit";
NSString *const START_KEY = @"start";
NSString *const END_KEY = @"end";
NSString *const PUSH_TYPE_KEY = @"pushType";
NSString *const PUSH_TOKEN_KEY = @"pushToken";
NSString *const ERROR_INFO_KEY = @"information";
NSString *const RESTORE = @"restore";
NSString *const MESSAGE_PUBLISHING_STATUS_KEY = @"isPublished";
NSString *const STATUS_CODE_KEY = @"statusCode";
NSString *const MESSAGE_PUBLISHING_CHANNELS_KEY = @"affectedChannels";
NSString *const REQUEST_KEY = @"request";
NSString *const WITH_PRESENCE_KEY = @"withPresence";
NSString *const TIME_TOKEN_KEY = @"timeToken";
NSString *const ACTION_TYPE_KEY = @"actionType";
NSString *const ACTION_VALUE_KEY = @"actionValue";

NSString *const MISSING_ARGUMENT_EXCEPTION = @"Missing Argument Exception";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:PUBNUB_METHOD_CHANNEL_NAME
                                     binaryMessenger:[registrar messenger]];
    PubnubPlugin* instance = [[PubnubPlugin alloc] init];
    
    instance.messageStreamHandler = [MessageStreamHandler new];
    instance.statusStreamHandler = [StatusStreamHandler new];
    instance.presenceStreamHandler = [PresenceStreamHandler new];
    instance.errorStreamHandler = [ErrorStreamHandler new];
    instance.messageActionStreamHandler = [MessageActionStreamHandler new];
    
    [registrar addMethodCallDelegate:instance channel:channel];
    
    
    [[FlutterEventChannel eventChannelWithName:PUBNUB_MESSAGE_CHANNEL_NAME
                               binaryMessenger:[registrar messenger]] setStreamHandler:instance.messageStreamHandler];
    
    [[FlutterEventChannel eventChannelWithName:PUBNUB_STATUS_CHANNEL_NAME
                               binaryMessenger:[registrar messenger]] setStreamHandler:instance.statusStreamHandler];
    
    [[FlutterEventChannel eventChannelWithName:PUBNUB_PRESENCE_CHANNEL_NAME
                               binaryMessenger:[registrar messenger]] setStreamHandler:instance.presenceStreamHandler];
    
    [[FlutterEventChannel eventChannelWithName:PUBNUB_ERROR_CHANNEL_NAME
                               binaryMessenger:[registrar messenger]] setStreamHandler:instance.errorStreamHandler];
  
    [[FlutterEventChannel eventChannelWithName:PUBNUB_MESSAGE_ACTION_CHANNEL_NAME
                             binaryMessenger:[registrar messenger]] setStreamHandler:instance.messageActionStreamHandler];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    @try{
        NSString *clientId = call.arguments[CLIENT_ID_KEY];
        
        if ([DISPOSE_METHOD isEqualToString:call.method]) {
            [self handleDispose:call clientId:clientId result:result];
        } else if  ([SUBSCRIBE_METHOD isEqualToString:call.method ]) {
            [self handleSubscribe:call clientId:clientId result:result];
        } else if  ([PUBLISH_METHOD isEqualToString:call.method]) {
            [self handlePublish:call clientId:clientId result:result];
        } else if  ([PRESENCE_METHOD isEqualToString:call.method]) {
            [self handlePresence:call clientId:clientId result:result];
        } else if  ([UNSUBSCRIBE_METHOD isEqualToString:call.method]) {
            [self handleUnsubscribe:call clientId:clientId result:result];
        } else if  ([UUID_METHOD isEqualToString:call.method]) {
            [self handleUUID:call clientId:clientId result:result];
        } else if  ([ADD_CHANNELS_TO_CHANNEL_GROUP_METHOD isEqualToString:call.method]) {
            [self handleAddChannelsToChannelGroup:call clientId:clientId result:result];
        } else if  ([LIST_CHANNELS_FOR_CHANNEL_GROUP_METHOD isEqualToString:call.method]) {
            [self handleListChannelsForChannelGroup:call clientId:clientId result:result];
        } else if  ([REMOVE_CHANNELS_FOR_CHANNEL_GROUP_METHOD isEqualToString:call.method]) {
            [self handleRemoveChannelsFromChannelGroup:call clientId:clientId result:result];
        } else if  ([DELETE_CHANNEL_GROUP_METHOD isEqualToString:call.method]) {
            [self handleDeleteChannelGroup:call clientId:clientId result:result];
        } else if  ([SUBSCRIBE_TO_CHANNEL_GROUP_METHOD isEqualToString:call.method]) {
            [self handleSubscribeToChannelGroups:call clientId:clientId result:result];
        } else if  ([UNSUBSCRIBE_FROM_CHANNEL_GROUP_METHOD isEqualToString:call.method]) {
            [self handleUnsubscribeFromChannelGroups:call clientId:clientId result:result];
        } else if  ([HISTORY_METHOD isEqualToString:call.method]) {
            [self handleHistory:call clientId:clientId result:result];
        } else if  ([ADD_PUSH_NOTIFICATIONS_ON_CHANNELS_METHOD isEqualToString:call.method]) {
            [self handleAddPushNotificationsOnChannels:call clientId:clientId result:result];
        } else if  ([LIST_PUSH_NOTIFICATION_CHANNELS_METHOD isEqualToString:call.method]) {
            [self handleListPushNotificationChannels:call clientId:clientId result:result];
        } else if  ([REMOVE_PUSH_NOTIFICATIONS_FROM_CHANNELS_METHOD isEqualToString:call.method]) {
            [self handleRemovePushNotificationsFromChannels:call clientId:clientId result:result];
        } else if  ([REMOVE_ALL_PUSH_NOTIFICATIONS_FROM_DEVICE_AITH_PUSH_TOKEN_METHOD isEqualToString:call.method]) {
            [self handleRemoveAllPushNotificationsFromDeviceWithPushToken:call clientId:clientId result:result];
        } else if  ([SIGNAL_METHOD isEqualToString:call.method]) {
            [self handleSignal:call clientId:clientId result:result];
        } else if ([RECONNECT_METHOD isEqualToString:call.method]) {
            [self handleReconnect:call clientId:clientId result:result];
        } else if ([ADD_MESSAGE_ACTION_METHOD isEqualToString:call.method]) {
          [self handleAddMessageAction:call clientId:clientId result:result];
        }
        
        else {
            result(FlutterMethodNotImplemented);
        }
    }
    @catch(NSException *exception){
        result([exception reason]);
    }
}

- (PubNub *) getClient:(NSString *)clientId call:(FlutterMethodCall *)call {
    if(self.clients == NULL) {
        self.clients = [NSMutableDictionary new];
    }
    
    if(self.clients[clientId] == NULL) {
        self.clients[clientId] = [self createClient:clientId call:call];
    }
    
    return self.clients[clientId];
}

- (PubNub *) createClient:(NSString *)clientId call:(FlutterMethodCall *)call {
    
    NSLog(@"FlutterPubnubPlugin createClient clientId: %@ method: %@", clientId, call.method);
    
    PNConfiguration *config = [self configFromCall:call];

    PubNub *client = [PubNub clientWithConfiguration:config];
    
    NSString *filter = call.arguments[FILTER_KEY];
    
    if((id)filter != [NSNull null] && filter && filter.length > 0) {
        NSLog(@"Setting filter expression");
        client.filterExpression = filter;
    }
    
    [client addListener:self];
    
    return client;
}

- (PNConfiguration *)configFromCall:(FlutterMethodCall*)call {
    NSString *publishKey = call.arguments[PUBLISH_CONFIG_KEY];
    PNConfiguration *config = NULL;
    
    NSLog(@"IN CONFIG FROM CALL");
    if((id)publishKey == [NSNull null] || publishKey == NULL) {
        NSLog(@"configFromCall: publish key is null");
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Publish key can't be null or empty" userInfo:nil];
    }
    
    NSString *subscribeKey = call.arguments[SUBSCRIBE_CONFIG_KEY];
    if((id)subscribeKey == [NSNull null] || subscribeKey == NULL) {
        NSLog(@"configFromCall: subscribe key is null");
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Subscribe key can't be null or empty" userInfo:nil];
    }
    
    id authKey = call.arguments[AUTH_CONFIG_KEY];
    id presenceTimeout = call.arguments[PRESENCE_TIMEOUT_KEY];
    id uuid = call.arguments[UUID_KEY];
    
    id restore = call.arguments[RESTORE];
    
    config =
    [PNConfiguration configurationWithPublishKey:publishKey
                                    subscribeKey:subscribeKey];
    
    
    if(uuid != [NSNull null]) {
        NSLog(@"configFromCall: setting uuid");
        config.uuid = uuid;
    }
    

  
    if(restore != [NSNull null]) {
        NSLog(@"configFromCall: setting restore: %d", [restore boolValue]);
       config.catchUpOnSubscriptionRestore = [restore boolValue];
    }
    
    if(authKey != [NSNull null]) {
        NSLog(@"configFromCall: setting authkey: %@", authKey);
        config.authKey = authKey;
    }
    
    if(presenceTimeout != [NSNull null]) {
        NSLog(@"configFromCall: setting presence timeout: %ld", (long)[presenceTimeout integerValue]);
        config.presenceHeartbeatValue = [presenceTimeout integerValue];
    }
    
    NSLog(@"IN CONFIG FROM CALL END");
    
    return config;
}

- (void) handleAddPushNotificationsOnChannels:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSArray<NSString *> *channels = call.arguments[CHANNELS_KEY];
    NSString *pushToken = call.arguments[PUSH_TOKEN_KEY];
    NSNumber *pushType = call.arguments[PUSH_TYPE_KEY];
    
    if((id)channels == [NSNull null] || channels == NULL || [channels count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Channels can't be null or empty" userInfo:nil];
    }
    
    if((id)pushToken == [NSNull null] || pushToken == NULL || pushToken.length == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Push Token can't be null or empty" userInfo:nil];
    }
    
    if((id)pushType == [NSNull null] || pushType == NULL) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Push Type can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    __weak __typeof(self) weakSelf = self;
    
    id preparedToken;
    PNPushType pnPushType;
    if([pushType integerValue] == APNS) {
        preparedToken = [pushToken dataUsingEncoding:NSUTF8StringEncoding];
        pnPushType = PNAPNSPush;
    } else {
        preparedToken = pushToken;
        pnPushType = PNFCMPush;
    }
    client.push().enable().channels(channels)
    .token(preparedToken)
    .pushType(pnPushType)
    .performWithCompletion(^(PNAcknowledgmentStatus *status) {
        __strong __typeof(self) strongSelf = weakSelf;
        result(NULL);
        if(status != NULL) {
            [strongSelf handleStatus:status clientId:clientId];
        }
    });

}

- (void) handleListPushNotificationChannels:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSString *pushToken = call.arguments[PUSH_TOKEN_KEY];
    NSNumber *pushType = call.arguments[PUSH_TYPE_KEY];
    
    if((id)pushToken == [NSNull null] || pushToken == NULL || pushToken.length == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Push Token can't be null or empty" userInfo:nil];
    }
    
    if((id)pushType == [NSNull null] || pushType == NULL) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Push Type can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    __weak __typeof(self) weakSelf = self;
    
    id preparedToken;
    PNPushType pnPushType;
    if([pushType integerValue] == APNS) {
        preparedToken = [pushToken dataUsingEncoding:NSUTF8StringEncoding];
        pnPushType = PNAPNSPush;
    } else {
        preparedToken = pushToken;
        pnPushType = PNFCMPush;
    }
    client.push().audit().token(preparedToken).pushType(pnPushType)
    .performWithCompletion(^(PNAPNSEnabledChannelsResult *res, PNErrorStatus *status) {
        __strong __typeof(self) strongSelf = weakSelf;
        result([[res data] channels]);
        if(status != NULL) {
            [strongSelf handleStatus:status clientId:clientId];
        }
    });
    
}

- (void) handleRemovePushNotificationsFromChannels:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSArray<NSString *> *channels = call.arguments[CHANNELS_KEY];
    NSString *pushToken = call.arguments[PUSH_TOKEN_KEY];
    NSNumber *pushType = call.arguments[PUSH_TYPE_KEY];
    
    if((id)channels == [NSNull null] || channels == NULL || [channels count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Channels can't be null or empty" userInfo:nil];
    }
    
    if((id)pushToken == [NSNull null] || pushToken == NULL || pushToken.length == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Push Token can't be null or empty" userInfo:nil];
    }
    
    if((id)pushType == [NSNull null] || pushType == NULL) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Push Type can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    __weak __typeof(self) weakSelf = self;
    
    id preparedToken;
    PNPushType pnPushType;
    if([pushType integerValue] == APNS) {
        preparedToken = [pushToken dataUsingEncoding:NSUTF8StringEncoding];
        pnPushType = PNAPNSPush;
    } else {
        preparedToken = pushToken;
        pnPushType = PNFCMPush;
    }
    client.push().disable().channels(channels)
    .token(preparedToken)
    .pushType(pnPushType)
    .performWithCompletion(^(PNAcknowledgmentStatus *status) {
        __strong __typeof(self) strongSelf = weakSelf;
        result(NULL);
        if(status != NULL) {
            [strongSelf handleStatus:status clientId:clientId];
        }
    });
}

- (void) handleRemoveAllPushNotificationsFromDeviceWithPushToken:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    
    NSString *pushToken = call.arguments[PUSH_TOKEN_KEY];
    NSNumber *pushType = call.arguments[PUSH_TYPE_KEY];
    
    if((id)pushToken == [NSNull null] || pushToken == NULL || pushToken.length == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Push Token can't be null or empty" userInfo:nil];
    }
    
    if((id)pushType == [NSNull null] || pushType == NULL) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Push Type can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    __weak __typeof(self) weakSelf = self;
    
    [client removeAllPushNotificationsFromDeviceWithPushToken:[pushToken dataUsingEncoding:NSUTF8StringEncoding]
                                                andCompletion:^(PNAcknowledgmentStatus *status) {
        __strong __typeof(self) strongSelf = weakSelf;
        result(NULL);
        if(status != NULL) {
            [strongSelf handleStatus:status clientId:clientId];
        }
    }];
}

- (void) handleHistory:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSNumber *limit = call.arguments[LIMIT_KEY];
    NSNumber *start = call.arguments[START_KEY];
    NSNumber *end = call.arguments[END_KEY];
    NSString *channel = call.arguments[CHANNEL_KEY];
    
    
    
    if((id)limit == [NSNull null] || limit == NULL || [limit integerValue] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Limit can't be null or empty" userInfo:nil];
    }
    
    if((id)channel == [NSNull null] || channel == NULL || channel.length == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Channel can't be null or empty" userInfo:nil];
    }
    
    if((id)start == [NSNull null] || start == NULL) {
        start = NULL;
    }
    
    if((id)end == [NSNull null] || end == NULL) {
        end = NULL;
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    
    __weak __typeof(self) weakSelf = self;
    
    
    [client historyForChannel:channel start:start end:end limit:[limit integerValue] reverse:NO includeTimeToken:YES withCompletion:^(PNHistoryResult *res, PNErrorStatus *status) {
        __strong __typeof(self) strongSelf = weakSelf;
        
        
        if(status != NULL) {
            [strongSelf handleStatus:status clientId:clientId];
        }
        
        if(res != NULL && [[[res data] messages] count] > 0 && [[[[res data] messages] firstObject] isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *messages = [NSMutableArray new];
            
            for(NSDictionary *message in [[res data] messages]) {
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message
                                                                   options:0
                                                                     error:&error];

                if (jsonData) {
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [messages addObject:jsonString];
                }
            }
            
            result(messages); // returns something like:  [{message: {message: Hello World!}, timetoken: 15701424217963024}]
        } else {
            result(NULL);
        }
    }];
    
}

- (void) handleAddChannelsToChannelGroup:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSArray<NSString *> *channels = call.arguments[CHANNELS_KEY];
    NSString *channelGroup = call.arguments[CHANNEL_GROUP_KEY];
    
    if((id)channels == [NSNull null] || channels == NULL || [channels count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Channel group channels can't be null or empty" userInfo:nil];
    }
    
    if((id)channelGroup == [NSNull null] || channelGroup == NULL || channelGroup.length == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Channel group can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    
    __weak __typeof(self) weakSelf = self;
    
    [client addChannels: channels toGroup:channelGroup
         withCompletion:^(PNAcknowledgmentStatus *status) {
        __strong __typeof(self) strongSelf = weakSelf;
        result(NULL);
        if(status != NULL) {
            [strongSelf handleStatus:status clientId:clientId];
        }
    }];
    
}

- (void) handleListChannelsForChannelGroup:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSString *channelGroup = call.arguments[CHANNEL_GROUP_KEY];
    
    if((id)channelGroup == [NSNull null] || channelGroup == NULL || channelGroup.length == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Channel group can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    __weak __typeof(self) weakSelf = self;
    
    [client channelsForGroup:channelGroup withCompletion:^(PNChannelGroupChannelsResult *res,
                                                           PNErrorStatus *status) {
        __strong __typeof(self) strongSelf = weakSelf;
        if(status != NULL) {
            [strongSelf handleStatus:status clientId:clientId];
        }
        result([[res data] channels]);
    }];
    
}
- (void) handleRemoveChannelsFromChannelGroup:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSArray<NSString *> *channels = call.arguments[CHANNELS_KEY];
    NSString *channelGroup = call.arguments[CHANNEL_GROUP_KEY];
    
    if((id)channels == [NSNull null] || channels == NULL || [channels count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Channel group channels can't be null or empty"userInfo:nil];
    }
    
    if((id)channelGroup == [NSNull null] || channelGroup == NULL || channelGroup.length == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Channel group can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    __weak __typeof(self) weakSelf = self;
    
    [client removeChannels:channels fromGroup:channelGroup
            withCompletion:^(PNAcknowledgmentStatus *status) {
        __strong __typeof(self) strongSelf = weakSelf;
        if(status != NULL) {
            [strongSelf handleStatus:status clientId:clientId];
        }
        result(NULL);
    }];
}

- (void) handleDeleteChannelGroup:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSString *channelGroup = call.arguments[CHANNEL_GROUP_KEY];
    
    if((id)channelGroup == [NSNull null] || channelGroup == NULL || channelGroup.length == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Channel group can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    __weak __typeof(self) weakSelf = self;
    
    [client removeChannelsFromGroup:channelGroup withCompletion:^(PNAcknowledgmentStatus *status) {
        __strong __typeof(self) strongSelf = weakSelf;
        if(status != NULL) {
            [strongSelf handleStatus:status clientId:clientId];
        }
        result(NULL);
    }];
    
    result(NULL);
}

- (void) handleSubscribeToChannelGroups:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSArray<NSString *> *channelGroups = call.arguments[CHANNEL_GROUPS_KEY];
    bool withPresence = [call.arguments[WITH_PRESENCE_KEY] boolValue];
    
    if((id)channelGroups == [NSNull null] || channelGroups == NULL || [channelGroups count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Channel groups can't be null or empty"userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    [client subscribeToChannelGroups:channelGroups withPresence:withPresence];
    
    result(NULL);
}

- (void) handleUnsubscribeFromChannelGroups:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSArray<NSString *> *channelGroups = call.arguments[CHANNEL_GROUPS_KEY];
    
    if((id)channelGroups == [NSNull null] || channelGroups == NULL || [channelGroups count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Channel groups can't be null or empty"userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    [client unsubscribeFromChannelGroups:channelGroups withPresence:YES];
    
    result(NULL);
}

- (void) handleUnsubscribe:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSArray<NSString *> *channels = call.arguments[CHANNELS_KEY];
    
    PubNub *client = [self getClient:clientId call:call];
    
    if((id)channels == [NSNull null] || channels == NULL || [channels count] == 0) {
        NSLog(@"Unsubscribing from channels: %@", channels);
        [client unsubscribeFromChannels:channels withPresence:YES];
    } else {
        NSLog(@"Unsubscribing ALL Channels");
        [client unsubscribeFromAll];
    }
    
    result(NULL);
}

- (void) handleDispose:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    PubNub *client = [self getClient:clientId call:call];
    [client unsubscribeFromAll];
    [self.clients removeObjectForKey:clientId];
    
    result(NULL);
}

- (void) handleUUID:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    PubNub *client = [self getClient:clientId call:call];
    NSLog(@"UUID method: clientid: %@, client: %@", clientId, client);
    result([[client currentConfiguration] uuid]);
}

- (void) handlePublish:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSArray<NSString *> *channels = call.arguments[CHANNELS_KEY];
    NSDictionary *message = call.arguments[MESSAGE_KEY];
    NSDictionary *metadata = call.arguments[METADATA_KEY];
    
    if((id)channels == [NSNull null] || channels == NULL || [channels count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Publish channels can't be null or empty" userInfo:nil];
    }
    
    if((id)message == [NSNull null] || message == NULL || [message count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Publish message can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    __weak __typeof(self) weakSelf = self;
    
    for(NSString *channel in channels) {
        [client publish:message toChannel:channel withMetadata:metadata completion:^(PNPublishStatus *status) {
            __strong __typeof(self) strongSelf = weakSelf;
                NSDictionary *resultData = @{MESSAGE_PUBLISHING_STATUS_KEY:status.isError ? @(NO) : @(YES),
                                             ERROR_OPERATION_KEY:[PubnubPlugin getOperationAsNumber:status.operation],
                                             STATUS_CATEGORY_KEY:[PubnubPlugin getCategoryAsNumber:status.category],
                                             UUID_KEY: status.uuid,
                                             STATUS_CODE_KEY: @(status.statusCode),
                                             MESSAGE_PUBLISHING_CHANNELS_KEY: [NSArray array],
                                             REQUEST_KEY: status.clientRequest.URL.absoluteString,
                                             TIME_TOKEN_KEY: status.isError ? NULL : status.data.timetoken,
                                             ERROR_KEY:status.isError ? status.errorData.information :@"" };
                result(resultData);
            [strongSelf handleStatus:status clientId:clientId];
        }];
    }
}

- (void) handleSignal:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSArray<NSString *> *channels = call.arguments[CHANNELS_KEY];
    NSDictionary *message = call.arguments[MESSAGE_KEY];
    
    if((id)channels == [NSNull null] || channels == NULL || [channels count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Signal channels can't be null or empty" userInfo:nil];
    }
    
    if((id)message == [NSNull null] || message == NULL || [message count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Signal message can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    __weak __typeof(self) weakSelf = self;
    
    for(NSString *channel in channels) {
        [client signal:message channel:channel withCompletion:^(PNSignalStatus *status) {
            __strong __typeof(self) strongSelf = weakSelf;
            [strongSelf handleStatus:status clientId:clientId];
        }];
    }
    
    result(NULL);
}

- (void) handleAddMessageAction:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
  NSString *actionType = call.arguments[ACTION_TYPE_KEY];
  NSString *actionValue = call.arguments[ACTION_VALUE_KEY];
  NSNumber *timeToken = call.arguments[TIME_TOKEN_KEY];
  NSArray<NSString *> *channels = call.arguments[CHANNELS_KEY];
  
  if((id)channels == [NSNull null] || channels == NULL || [channels count] == 0) {
      @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Presence channels can't be null or empty" userInfo:nil];
  }
  
  if((id)actionType == [NSNull null] || actionType == NULL || actionType.length == 0) {
      @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Action Type can't be null or empty" userInfo:nil];
  }
  
  if((id)actionValue == [NSNull null] || actionValue == NULL || actionValue.length == 0) {
      @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Action Value can't be null or empty" userInfo:nil];
  }
  
  if((id)timeToken == [NSNull null] || timeToken == NULL) {
      @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Time token can't be null" userInfo:nil];
  }
  
  PubNub *client = [self getClient:clientId call:call];
  
  __weak __typeof(self) weakSelf = self;
  
  for(NSString *channel in channels) {
    client.addMessageAction()
        .channel(channel)
        .messageTimetoken(timeToken)
        .type(actionType)
        .value(actionValue)
        .performWithCompletion(^(PNAddMessageActionStatus *status) {
          __strong __typeof(self) strongSelf = weakSelf;
            if(!status.isError) {
                NSDictionary *resultData = @{
                                             UUID_KEY: status.uuid,
                                             STATUS_CODE_KEY: @(status.statusCode),
                                             MESSAGE_PUBLISHING_CHANNELS_KEY: [NSArray array],
                                             REQUEST_KEY: status.clientRequest.URL.absoluteString,
                                             TIME_TOKEN_KEY: status.data.action.messageTimetoken,
                                             ACTION_TYPE_KEY:status.data.action.type,
                                             ACTION_VALUE_KEY:status.data.action.value,
                                             MESSAGE_PUBLISHING_STATUS_KEY:status.isError ? @(NO) : @(YES),
                                             ERROR_KEY:status.isError ? status.errorData.information :@"" };
                result(resultData);
            }
            [strongSelf handleStatus:status clientId:clientId];
        });
  }
  
}

- (void) handlePresence:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSArray<NSString *> *channels = call.arguments[CHANNELS_KEY];
    NSDictionary<NSString*, NSString*> *state = call.arguments[STATE_KEY];
    
    if((id)channels == [NSNull null] || channels == NULL || [channels count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Presence channels can't be null or empty" userInfo:nil];
    }
    
    if((id)state == [NSNull null] || state == NULL || [state count] == 0) {
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Presence state can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    for(NSString *channel in channels) {
        [client setState: state forUUID:client.uuid onChannel: channel
          withCompletion:^(PNClientStateUpdateStatus *status) {
            
            if (status.isError) {
              PNErrorStatus *errorStatus = (PNErrorStatus *)status;
              PNErrorData *errorData = errorStatus.errorData;
              
              NSDictionary *result = @{CLIENT_ID_KEY: clientId, ERROR_OPERATION_KEY:  [PubnubPlugin getOperationAsNumber:status.operation], ERROR_KEY: @"cannot deserialize 1", STATUS_CATEGORY_KEY: [PubnubPlugin getCategoryAsNumber:errorStatus.category], ERROR_INFO_KEY: errorData.information};
                [self.errorStreamHandler sendError:result];
            } else {
                [self.statusStreamHandler sendStatus:status clientId:clientId];
            }
        }];
    }
    
    result(NULL);
}
- (void) handleSubscribe:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSArray<NSString *> *channels = call.arguments[CHANNELS_KEY];
    bool withPresence = [call.arguments[WITH_PRESENCE_KEY] boolValue];
    
    NSLog(@"Subscribe: %@", channels);
    if((id)channels == [NSNull null] || channels == NULL || [channels count] == 0) {
        NSLog(@"Empty Channels exception");
        @throw [[MissingArgumentException alloc] initWithName:MISSING_ARGUMENT_EXCEPTION reason:@"Publish channels can't be null or empty" userInfo:nil];
    }
    
    PubNub *client = [self getClient:clientId call:call];
    
    [client subscribeToChannels:channels withPresence:withPresence];
    
    result(NULL);
}

- (void) handleReconnect:(FlutterMethodCall*)call clientId:(NSString *)clientId result:(FlutterResult)result {
    NSLog(@"Reconnect client: %@", clientId);
    [self handleSubscribe:call clientId:clientId result:result];
}


- (void)handleStatus:(PNStatus *)status clientId:(NSString *)clientId {
  if (status.isError && [status isMemberOfClass:PNErrorStatus.class]) {
    PNErrorStatus *errorStatus = (PNErrorStatus *)status;
    PNErrorData *errorData = errorStatus.errorData;
    
      NSDictionary *result = @{CLIENT_ID_KEY: clientId, ERROR_OPERATION_KEY:  [PubnubPlugin getOperationAsNumber:errorStatus.operation], STATUS_CATEGORY_KEY: [PubnubPlugin getCategoryAsNumber:errorStatus.category], UUID_KEY: status.uuid, STATUS_CODE_KEY: @(status.statusCode), REQUEST_KEY: status.clientRequest.URL.absoluteString, ERROR_KEY: @"cannot deserialize 2", ERROR_INFO_KEY: errorData.information};
        [self.errorStreamHandler sendError:result];
    } else {
        [self.statusStreamHandler sendStatus:status clientId:clientId];
    }
}

- (NSString *) getClientId:(PubNub *) client {
    NSArray *matches = [self.clients allKeysForObject:client];
    if(matches && matches.count > 0) {
        return matches[0];
    }
    return NULL;
}

- (void)client:(PubNub *)client didReceiveMessageAction:(PNMessageActionResult *)action {
  NSLog(@"ClientCallback didReceiveMessageAction");
  [self.messageActionStreamHandler sendMessageAction:action clientId:[self getClientId:client]];
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    NSLog(@"ClientCallback didReceiveStatus");
    [self.statusStreamHandler sendStatus:status clientId:[self getClientId:client]];
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    NSLog(@"ClientCallback didReceiveMessage");
    [self.messageStreamHandler sendMessage:message clientId:[self getClientId:client]];
}

- (void)client:(PubNub *)client didReceiveSignal:(PNSignalResult *)signal {
    NSLog(@"ClientCallback didReceiveSignal");
    [self.messageStreamHandler sendSignal:signal clientId:[self getClientId:client]];
}

// New presence event handling.
- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)presence {
    NSLog(@"ClientCallback didReceivePresenceEvent");
    [self.presenceStreamHandler sendPresence:presence clientId:[self getClientId:client]];
}

typedef enum {
    APNS=0,
    GCM=1
} PushType;

+ (NSNumber *) getCategoryAsNumber:(PNStatusCategory) category {
    switch(category) {
            
        case PNUnknownCategory:
            return [NSNumber numberWithInt:0];
        case PNAcknowledgmentCategory:
            return [NSNumber numberWithInt:1];
        case PNAccessDeniedCategory:
            return [NSNumber numberWithInt:2];
        case PNTimeoutCategory:
            return [NSNumber numberWithInt:3];
        case PNNetworkIssuesCategory:
            return [NSNumber numberWithInt:4];
        case PNConnectedCategory:
            return [NSNumber numberWithInt:5];
        case PNReconnectedCategory:
            return [NSNumber numberWithInt:6];
        case PNDisconnectedCategory:
            return [NSNumber numberWithInt:7];
        case PNUnexpectedDisconnectCategory:
            return [NSNumber numberWithInt:8];
        case PNCancelledCategory:
            return [NSNumber numberWithInt:9];
        case PNBadRequestCategory:
            return [NSNumber numberWithInt:10];
        case PNMalformedFilterExpressionCategory:
            return [NSNumber numberWithInt:11];
        case PNMalformedResponseCategory:
            return [NSNumber numberWithInt:12];
        case PNDecryptionErrorCategory:
            return [NSNumber numberWithInt:13];
        case PNTLSConnectionFailedCategory:
            return [NSNumber numberWithInt:14];
        case PNTLSUntrustedCertificateCategory:
            return [NSNumber numberWithInt:15];
        case PNRequestMessageCountExceededCategory:
            return [NSNumber numberWithInt:16];
        case PNRequestURITooLongCategory:
            return [NSNumber numberWithInt:0];
    }
    
    return [NSNumber numberWithInt:0];
}

+ (NSNumber *)  getOperationAsNumber:(PNOperationType) operation {
    switch (operation) {
            
        case PNSubscribeOperation:
            return [NSNumber numberWithInt:1];
        case PNUnsubscribeOperation:
            return [NSNumber numberWithInt:2];
        case PNPublishOperation:
            return [NSNumber numberWithInt:3];
        case PNHistoryOperation:
            return [NSNumber numberWithInt:4];
        case PNHistoryForChannelsOperation:
            return [NSNumber numberWithInt:0];
        case PNDeleteMessageOperation:
            return [NSNumber numberWithInt:6];
        case PNWhereNowOperation:
            return [NSNumber numberWithInt:7];
        case PNHereNowGlobalOperation:
            return [NSNumber numberWithInt:0];
        case PNHereNowForChannelOperation:
            return [NSNumber numberWithInt:0];
        case PNHereNowForChannelGroupOperation:
            return [NSNumber numberWithInt:0];
        case PNHeartbeatOperation:
            return [NSNumber numberWithInt:8];
        case PNSetStateOperation:
            return [NSNumber numberWithInt:9];
        case PNGetStateOperation:
            return [NSNumber numberWithInt:20];
        case PNStateForChannelOperation:
            return [NSNumber numberWithInt:0];
        case PNStateForChannelGroupOperation:
            return [NSNumber numberWithInt:0];
        case PNAddChannelsToGroupOperation:
            return [NSNumber numberWithInt:10];
        case PNRemoveChannelsFromGroupOperation:
            return [NSNumber numberWithInt:11];
        case PNChannelGroupsOperation:
            return [NSNumber numberWithInt:12];
        case PNRemoveGroupOperation:
            return [NSNumber numberWithInt:13];
        case PNChannelsForGroupOperation:
            return [NSNumber numberWithInt:14];
        case PNPushNotificationEnabledChannelsOperation:
            return [NSNumber numberWithInt:15];
        case PNAddPushNotificationsOnChannelsOperation:
            return [NSNumber numberWithInt:16];
        case PNRemovePushNotificationsFromChannelsOperation:
            return [NSNumber numberWithInt:17];;
        case PNRemoveAllPushNotificationsOperation:
            return [NSNumber numberWithInt:18];
        case PNTimeOperation:
            return [NSNumber numberWithInt:19];
        case PNSignalOperation:
            return [NSNumber numberWithInt:21];
      case PNAddMessageActionOperation:
            return  [NSNumber numberWithInt:22];
        default:
            return [NSNumber numberWithInt:0];
    }
}
@end


@implementation MessageStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    self.eventSink = nil;
    return nil;
}

- (void) sendMessage:(PNMessageResult *)message clientId:(NSString *)clientId {
    [self send:clientId uuid:message.uuid channel:message.data.channel message:message.data.message timeToken:message.data.timetoken];
}

- (void) sendSignal:(PNSignalResult *)signal clientId:(NSString *)clientId {
    [self send:clientId uuid:signal.uuid channel:signal.data.channel message:signal.data.message timeToken:signal.data.timetoken];
}

- (void) send:(NSString *)clientId uuid:(NSString *)uuid channel:(NSString *)channel message: (id)message timeToken:(NSNumber *)timeToken {
    if(self.eventSink) {
        
        NSString *jsonString = @"";
        
        if([message isKindOfClass:[NSDictionary class]]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message
                                                    options:0
                                                    error:&error];

            if (jsonData) {
               jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
        
        NSDictionary * result = @{CLIENT_ID_KEY: clientId, UUID_KEY: uuid, CHANNEL_KEY: channel, MESSAGE_KEY: jsonString, TIME_TOKEN_KEY: timeToken};

        self.eventSink(result);
    }
}


@end

@implementation StatusStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    self.eventSink = nil;
    return nil;
}

- (void) sendStatus:(PNStatus *)status clientId:(NSString *)clientId {
    NSLog(@"sendStatus (StatusStreamHandler), status: %@, clientId:%@, eventSink: %@", status, clientId, self.eventSink);
    if(self.eventSink) {
        NSArray<NSString *> *affectedChannels;
        if (status.category == PNConnectedCategory || status.category == PNReconnectedCategory) {
            PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
            affectedChannels = subscribeStatus.subscribedChannels;
        }

      self.eventSink(@{CLIENT_ID_KEY: clientId, STATUS_CATEGORY_KEY: [PubnubPlugin getCategoryAsNumber:status.category],STATUS_OPERATION_KEY: [PubnubPlugin getOperationAsNumber:status.operation], UUID_KEY: status.uuid, CHANNELS_KEY: affectedChannels == NULL ? @[] : affectedChannels, STATUS_CODE_KEY: @(status.statusCode), REQUEST_KEY: status.clientRequest.URL.absoluteString});
    }
}

@end

@implementation PresenceStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    self.eventSink = nil;
    return nil;
}

- (void) sendPresence:(PNPresenceEventResult *)presence clientId:(NSString *)clientId {
    if(self.eventSink) {
        NSLog(@"Presence state: %@", presence.data.presence.state);
        self.eventSink(@{CLIENT_ID_KEY: clientId, CHANNEL_KEY: presence.data.channel, EVENT_KEY: presence.data.presenceEvent, UUID_KEY: presence.data.presence.uuid, OCCUPANCY_KEY: presence.data.presence.occupancy, STATE_KEY: presence.data.presence.state == NULL ? [NSDictionary new] : presence.data.presence.state});
    }
}

@end

@implementation ErrorStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    self.eventSink = nil;
    return nil;
}

- (void) sendError:(NSDictionary *)error {
    if(self.eventSink) {
        self.eventSink(error);
    }
}

@end

@implementation MessageActionStreamHandler

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    self.eventSink = nil;
    return nil;
}

- (void) sendMessageAction:(PNMessageActionResult *)action clientId:(NSString *)clientId {
  
  if(self.eventSink) {
      NSLog(@"Action Type: %@ Action Value: %@ TimeToken: %@", action.data.action.type, action.data.action.value, action.data.timetoken);
    self.eventSink(@{CLIENT_ID_KEY: clientId, TIME_TOKEN_KEY: action.data.action.messageTimetoken, ACTION_TYPE_KEY: action.data.action.type, ACTION_VALUE_KEY: action.data.action.value, CHANNEL_KEY: action.data.channel});
  }
}

@end

@implementation MissingArgumentException
@end
