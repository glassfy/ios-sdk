//
//  GYPaywallJsonProvider.h
//  Glassfy
//
//  Created by Federico Curzel on 10/05/23.
//

#import <Foundation/Foundation.h>
@class GYPaywall;

NS_ASSUME_NONNULL_BEGIN
@interface GYPaywallJsonProvider: NSObject
+ (NSDictionary *)json:(GYPaywall *)paywall;
@end
NS_ASSUME_NONNULL_END
