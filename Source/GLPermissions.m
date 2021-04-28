//
//  GLPermissions.m
//  Glassfy
//
//  Created by Luca Garbolino on 22/02/21.
//

#import "GLPermissions+Private.h"
#import "GLAPIPermissionsResponse.h"

@interface GLPermissions()
@property(nonatomic, readwrite, strong) NSArray<GLPermission *> *all;
@property(nonatomic, readwrite, strong) NSString *originalApplicationVersion;
@property(nonatomic, readwrite, strong) NSDate *originalApplicationDate;
@end

@implementation GLPermissions (Private)

+ (instancetype)permissionsWithResponse:(GLAPIPermissionsResponse *)response
{
    GLPermissions *installation = [GLPermissions new];
    installation.all = response.permissions ?: @[];
    installation.originalApplicationVersion = response.originalApplicationVersion;
    installation.originalApplicationDate = response.originalApplicationDate;
    
    return installation;
}

@end

@implementation GLPermissions
@end
