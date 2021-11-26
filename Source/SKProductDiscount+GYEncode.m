//
//  SKProductDiscount+Encode.m
//  Glassfy
//
//  Created by Luca Garbolino on 22/12/20.
//

#import "SKProductDiscount+GYEncode.h"
#import "SKProductSubscriptionPeriod+GYEncode.h"

@implementation SKProductDiscount (GYEncode)

API_AVAILABLE(ios(11.2), macos(10.13.2), watchos(6.2))
NSString *GYProductDiscountPaymentMode(SKProductDiscountPaymentMode type) {
    NSString *discountPaymentMode;
    switch (type) {
        case SKProductDiscountPaymentModePayAsYouGo:
            discountPaymentMode = @"payasyougo";
            break;
        case SKProductDiscountPaymentModePayUpFront:
            discountPaymentMode = @"payupfront";
            break;
        case SKProductDiscountPaymentModeFreeTrial:
            discountPaymentMode = @"freetrial";
            break;
        default:
            discountPaymentMode = @"unknow";
    }
    return discountPaymentMode;
}

API_AVAILABLE(ios(12.2), macos(10.14.4), watchos(6.2))
NSString *GYProductDiscountType(SKProductDiscountType type) {
    NSString *discountTypeStr;
    switch (type) {
        case SKProductDiscountTypeIntroductory:
            discountTypeStr = @"introductory";
            break;
        case SKProductDiscountTypeSubscription:
            discountTypeStr = @"subscription";
            break;
        default:
            discountTypeStr = @"unknow";
    }
    return discountTypeStr;
}

- (id)encodedObject
{
    NSMutableDictionary *discountInfo = [NSMutableDictionary dictionary];
    
    discountInfo[@"price"] = self.price;
    discountInfo[@"pricelocale"] = [self.priceLocale objectForKey:NSLocaleCurrencyCode];
    if (@available(iOS 12.2, macOS 10.14.4, watchOS 6.2, *)) {
        discountInfo[@"identifier"] = self.identifier;
        discountInfo[@"type"] = GYProductDiscountType(self.type);
    }
    discountInfo[@"subscriptionperiod"] = [self.subscriptionPeriod encodedObject];
    discountInfo[@"numberofperiods"] = @(self.numberOfPeriods);
    discountInfo[@"paymentmode"] = GYProductDiscountPaymentMode(self.paymentMode);
    
    return discountInfo;
}

@end
