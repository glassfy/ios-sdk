//
//  GLSku.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import "GLSku+Private.h"
#import "GLError.h"

@interface GLSku()
@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *productId;
@property(nonatomic, assign) GLSkuEligibility introductoryEligibility;
@property(nonatomic, assign) GLSkuEligibility promotionalEligibility;
@property(nonatomic, strong) NSDictionary<NSString*, NSString*>* extravars;
@property(nonatomic, nullable, strong) SKProduct *product;
@end

@implementation GLSku (Private)

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
    
    GLSkuEligibility introductoryEligibility = GLSkuEligibilityUnknown;
    NSString *isintroductoryeligibleJSON = obj[@"isintroductoryeligible"];
    if ([isintroductoryeligibleJSON isKindOfClass:NSString.class]) {
        if ([isintroductoryeligibleJSON isEqualToString:@"true"]) {
            introductoryEligibility = GLSkuEligibilityEligible;
        }
        else if ([isintroductoryeligibleJSON isEqualToString:@"false"]) {
            introductoryEligibility = GLSkuEligibilityNonEligible;
        }
    }
    
    GLSkuEligibility promotionalEligibility = GLSkuEligibilityUnknown;
    NSString *ispromotionaleligibleJSON = obj[@"ispromotionaleligible"];
    if ([ispromotionaleligibleJSON isKindOfClass:NSString.class]) {
        if ([ispromotionaleligibleJSON isEqualToString:@"true"]) {
            promotionalEligibility = GLSkuEligibilityEligible;
        }
        else if ([ispromotionaleligibleJSON isEqualToString:@"false"]) {
            promotionalEligibility = GLSkuEligibilityNonEligible;
        }
    }

    if (!identifier || !productId) {
        if (error) {
            *error = [GLError serverError:GLErrorCodeUnknow description:@"Unexpected GLSku data format: missing identifier/productId"];
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

@implementation GLSku
@end
