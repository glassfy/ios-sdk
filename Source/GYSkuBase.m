//
//  GYSkuBase.m
//  Glassfy
//
//  Created by Luca Garbolino on 20/04/22.
//

#import "GYSkuBase.h"
#import "GYError.h"

@interface GYSkuBase()
@property(nonatomic, strong) NSString *skuId;
@property(nonatomic, strong) NSString *productId;
@property(nonatomic, assign) GYStore store;
@end

@implementation GYSkuBase (Private)

- (instancetype)initWithObject:(NSDictionary *)obj error:(NSError ** _Nullable)error
{
    self = [super init];
    if (self) {
        NSString *skuId = obj[@"identifier"];
        if ([skuId isKindOfClass:NSString.class] && skuId.length) {
            self.skuId = skuId;
        }
        
        NSString *productId = obj[@"productid"];
        if ([productId isKindOfClass:NSString.class] && productId.length) {
            self.productId = productId;
        }
        
        NSString *store = obj[@"store"];
        if ([store isKindOfClass:NSString.class]) {
            self.store = store.integerValue;
        }
    }
    
    if (!self.skuId || !self.productId || self.store == 0) {
        if (error) {
            *error = [GYError serverError:GYErrorCodeUnknow description:@"Unexpected GYSkuBase data format: missing identifier/productId"];
        }
        return nil;
    }
    
    return self;
}

@end

@implementation GYSkuBase

#pragma mark - Deprecations

- (NSString *)identifier
{
    return self.skuId;
}

@end
