//
//  GLAPIPermissionsResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 07/01/21.
//

#import "GLAPIPermissionsResponse.h"
#import "GLError.h"
#import "GLPermission+Private.h"

@implementation GLAPIPermissionsResponse

- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError **)error
{
    self = [super initWithObject:obj error:error];
    if (error && *error) {
        return self;
    }
    
    if (self) {
        NSMutableArray<GLPermission *> *permissions = [NSMutableArray array];
        if ([obj[@"permissions"] isKindOfClass:NSArray.class]) {
            NSArray *permissionsJSON = obj[@"permissions"];
            for (NSDictionary *permissionJSON in permissionsJSON) {
                if (![permissionJSON isKindOfClass:[NSDictionary class]]) {
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
                        GLPermission *permission = [GLPermission permissionWithIdentifier:identifier
                                                                              entitlement:entitlementJSON.integerValue
                                                                                   expire:expireDate];
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
    }
    return self;
}

@end
