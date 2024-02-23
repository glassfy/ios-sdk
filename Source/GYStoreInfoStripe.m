//
//  GYStoreInfoStripe.m
//  Glassfy
//
//  Created by Luca Garbolino on 21/02/24.
//

#import "GYStoreInfoStripe.h"

#define kProductId @"productid"
#define kSubscriptionId @"subscriptionid"
#define kCustomerId @"customerid"

@implementation GYStoreInfoStripe

- (NSString *)customerId
{
    NSString *customerId = nil;
    if ([self.rawInfo[kCustomerId] isKindOfClass:NSString.class]) {
        customerId = self.rawInfo[kCustomerId];
    }
    return customerId;
}

- (NSString *)subscriptionId
{
    NSString *subscriptionId = nil;
    if ([self.rawInfo[kSubscriptionId] isKindOfClass:NSString.class]) {
        subscriptionId = self.rawInfo[kSubscriptionId];
    }
    return subscriptionId;
}

- (NSString *)producId
{
    NSString *producId = nil;
    if ([self.rawInfo[kProductId] isKindOfClass:NSString.class]) {
        producId = self.rawInfo[kProductId];
    }
    return producId;
}

@end
