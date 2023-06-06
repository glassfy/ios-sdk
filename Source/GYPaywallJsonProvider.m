//
//  GYPaywallJsonProvider.m
//  Glassfy
//
//  Created by Federico Curzel on 10/05/23.
//

#import <Foundation/Foundation.h>
#import "Glassfy+Private.h"
#import "GYPaywallJsonProvider.h"
#import "GYPaywallHtmlJsonProvider.h"
#import "GYPaywallNoCodeJsonProvider.h"
#import "GYPaywall+Private.h"

@implementation GYPaywallJsonProvider: NSObject

+ (NSDictionary *)json:(GYPaywall *)paywall {
    NSString *uiStyle = [self uiStyle];

    if ([paywall type] == GYPaywallTypeNoCode) {
        return [GYPaywallNoCodeJsonProvider jsonWithPwid:paywall.pwid
                                                  locale:paywall.locale
                                                 uiStyle:uiStyle
                                                    skus:paywall.skus];
    } else {
        return [GYPaywallHtmlJsonProvider jsonWithPwid:paywall.pwid
                                                locale:paywall.locale
                                               uiStyle:uiStyle
                                                  skus:paywall.skus];
    }
}

+ (NSString *)uiStyle {
#if TARGET_OS_IPHONE
    if (@available(iOS 13.0, *)) {
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return @"dark";
        }
    }
#endif
    return @"light";
}

@end
