#import <Flutter/Flutter.h>

#import <Flutter/Flutter.h>
#import <PubNub/PubNub.h>

@class MessageStreamHandler;
@class StatusStreamHandler;
@class ErrorStreamHandler;
@class PresenceStreamHandler;
@class MessageActionStreamHandler;

@interface PubnubPlugin : NSObject<FlutterPlugin>
@property (nonatomic, strong) MessageStreamHandler *messageStreamHandler;
@property (nonatomic, strong) StatusStreamHandler *statusStreamHandler;
@property (nonatomic, strong) PresenceStreamHandler *presenceStreamHandler;
@property (nonatomic, strong) ErrorStreamHandler *errorStreamHandler;
@property (nonatomic, strong) MessageActionStreamHandler *messageActionStreamHandler;
@end

@interface MessageStreamHandler : NSObject<FlutterStreamHandler>
@property (nonatomic, strong) FlutterEventSink eventSink;

- (void) sendMessage:(PNMessageResult *)message clientId:(NSString *)clientId;
- (void) sendSignal:(PNSignalResult *)signal clientId:(NSString *)clientId;

@end

@interface StatusStreamHandler : NSObject <FlutterStreamHandler>
@property (nonatomic, strong) FlutterEventSink eventSink;

- (void) sendStatus:(PNStatus *)status clientId:(NSString *)clientId;

@end

@interface PresenceStreamHandler : NSObject <FlutterStreamHandler>
@property (nonatomic, strong) FlutterEventSink eventSink;

- (void) sendPresence:(PNPresenceEventResult *)presence clientId:(NSString *)clientId;

@end

@interface ErrorStreamHandler : NSObject <FlutterStreamHandler>
@property (nonatomic, strong) FlutterEventSink eventSink;

- (void) sendError:(NSDictionary *)error;

@end

@interface MessageActionStreamHandler : NSObject <FlutterStreamHandler>
@property (nonatomic, strong) FlutterEventSink eventSink;

- (void) sendMessageAction:(PNMessageActionResult *)action clientId:(NSString *)clientId;

@end

@interface MissingArgumentException : NSException
@end

