#import "AppDelegate.h"
#import "HumanModule.h"

#import <React/RCTBundleURLProvider.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"HUMAN_Demo";
  self.initialProps = @{};

  HSPolicy *policy = [[HSPolicy alloc] init];
  policy.automaticInterceptorPolicy.interceptorType = HSAutomaticInterceptorTypeNone;
  policy.doctorAppPolicy.enabled = YES;
  NSError *error = nil;
  [HumanSecurity startWithAppId:@"PXj9y4Q8Em" policy:policy error:&error];
  HumanSecurity.BD.delegate = self;
  if (error != nil) {
    NSLog(@"failed to start. error: %@", error.localizedDescription);
  }

  BOOL result = [super application:application didFinishLaunchingWithOptions:launchOptions];

  [[HumanModule shared] startObserving];

  return result;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return [self bundleURL];
}

- (NSURL *)bundleURL
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

// MARK: - HSBotDefenderDelegate

- (void)botDefenderDidUpdateHeaders:(NSDictionary<NSString *,NSString *> *)headers forAppId:(NSString *)appId {
  if ([HumanModule shared] != nil) {
    [[HumanModule shared] handleUpdatedHeaders:headers];
  }
}

- (void)botDefenderChallengeSolvedForAppId:(NSString *)appId {
  [[HumanModule shared] handleChallengeSolvedEvent];
}

- (void)botDefenderChallengeCancelledForAppId:(NSString *)appId {
  [[HumanModule shared] handleChallengeCancelledEvent];
}

- (void)botDefenderChallengeRenderedForAppId:(NSString *)appId {
}

- (void)botDefenderChallengeRenderFailedForAppId:(NSString *)appId {
}

@end
