//
//  GLOfferings.m
//  Glassfy
//
//  Created by Luca Garbolino on 23/02/21.
//

#import "GLOffers+Private.h"
#import "GLOffering+Private.h"
#import "GLSku+Private.h"
#import <StoreKit/StoreKit.h>

@interface GLOfferings()
@property(nonatomic, readwrite, strong) NSArray<GLOffering*> *all;
@end

@implementation GLOfferings (Private)

+ (instancetype)offeringsWithOffers:(NSArray<GLOffering *> *)offerings products:(NSArray<SKProduct *> *)products
{
    GLOfferings *offers = [GLOfferings new];
    offers.all = [NSArray arrayWithArray:offerings];
    [offers matchSkusInOfferings:offers.all withProducts:products];
    return offers;
}

- (void)matchSkusInOfferings:(NSArray<GLOffering*>*)offerings withProducts:(NSArray<SKProduct*>*)products
{
    for (GLOffering *o in offerings) {
        // match sku with product
        for (GLSku *s in o.skus) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"productIdentifier = %@", s.productId];
            s.product = [products filteredArrayUsingPredicate:p].firstObject;
        }
        
        // filter sku without product
        NSPredicate *p = [NSPredicate predicateWithFormat:@"product != nil"];
        o.skus = [o.skus filteredArrayUsingPredicate:p];
    }
}

@end

@implementation GLOfferings

@end
