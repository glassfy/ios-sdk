//
//  GYPaywallViewController.h
//  Glassfy
//
//  Created by Luca Garbolino on 13/10/21.
//
#if TARGET_OS_IPHONE
API_UNAVAILABLE_BEGIN(macos, watchos)

#import "GYPaywallViewController.h"
@class GYAPIPaywallResponse;
@class GYSku;

NS_ASSUME_NONNULL_BEGIN

@interface GYPaywallViewController (Private)
+ (instancetype)paywallWithResponse:(GYAPIPaywallResponse *)res;
@end

NS_ASSUME_NONNULL_END


API_UNAVAILABLE_END
#endif
