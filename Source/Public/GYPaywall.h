//
//  GYPaywall.h
//  Glassfy
//
//  Created by Luca Garbolino on 27/06/22.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYTypes.h>
#else
#import "GYTypes.h"
#endif
NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_IPHONE
@class GYPaywallViewController;
#endif

NS_SWIFT_NAME(Glassfy.Paywall)
@interface GYPaywall : NSObject
#if TARGET_OS_IPHONE
- (void)setContentAvailableHandler:(GYPaywallViewControllerCompletion)handler;
- (GYPaywallViewController *)viewController;
#endif
@end

NS_ASSUME_NONNULL_END
