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
    GYOfferings *offers = [[self alloc] init];
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
        
        // filter sku without product and sku with promotionalid and no discount
        NSPredicate *p = [NSPredicate predicateWithBlock:^BOOL(GYSku *s, NSDictionary<NSString*,id> * _Nullable bindings) {
            if (!s.product) {
                return NO;
            }
            if (@available(iOS 12.2, macOS 10.14.4, watchOS 6.2, *)) {
                return s.promotionalId == nil ?: s.discount != nil;
            }
            return s.promotionalId == nil;
        }];
        o.skus = [o.skus filteredArrayUsingPredicate:p];
    }
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
