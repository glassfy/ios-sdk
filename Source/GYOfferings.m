//
//  GYOfferings.m
//  Glassfy
//
//  Created by Luca Garbolino on 23/02/21.
//

#import "GYOfferings+Private.h"
#import "GYOffering+Private.h"
#import "GYSku+Private.h"
#import <StoreKit/StoreKit.h>

@interface GYOfferings()
@property(nonatomic, readwrite, strong) NSArray<GYOffering*> *all;
@end

@implementation GYOfferings (Private)

+ (instancetype)offeringsWithOffers:(NSArray<GYOffering *> *)offerings products:(NSArray<SKProduct *> *)products
{
    GYOfferings *offers = [GYOfferings new];
    offers.all = [NSArray arrayWithArray:offerings];
    [offers matchSkusInOfferings:offers.all withProducts:products];
    return offers;
}

- (void)matchSkusInOfferings:(NSArray<GYOffering*>*)offerings withProducts:(NSArray<SKProduct*>*)products
{
    for (GYOffering *o in offerings) {
        // match sku with product
        for (GYSku *s in o.skus) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"productIdentifier = %@", s.productId];
            s.product = [products filteredArrayUsingPredicate:p].firstObject;
        }
        
        // filter sku without product
        NSPredicate *p = [NSPredicate predicateWithFormat:@"product != nil"];
        o.skus = [o.skus filteredArrayUsingPredicate:p];
    }
}

@end

@implementation GYOfferings

#pragma mark - Custom Keyed Subscripting method

- (GYOffering *)objectForKeyedSubscript:(NSString *)identifier
{
    GYOffering *result = nil;
    if (!self.all || self.all.count == 0) {
        return result;
    }
    
    for (GYOffering *o in self.all) {
        if ([o.identifier isEqualToString:identifier]) {
            result = o;
            break;
        }
    }
    
    return result;
}

@end
