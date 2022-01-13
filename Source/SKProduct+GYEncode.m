//
//  SKProduct+Encode.m
//  Glassfy
//
//  Created by Luca Garbolino on 22/12/20.
//

#import "SKProduct+GYEncode.h"
#import "SKProductSubscriptionPeriod+GYEncode.h"
#import "SKProductDiscount+GYEncode.h"

@implementation SKProduct (GYEncode)

- (id)encodedObject
{
    NSMutableDictionary *productInfo = [NSMutableDictionary dictionary];
    
    productInfo[@"price"] = self.price;
    productInfo[@"localeidentifier"] = [self.priceLocale objectForKey:NSLocaleIdentifier];
    productInfo[@"pricelocale"] = [self.priceLocale objectForKey:NSLocaleCurrencyCode];
    productInfo[@"countrycode"] = [self.priceLocale objectForKey:NSLocaleCountryCode];
    productInfo[@"productidentifier"] = self.productIdentifier;
    if (@available(iOS 6, macOS 10.15, watchOS 6.2, *)) {
        productInfo[@"isdownloadable"] = @(self.isDownloadable);
    }
    
    if (@available(iOS 14.0, macOS 10.16, watchOS 7.0, *)) {
        productInfo[@"isfamilyshareable"] = @(self.isFamilyShareable);
    }
    
    if (@available(iOS 11.2, macOS 10.13.2, watchOS 6.2, *)) {
        if (self.subscriptionPeriod) {
            productInfo[@"subscriptionperiod"] = [self.subscriptionPeriod encodedObject];
        }
        
        if (self.introductoryPrice) {
            productInfo[@"introductoryprice"] = [self.introductoryPrice encodedObject];
        }
    }
    
    if (@available(iOS 12.0, macOS 10.14, watchOS 6.2, *)) {
        productInfo[@"subscriptiongroupidentifier"] = self.subscriptionGroupIdentifier;
    }
    
    if (@available(iOS 12.2, macOS 10.14.4, watchOS 6.2, *)) {
        NSMutableArray *discounts = [NSMutableArray array];
        for (SKProductDiscount *discount in self.discounts) {
            NSDictionary *introductoryPriceInfo = [discount encodedObject];
            [discounts addObject:introductoryPriceInfo];
        }
        if (discounts.count > 0) {
            productInfo[@"discounts"] = [NSArray arrayWithArray:discounts];
        }
    }
    
    return productInfo;
}

@end
