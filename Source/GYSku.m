//
//  GYSku.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import "GYSku+Private.h"
#import "GYError.h"

@interface GYSku()
@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *productId;
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
        self.identifier = identifier;
        self.productId = productId;
        self.introductoryEligibility = introductoryEligibility;
        self.promotionalEligibility = promotionalEligibility;
    }
    return self;
}

@end

@implementation GYSku
@end
