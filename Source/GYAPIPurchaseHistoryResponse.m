//
//  GYAPIPurchasesHistoryResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 06/03/23.
//

#import "GYAPIPurchaseHistoryResponse.h"
#import "GYPurchaseHistory+Private.h"
#import "GYError.h"

@implementation GYAPIPurchaseHistoryResponse
- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError **)error
{
    self = [super initWithObject:obj error:error];
    if (error && *error) {
        return self;
    }
    
    if (self) {
        NSMutableArray<GYPurchaseHistory*> *purchasesHistory = [NSMutableArray array];
        if ([obj[@"purchases"] isKindOfClass:NSArray.class]) {
            NSArray *purchasesJSON = obj[@"purchases"];
            for (NSDictionary *purchaseJSON in purchasesJSON) {
                if (![purchaseJSON isKindOfClass:NSDictionary.class]) {
                    continue;
                }
                
                GYPurchaseHistory *purchase = [[GYPurchaseHistory alloc] initWithObject:purchaseJSON error:nil];
                if (purchase) {
                    [purchasesHistory addObject:purchase];
                }
            }
        }
        self.purchasesHistory = purchasesHistory;
        
        NSString *subscriberId = obj[@"subscriberid"];
        if ([subscriberId isKindOfClass:NSString.class] && subscriberId.length > 0) {
            self.subscriberId = subscriberId;
        }
        NSString *customId = obj[@"customid"];
        if ([customId isKindOfClass:NSString.class] && customId.length > 0) {
            self.customId = customId;
        }
        
        if (!self.subscriberId.length) {
            if (error) {
                *error = [GYError serverError:GYErrorCodeUnknow description:@"Unexpected APIPurchaseHistory data format: missing subscriberId"];
            }
            return nil;
        }
    }
    return self;
}
@end
