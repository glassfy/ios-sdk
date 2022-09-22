//
//  GYAPIPermissionsResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 07/01/21.
//

#import "GYAPIPermissionsResponse.h"
#import "GYError.h"
#import "GYAccountableSku+Private.h"
#import "GYPermission+Private.h"

@implementation GYAPIPermissionsResponse

- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError **)error
{
    self = [super initWithObject:obj error:error];
    if (error && *error) {
        return self;
    }
    
    if (self) {
        NSMutableArray<GYPermission*> *permissions = [NSMutableArray array];
        if ([obj[@"permissions"] isKindOfClass:NSArray.class]) {
            NSArray *permissionsJSON = obj[@"permissions"];
            for (NSDictionary *permissionJSON in permissionsJSON) {
                if (![permissionJSON isKindOfClass:NSDictionary.class]) {
                    continue;
                }
                
                NSString *identifier = permissionJSON[@"identifier"];
                if ([identifier isKindOfClass:NSString.class] && identifier.length) {
                    NSString *entitlementJSON = permissionJSON[@"entitlement"];
                    if ([entitlementJSON isKindOfClass:NSString.class]) {
                        NSDate *expireDate = nil;
                        NSNumber *dateJSON = permissionJSON[@"expires_date"];
                        if ([dateJSON isKindOfClass:NSNumber.class] && dateJSON.integerValue > 0) {
                            expireDate = [NSDate dateWithTimeIntervalSince1970:dateJSON.integerValue];
                        }
                        
                        NSMutableSet<GYAccountableSku*> *accountableSkus = [NSMutableSet set];
                        NSArray *accountableSkusJSON = permissionJSON[@"skuarray"];
                        if ([accountableSkusJSON isKindOfClass:NSArray.class]) {
                            for (NSDictionary *baseSkuJSON in accountableSkusJSON) {
                                if (![baseSkuJSON isKindOfClass:NSDictionary.class]) {
                                    continue;
                                }
                                GYAccountableSku *baseSku = [[GYAccountableSku alloc] initWithObject:baseSkuJSON error:nil];
                                if (baseSku) {
                                    [accountableSkus addObject:baseSku];
                                }
                            }
                        }
                        
                        GYPermission *permission = [GYPermission permissionWithIdentifier:identifier
                                                                              entitlement:entitlementJSON.integerValue
                                                                                   expire:expireDate
                                                                          accountableSkus:accountableSkus];
                        [permissions addObject:permission];
                    }
                }
            }
        }
        self.permissions = permissions;
        
        NSString *originalApplicationVersion = obj[@"original_application_version"];
        if ([originalApplicationVersion isKindOfClass:NSString.class] && originalApplicationVersion.length > 0) {
            self.originalApplicationVersion = originalApplicationVersion;
        }
        
        NSNumber *originalApplicationDate = obj[@"original_purchase_date"];
        if ([originalApplicationDate isKindOfClass:NSNumber.class] && originalApplicationDate.integerValue > 0) {
            self.originalApplicationDate = [NSDate dateWithTimeIntervalSince1970:originalApplicationDate.integerValue];
        }
        
        NSString *subscriberId = obj[@"subscriberid"];
        if ([subscriberId isKindOfClass:NSString.class] && subscriberId.length > 0) {
            self.subscriberId = subscriberId;
        }
        
    }
    return self;
}

@end
