//
//  GYInstallation+Private.h
//  Glassfy
//
//  Created by Luca Garbolino on 22/02/21.
//

#import "GYPermissions.h"
@class GYAPIPermissionsResponse;

NS_ASSUME_NONNULL_BEGIN

@interface GYPermissions (Private)

+ (instancetype)permissionsWithResponse:(GYAPIPermissionsResponse * _Nullable)permission
                         installationId:(NSString * _Nullable)installationId;

@end

NS_ASSUME_NONNULL_END
