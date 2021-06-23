//
//  GYAPISkuResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 15/06/21.
//

#import "GYAPISkuResponse.h"
#import "GYSku+Private.h"
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
            self.sku = [[GYSku alloc] initWithObject:sku error:error];
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
