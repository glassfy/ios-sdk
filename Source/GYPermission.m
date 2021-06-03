//
//  GYPermission.m
//  Glassfy
//
//  Created by Luca Garbolino on 07/01/21.
//

#import "GYPermission.h"

@interface GYPermission()
@property(nonatomic, readwrite, strong) NSString *permissionIdentifier;
@property(nonatomic, assign) GYEntitlement entitlement;
@property(nonatomic, readwrite, strong) NSDate *expireDate;
@end

@implementation GYPermission (Private)

+ (instancetype)permissionWithIdentifier:(NSString *)identifier entitlement:(GYEntitlement)entitlement expire:(NSDate *)date
{
    GYPermission *permission = [[self alloc] init];
    permission.permissionIdentifier = identifier;
    permission.entitlement = entitlement;
    permission.expireDate = date;
    return permission;
}

@end

@implementation GYPermission

- (BOOL)isValid
{
    return self.entitlement > 0;
}

@end
