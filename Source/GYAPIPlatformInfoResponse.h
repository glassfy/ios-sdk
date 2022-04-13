//
//  GYAPIPlatformInfoResponse.h
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import <Foundation/Foundation.h>
#import "GYAPIBaseResponse.h"
@class GYPlatformInfo;

NS_ASSUME_NONNULL_BEGIN

@interface GYAPIPlatformInfoResponse : GYAPIBaseResponse
@property(nonatomic, strong) NSArray<GYPlatformInfo*> *info;
@end

NS_ASSUME_NONNULL_END
