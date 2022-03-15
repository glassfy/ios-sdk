//
//  GYAPIPaywallResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 13/10/21.
//

#import "GYAPIPaywallResponse.h"
#import "GYAPIBaseResponse.h"
#import "GYError.h"
#import "GYSku+Private.h"

@implementation GYAPIPaywallResponse
- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError **)error
{
    self = [super initWithObject:obj error:error];
    if (error && *error) {
        return self;
    }
    
    if (self) {
        NSDictionary *paywall = obj[@"paywall"];
        if ([paywall isKindOfClass:NSDictionary.class]) {
            NSString *content = paywall[@"content"];
            if ([content isKindOfClass:NSString.class]) {
                self.content = content;
            }
            
            NSString *locale = paywall[@"locale"];
            if ([locale isKindOfClass:NSString.class]) {
                self.locale = locale;
            }
            
            NSString *pwid = paywall[@"pwid"];
            if ([pwid isKindOfClass:NSString.class]) {
                self.pwid = pwid;
            }
        }
        
        NSMutableArray *skus = [NSMutableArray array];
        NSArray *skusJSON = obj[@"skus"];
        if ([skusJSON isKindOfClass:NSArray.class]) {
            for (NSDictionary *skuJSON in skusJSON) {
                if (![skuJSON isKindOfClass:NSDictionary.class] || skuJSON.allKeys.count == 0) {
                    continue;
                }
                
                //ToDo manage error
                GYSku *s = [[GYSku alloc] initWithObject:skuJSON error:error];
                if (s) {
                    [skus addObject:s];
                }
            }
        }
        self.skus = skus;
        
        
        // verify
        if (!self.content) {
            *error = [GYError serverError:GYErrorCodeUnknow description:@"Unexpected data format"];
        }
    }
    return self;
}
@end
