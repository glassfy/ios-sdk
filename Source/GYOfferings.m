//
//  GYOfferings.m
//  Glassfy
//
//  Created by Luca Garbolino on 23/02/21.
//

#import "GYOfferings+Private.h"
#import "GYOffering+Private.h"
#import <StoreKit/StoreKit.h>

@interface GYOfferings()
@property(nonatomic, readwrite, strong) NSArray<GYOffering*> *all;
@end

@implementation GYOfferings (Private)

+ (instancetype)offeringsWithOffers:(NSArray<GYOffering*> *)offerings products:(NSArray<SKProduct*> *)products
{
    GYOfferings *offers = [[self alloc] init];
    offers.all = [NSArray arrayWithArray:offerings];
    for (GYOffering *o in offers.all) {
        [o matchSkusWithProducts:products];
    }
    return offers;
}

@end

@implementation GYOfferings

#pragma mark - Custom Keyed Subscripting method

- (GYOffering *)objectForKeyedSubscript:(NSString *)offeringid
{
    GYOffering *result = nil;
    if (!self.all || self.all.count == 0) {
        return result;
    }
    
    for (GYOffering *o in self.all) {
        if ([o.offeringId isEqualToString:offeringid]) {
            result = o;
            break;
        }
    }
    
    return result;
}

@end
