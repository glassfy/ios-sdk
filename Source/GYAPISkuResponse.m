//
//  GYAPISkuResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 15/06/21.
//

#import "GYAPISkuResponse.h"
#import "GYSkuBase+Private.h"
#import "GYSkuPaddle+Private.h"
#import "GYError.h"

@implementation GYAPISkuResponse

- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError **)error
{
    self = [super initWithObject:obj error:error];
    if (error && *error) {
        return self;
    }
    
    if (self) {
        NSDictionary *sku = obj[@"sku"];
        if ([sku isKindOfClass:NSDictionary.class] && sku.allKeys.count > 0) {
            NSString *store = sku[@"store"];
            if (![store isKindOfClass:NSString.class] || store.integerValue == 0) {
                if (error) {
                    *error = [GYError serverError:GYErrorCodeUnknow description:@"Unexpected sku data format"];
                }
                return self;
            }
            
            switch (store.integerValue) {
                case GYStoreAppStore:
                    self.sku = [[GYSku alloc] initWithObject:sku error:error];
                    break;
                case GYStorePaddle:
                    self.sku = [[GYSkuPaddle alloc] initWithObject:sku error:error];
                    break;
                default:
                    self.sku = [[GYSkuBase alloc] initWithObject:sku error:error];
                    break;
            }
        }
        else {
            if (error) {
                *error = [GYError serverError:GYErrorCodeSkuIDNotFound description:@"Sku not found"];
            }
        }
    }
    return self;
}

@end
