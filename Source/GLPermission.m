//
//  GLPermission.m
//  Glassfy
//
//  Created by Luca Garbolino on 07/01/21.
//

#import "GLPermission.h"

@interface GLPermission()
@property(nonatomic, readwrite, strong) NSString *permissionIdentifier;
@property(nonatomic, assign) GLEntitlement entitlement;
@property(nonatomic, readwrite, strong) NSDate *expireDate;
@end

@implementation GLPermission (Private)

+ (instancetype)permissionWithIdentifier:(NSString *)identifier entitlement:(GLEntitlement)entitlement expire:(NSDate *)date
{
    GLPermission *permission = [[self alloc] init];
    permission.permissionIdentifier = identifier;
    permission.entitlement = entitlement;
    permission.expireDate = date;
    return permission;
}

@end

@implementation GLPermission

- (BOOL)isValid
{
    return self.entitlement > 0;
}

@end
