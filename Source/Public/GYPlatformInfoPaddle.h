//
//  GYPlatformInfoPaddle.h
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import <Foundation/Foundation.h>
#if __has_include(<Glassfy/GYPlatformInfo.h>)
#import <Glassfy/GYPlatformInfo.h>
#else
#import "GYPlatformInfo.h"
#endif


NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Glassfy.PlatformInfoPaddle)
@interface GYPlatformInfoPaddle : GYPlatformInfo
@property(nonatomic, nullable, readonly) NSString *userId;
@property(nonatomic, nullable, readonly) NSString *planId;
@property(nonatomic, nullable, readonly) NSString *subscriptionId;

@property(nonatomic, nullable, readonly) NSURL *updateURL;
@property(nonatomic, nullable, readonly) NSURL *cancelURL;
@end

NS_ASSUME_NONNULL_END
