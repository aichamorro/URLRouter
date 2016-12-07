//
//  ReactNativeURLRouter.m
//  ReactNativeExample
//
//  Created by Alberto Chamorro on 07/12/2016.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "ReactNativeURLRouter.h"
#import "RCTBridgeModule.h"

@interface ReactNativeURLRouter()<RCTBridgeModule>

@property (nonatomic, copy) URLRouter router;

@end

@implementation ReactNativeURLRouter

- (instancetype)initWithRouter:(URLRouter)router
{
  if (self = [super init])
  {
    _router = router;
  }
  
  return self;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(open:(NSString * _Nonnull)url callback:(RCTResponseSenderBlock)callback)
{
  URLResultHandler resultHandler = ^(id result) {
    callback(@[[NSNull null], result]);
  };
  
  if (!self.router([NSURL URLWithString:url], resultHandler)) {
    callback(@[@"The request couldn't be handled"]);
  }
}


@end
