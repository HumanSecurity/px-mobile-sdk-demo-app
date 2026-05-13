#import "HumanModule.h"
@import HUMAN;

static NSString *humanNewHeaders = @"HumanNewHeaders";
static NSString *humanChallengeResult = @"HumanChallengeResult";
static NSString *humanSolved = @"solved";
static NSString *humanCancelled = @"cancelled";
static NSString *humanFalse = @"false";

@implementation HumanModule

// MARK: - NSObject

- (instancetype)init {
  self = [super init];
  shared = self;
  return self;
}

// MARK: - RCTEventEmitter

- (NSArray<NSString *> *)supportedEvents {
  return @[humanNewHeaders, humanChallengeResult];
}

// MARK: - PX Module

static HumanModule *shared = nil;

+ (HumanModule *)shared {
  return shared;
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

- (void)handleUpdatedHeaders:(NSDictionary<NSString *,NSString *> *)headers {
  NSData *data = [NSJSONSerialization dataWithJSONObject:headers options:0 error:nil];
  NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  [self sendEventWithName:humanNewHeaders body:json];
}

- (void)handleChallengeSolvedEvent {
  [self sendEventWithName:humanChallengeResult body:humanSolved];
}

- (void)handleChallengeCancelledEvent {
  [self sendEventWithName:humanChallengeResult body:humanCancelled];
}

RCT_EXPORT_MODULE(HumanModule);

RCT_REMAP_METHOD(getHTTPHeaders,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  NSDictionary<NSString *, NSString *> *headers = [HumanSecurity.BD headersForURLRequestForAppId:nil];
  NSData *data = [NSJSONSerialization dataWithJSONObject:headers options:0 error:nil];
  NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  resolve(@[json]);
}

RCT_REMAP_METHOD(handleResponse,
                 rsponse:(NSString *)response
                 code:(NSInteger)code
                 url:(NSString *)url
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
  NSHTTPURLResponse *httpURLResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:url] statusCode:code HTTPVersion:nil headerFields:nil];
  BOOL handled = [HumanSecurity.BD handleBlockResponseWithData:data url:url callback:^(enum HSBotDefenderChallengeResult result) {
    resolve((result == HSBotDefenderChallengeResultSolved ? humanSolved : humanCancelled));
  }];
  if (!handled) {
    resolve(humanFalse);
  }
}

@end
