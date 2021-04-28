//
//  GLInstallation+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 22/02/21.
//

#import "GLPermissions.h"
@class GLAPIPermissionsResponse;

NS_ASSUME_NONNULL_BEGIN

@interface GLPermissions (Private)

+ (instancetype)permissionsWithResponse:(GLAPIPermissionsResponse * _Nullable)permission;

@end

NS_ASSUME_NONNULL_END
