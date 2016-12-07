/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"
@import URLRouter;
#import "ReactNativeURLRouter.h"

typedef BOOL(^URLRouter)(NSURL * _Nonnull, void (^ _Nullable)(id _Nullable));

@interface AppDelegate()<RCTBridgeDelegate>

@property (nonatomic, copy) URLRouter router;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  URLRouterEntryClass *entry = [URLRouterFactoryClass entryWithPattern:@"app://user/:id/" resultBuilder:^id _Nullable(NSURL * _Nonnull url, NSDictionary<NSString *,NSString *> * _Nonnull parameters) {
    return [NSString stringWithFormat:@"Requested user with id: %@", parameters[@"id"]];
  }];
  
  self.router = [URLRouterFactoryClass routerWithEntries:@[entry]];
  
  id<RCTBridgeDelegate> bridgeDelegate = self;
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:bridgeDelegate launchOptions:nil];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"ReactNativeExample" initialProperties:nil];

  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

#pragma mark RCTBridgeDelegate methods
- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];
}

- (NSArray<id<RCTBridgeModule>> *)extraModulesForBridge:(RCTBridge *)bridge
{
  ReactNativeURLRouter *urlRouterReactNative = [[ReactNativeURLRouter alloc] initWithRouter:self.router];
  
  return @[urlRouterReactNative];
}

@end
