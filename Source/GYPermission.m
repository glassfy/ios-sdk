//
//  GYPermission.m
//  Glassfy
//
//  Created by Luca Garbolino on 07/01/21.
//

#import "GYPermission.h"

@interface GYPermission()
@property(nonatomic, readwrite, strong) NSString *permissionId;
@property(nonatomic, assign) GYEntitlement entitlement;
@property(nonatomic, readwrite, strong) NSDate *expireDate;
@property(nonatomic, readwrite, strong) NSSet<NSString*> *accountableSkus;
@end

@implementation GYPermission (Private)

+ (instancetype)permissionWithIdentifier:(NSString *)identifier
                             entitlement:(GYEntitlement)entitlement
                                  expire:(NSDate *)date
                         accountableSkus:(NSSet<NSString*> *)skuIds
{
    GYPermission *permission = [[self alloc] init];
    permission.permissionId = identifier;
    permission.entitlement = entitlement;
    permission.expireDate = date;
    permission.accountableSkus = skuIds;
    return permission;
}

@end

@implementation GYPermission

- (BOOL)isValid
{
    return self.entitlement > 0;
}


#pragma mark - Deprecations

- (NSString *)permissionIdentifier {
    return self.permissionId;
}

@end
