//
//  GYPermissions.m
//  Glassfy
//
//  Created by Luca Garbolino on 22/02/21.
//

#import "GYPermissions+Private.h"
#import "GYPermission+Private.h"
#import "GYAPIPermissionsResponse.h"

@interface GYPermissions()
@property(nonatomic, readwrite, strong) NSArray<GYPermission *> *all;
@property(nonatomic, readwrite, strong) NSString *originalApplicationVersion;
@property(nonatomic, readwrite, strong) NSDate *originalApplicationDate;
@end

@implementation GYPermissions (Private)

+ (instancetype)permissionsWithResponse:(GYAPIPermissionsResponse *)response
{
    GYPermissions *installation = [GYPermissions new];
    installation.all = response.permissions ?: @[];
    installation.originalApplicationVersion = response.originalApplicationVersion;
    installation.originalApplicationDate = response.originalApplicationDate;
    
    return installation;
}

@end

@implementation GYPermissions

#pragma mark - Custom Keyed Subscripting method

- (nullable GYPermission *)objectForKeyedSubscript:(NSString *)identifier
{
    GYPermission *result = nil;
    if (!self.all || self.all.count == 0) {
        return result;
    }
        
    for (GYPermission *o in self.all) {
        if ([o.permissionIdentifier isEqualToString:identifier]) {
            result = o;
            break;
        }
    }
    
    return result;
}

@end
