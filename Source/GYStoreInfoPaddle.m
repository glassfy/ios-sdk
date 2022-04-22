//
//  GYStoreInfoPaddle.m
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import "GYStoreInfoPaddle.h"

@implementation GYStoreInfoPaddle

- (NSString *)userId
{
    NSString *userId = nil;
    if ([self.rawInfo[@"userid"] isKindOfClass:NSString.class]) {
        userId = self.rawInfo[@"userid"];
    }
    return userId;
}

- (NSString *)planId
{
    NSString *planId = nil;
    if ([self.rawInfo[@"planid"] isKindOfClass:NSString.class]) {
        planId = self.rawInfo[@"planid"];
    }
    return planId;
}

- (NSString *)subscriptionId
{
    NSString *subscriptionId = nil;
    if ([self.rawInfo[@"subscriptionid"] isKindOfClass:NSString.class]) {
        subscriptionId = self.rawInfo[@"subscriptionid"];
    }
    return subscriptionId;
}

- (NSURL *)updateURL
{
    NSURL *updateURL = nil;
    if ([self.rawInfo[@"updateurl"] isKindOfClass:NSString.class]) {
        updateURL = [NSURL URLWithString:self.rawInfo[@"updateurl"]];
    }
    return updateURL;
}

- (NSURL *)cancelURL
{
    NSURL *cancelURL = nil;
    if ([self.rawInfo[@"cancelurl"] isKindOfClass:NSString.class]) {
        cancelURL = [NSURL URLWithString:self.rawInfo[@"cancelurl"]];
    }
    return cancelURL;
}


@end
