//
//  GYPaywallViewController.h
//  Glassfy
//
//  Created by Luca Garbolino on 13/10/21.
//


#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYTypes.h>
#else
#import "GYTypes.h"
#endif
@class GYTransaction;
@class GYSku;

NS_ASSUME_NONNULL_BEGIN

API_UNAVAILABLE(macos, watchos)
NS_SWIFT_NAME(Glassfy.PaywallViewController)
@interface GYPaywallViewController : UIViewController

- (void)setCloseHandler:(GYPaywallCloseBlock)handler;
- (void)setLinkHandler:(GYPaywallLinkBlock)handler;
- (void)setPurchaseHandler:(GYPaywallPurchaseBlock)handler;
- (void)setRestoreHandler:(GYPaywallRestoreBlock)handler;

@end

NS_ASSUME_NONNULL_END

#endif
