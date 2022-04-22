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
@property(nonatomic, strong) NSArray<GYPermission*> *permissions;
@property(nonatomic, nullable, strong) NSString *originalApplicationVersion;
@property(nonatomic, nullable, strong) NSDate *originalApplicationDate;
@property(nonatomic, nullable, strong) NSString *subscriberId;
@end

NS_ASSUME_NONNULL_END
