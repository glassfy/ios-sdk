//
//  GYStoreInfoPaddle.m
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import "GYStoreInfoPaddle.h"

#define kUserId @"userid"
#define kPlanId @"planid"
#define kSubscriptionId @"subscriptionid"
#define kUpdateURL @"updateurl"
#define kCancelURL @"cancelurl"

@implementation GYStoreInfoPaddle

- (NSString *)userId
{
    NSString *userId = nil;
    if ([self.rawInfo[kUserId] isKindOfClass:NSString.class]) {
        userId = self.rawInfo[kUserId];
    }
    return userId;
}

- (NSString *)planId
{
    NSString *planId = nil;
    if ([self.rawInfo[kPlanId] isKindOfClass:NSString.class]) {
        planId = self.rawInfo[kPlanId];
    }
    return planId;
}

- (NSString *)subscriptionId
{
    NSString *subscriptionId = nil;
    if ([self.rawInfo[kSubscriptionId] isKindOfClass:NSString.class]) {
        subscriptionId = self.rawInfo[kSubscriptionId];
    }
    return subscriptionId;
}

- (NSURL *)updateURL
{
    NSURL *updateURL = nil;
    if ([self.rawInfo[kUpdateURL] isKindOfClass:NSString.class]) {
        updateURL = [NSURL URLWithString:self.rawInfo[kUpdateURL]];
    }
    return updateURL;
}

- (NSURL *)cancelURL
{
    NSURL *cancelURL = nil;
    if ([self.rawInfo[kCancelURL] isKindOfClass:NSString.class]) {
        cancelURL = [NSURL URLWithString:self.rawInfo[kCancelURL]];
    }
    return cancelURL;
}


@end
