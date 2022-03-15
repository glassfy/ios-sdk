//
//  GYSku.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import "GYSku+Private.h"
#import "GYError.h"
#import "SKProduct+GYEncode.h"

@interface GYSku()
@property(nonatomic, strong) NSString *skuId;
@property(nonatomic, strong) NSString *productId;
@property(nonatomic, nullable, strong) NSString *promotionalId;
@property(nonatomic, nullable, strong) NSString *offeringId;
@property(nonatomic, assign) GYSkuEligibility introductoryEligibility;
@property(nonatomic, assign) GYSkuEligibility promotionalEligibility;
@property(nonatomic, strong) NSDictionary<NSString*, NSString*>* extravars;
@property(nonatomic, nullable, strong) SKProduct *product;
@end

@implementation GYSku (Private)

- (instancetype)initWithObject:(nonnull NSDictionary *)obj error:(NSError **)error {
    NSString *identifier;
    if ([obj[@"identifier"] isKindOfClass:NSString.class]) {
        identifier = obj[@"identifier"];
    }
    NSString *productId;
    if ([obj[@"productid"] isKindOfClass:NSString.class]) {
        productId = obj[@"productid"];
    }
    NSString *promotionalId;
    if ([obj[@"promotionalid"] isKindOfClass:NSString.class] && [obj[@"promotionalid"] length]) {
        promotionalId = obj[@"promotionalid"];
    }
    
    NSDictionary<NSString*, NSString*>* extravars = @{};
    if ([obj[@"extravars"] isKindOfClass:NSDictionary.class]) {
        extravars = obj[@"extravars"];
    }
    
    GYSkuEligibility introductoryEligibility = GYSkuEligibilityUnknown;
    NSString *isintroductoryeligibleJSON = obj[@"isintroductoryeligible"];
    if ([isintroductoryeligibleJSON isKindOfClass:NSString.class]) {
        if ([isintroductoryeligibleJSON isEqualToString:@"true"]) {
            introductoryEligibility = GYSkuEligibilityEligible;
        }
        else if ([isintroductoryeligibleJSON isEqualToString:@"false"]) {
            introductoryEligibility = GYSkuEligibilityNonEligible;
        }
    }
    
    GYSkuEligibility promotionalEligibility = GYSkuEligibilityUnknown;
    NSString *ispromotionaleligibleJSON = obj[@"ispromotionaleligible"];
    if ([ispromotionaleligibleJSON isKindOfClass:NSString.class]) {
        if ([ispromotionaleligibleJSON isEqualToString:@"true"]) {
            promotionalEligibility = GYSkuEligibilityEligible;
        }
        else if ([ispromotionaleligibleJSON isEqualToString:@"false"]) {
            promotionalEligibility = GYSkuEligibilityNonEligible;
        }
    }

    if (!identifier || !productId) {
        if (error) {
            *error = [GYError serverError:GYErrorCodeUnknow description:@"Unexpected GYSku data format: missing identifier/productId"];
        }
        
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.extravars = extravars;
        self.skuId = identifier;
        self.productId = productId;
        self.promotionalId = promotionalId;
        self.introductoryEligibility = introductoryEligibility;
        self.promotionalEligibility = promotionalEligibility;
    }
    return self;
}

+ (instancetype)skuWithProduct:(SKProduct *)product
{
    GYSku *sku = [[self alloc] init];
    if (sku) {
        sku.product = product;
        sku.extravars = @{};
        sku.skuId = @"";
        sku.productId = product.productIdentifier;
        sku.introductoryEligibility = GYSkuEligibilityUnknown;
        sku.promotionalEligibility = GYSkuEligibilityUnknown;
    }
    return sku;
}

- (id)encodedObject
{
    NSMutableDictionary *skuInfo = [NSMutableDictionary dictionary];
    skuInfo[@"productinfo"] = [self.product encodedObject];
    skuInfo[@"offeringidentifier"] = self.offeringId;
    skuInfo[@"promotionalid"] = self.promotionalId;
    
    return skuInfo;
}

+ (NSArray<GYSku*> *)matchSkus:(NSArray<GYSku*>*)skus withProducts:(NSArray<SKProduct*> *)products
{
    // match sku with product
    for (GYSku *s in skus) {
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
    return [skus filteredArrayUsingPredicate:p];
}

@end

@implementation GYSku

- (SKProductDiscount *)discount
{
    NSPredicate *p = [NSPredicate predicateWithFormat:@"identifier = %@", self.promotionalId];
    return [self.product.discounts filteredArrayUsingPredicate:p].firstObject;
}


#pragma mark - Deprecations

- (NSString *)identifier
{
    return self.skuId;
}

@end
