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
@property(nonatomic, readwrite, strong) NSArray<GYPermission*> *all;
@property(nonatomic, readwrite, strong) NSString *originalApplicationVersion;
@property(nonatomic, readwrite, strong) NSDate *originalApplicationDate;
@property(nonatomic, readwrite, strong) NSString *subscriberId;
@property(nonatomic, readwrite, strong) NSString *installationId;
@end

@implementation GYPermissions (Private)

+ (instancetype)permissionsWithResponse:(GYAPIPermissionsResponse *)response installationId:(NSString *)installationId
{
    GYPermissions *installation = [[self alloc] init];
    installation.all = response.permissions ?: @[];
    installation.originalApplicationVersion = response.originalApplicationVersion;
    installation.originalApplicationDate = response.originalApplicationDate;
    installation.subscriberId = response.subscriberId;
    installation.installationId = installationId;
    
    return installation;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.all = @[];
    }
    return self;
}

@end

@implementation GYPermissions

#pragma mark - Custom Keyed Subscripting method

- (nullable GYPermission *)objectForKeyedSubscript:(NSString *)permissionid
{
    GYPermission *result = nil;
    if (!self.all || self.all.count == 0) {
        return result;
    }
        
    for (GYPermission *o in self.all) {
        if ([o.permissionId isEqualToString:permissionid]) {
            result = o;
            break;
        }
    }
    
    return result;
}

@end
