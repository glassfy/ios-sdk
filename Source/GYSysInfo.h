//
//  GYSysInfo.h
//  Glassfy
//
//  Created by Luca Garbolino on 22/03/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GYSysInfo : NSObject
@property(class, nonatomic, strong, readonly) NSString *installationInfo;
@property(class, nonatomic, strong, readonly, nullable) NSNotificationName applicationDidBecomeActiveNotification;
@end

NS_ASSUME_NONNULL_END
