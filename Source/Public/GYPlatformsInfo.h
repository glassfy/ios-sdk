//
//  GYPlatformsInfo.h
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYTypes.h>)
#import <Glassfy/GYTypes.h>
#else
#import "GYTypes.h"
#endif
@class GYPlatformInfo;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.PlatformsInfo)
@interface GYPlatformsInfo : NSObject
@property(nonatomic, readonly) NSArray<GYPlatformInfo *> *all;

- (NSArray<GYPlatformInfo *> *)filter:(GYPlatform)type;
@end

NS_ASSUME_NONNULL_END
