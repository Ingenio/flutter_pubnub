#import <Flutter/Flutter.h>

#import <Flutter/Flutter.h>
#import <PubNub/PubNub.h>

@class MessageStreamHandler;
@class StatusStreamHandler;
@class ErrorStreamHandler;
@class PresenceStreamHandler;

@interface PubnubPlugin : NSObject<FlutterPlugin>
@property (nonatomic, strong) MessageStreamHandler *messageStreamHandler;
@property (nonatomic, strong) StatusStreamHandler *statusStreamHandler;
@property (nonatomic, strong) PresenceStreamHandler *presenceStreamHandler;
@property (nonatomic, strong) ErrorStreamHandler *errorStreamHandler;
@end

@interface MessageStreamHandler : NSObject<FlutterStreamHandler>
@property (nonatomic, strong) FlutterEventSink eventSink;

- (void) sendMessage:(PNMessageResult *)message clientId:(NSString *)clientId;

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

@interface MissingArgumentException : NSException
@end
