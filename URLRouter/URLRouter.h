//
//  URLRouter.h
//  URLRouter
//
//  Created by Alberto Chamorro on 20/11/2016.
//  Copyright © 2016 Alberto Chamorro. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for URLRouter.
FOUNDATION_EXPORT double URLRouterVersionNumber;

//! Project version string for URLRouter.
FOUNDATION_EXPORT const unsigned char URLRouterVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <URLRouter/PublicHeader.h>
typedef id(^URLRouterResult)(NSURL * _Nonnull url, NSDictionary<String *, String *> * _Nonnull parameters);
typedef void(^URLRouterResultHandler)(id result);
typedef BOOL(^URLRouter)(NSURL * _Nonnull url, URLRouterResultHandler handler);
