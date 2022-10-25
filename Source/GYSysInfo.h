//
//  GYSysInfo.h
//  Glassfy
//
//  Created by Luca Garbolino on 22/03/21.
//

#import <Foundation/Foundation.h>
#import "GYInternalType.h"

NS_ASSUME_NONNULL_BEGIN

@interface GYSysInfo : NSObject
@property(class, nonatomic, strong, readonly) NSString *installationInfo;

@property(class, nonatomic, assign, readonly) GYSubplatform subplatform;
@property(class, nonatomic, strong, readonly) NSString *appVersion;
@property(class, nonatomic, strong, readonly) NSString *systemVersion;
@property(class, nonatomic, strong, readonly, nullable) NSString *sysInfo;
@property(class, nonatomic, strong, readonly, nullable) NSNotificationName applicationDidBecomeActiveNotification;
@end

NS_ASSUME_NONNULL_END
