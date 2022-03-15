//
//  GYFormatter.h
//  Glassfy
//
//  Created by Luca Garbolino on 27/10/21.
//

#import <Foundation/Foundation.h>

API_AVAILABLE(ios(11.2), macos(10.13.2), watchos(6.2))
typedef NS_OPTIONS(NSUInteger, SKProductPeriodUnit);

NS_ASSUME_NONNULL_BEGIN

@interface GYFormatter : NSObject
+ (NSString *)formatPrice:(NSNumber *)price locale:(NSLocale *)locale;
+ (NSString *)formatPercentage:(NSNumber *)price locale:(NSLocale *)locale;

+ (NSString *)formatPeriod:(NSInteger)perdiod unit:(SKProductPeriodUnit)unit locale:(NSLocale *)locale API_AVAILABLE(ios(11.2), macos(10.13.2), watchos(6.2));
+ (NSString *)formatUnit:(SKProductPeriodUnit)unit locale:(NSLocale *)locale API_AVAILABLE(ios(11.2), macos(10.13.2), watchos(6.2));


@end

NS_ASSUME_NONNULL_END
