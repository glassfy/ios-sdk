//
//  GYAPIPermissionsResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 07/01/21.
//

#import <Foundation/Foundation.h>
#import "GYAPIBaseResponse.h"
@class GYPermission;


NS_ASSUME_NONNULL_BEGIN

@interface GYAPIPermissionsResponse: GYAPIBaseResponse
@property(nonatomic, strong) NSArray<GYPermission *> *permissions;
@property(nonatomic, strong) NSString *originalApplicationVersion;
@property(nonatomic, strong) NSDate *originalApplicationDate;
@end

NS_ASSUME_NONNULL_END
