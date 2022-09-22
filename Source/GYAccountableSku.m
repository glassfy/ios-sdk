//
//  GYAccountableSku.m
//  Glassfy
//
//  Created by Luca Garbolino on 21/09/22.
//

#import "GYAccountableSku+Private.h"
#import "GYSkuBase+Private.h"

@interface GYAccountableSku()
@property(nonatomic, assign) BOOL isInIntroOfferPeriod;
@property(nonatomic, assign) BOOL isInTrialPeriod;
@end

@implementation GYAccountableSku (Private)
- (instancetype)initWithObject:(nonnull NSDictionary *)obj error:(NSError **)error {
    self = [super initWithObject:obj error:error];
    if (self) {
        NSNumber *isInIntroOffer = obj[@"isinintrooffer"];
        if ([isInIntroOffer isKindOfClass:NSNumber.class]) {
            self.isInIntroOfferPeriod = isInIntroOffer.boolValue;
        }
        
        NSNumber *isTrial = obj[@"istrial"];
        if ([isTrial isKindOfClass:NSNumber.class]) {
            self.isInTrialPeriod = isTrial.boolValue;
        }
    }
    return self;
}
@end

@implementation GYAccountableSku

@end
