//
//  GYSysInfo.m
//  Glassfy
//
//  Created by Luca Garbolino on 22/03/21.
//

#import "Glassfy.h"
#import "GYSysInfo.h"
#import <TargetConditionals.h>
#include <sys/sysctl.h>

#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
#endif

@implementation GYSysInfo

typedef NS_ENUM(NSUInteger, GYSubplatform) {
    GYSubplatformUnknown = 0,
    GYSubplatformiOS = 1,
    GYSubplatformCatalyst = 2,
    GYSubplatformTV = 3,
    GYSubplatformWatch = 4,
    GYSubplatformOSx = 5,
    GYSubplatformDrive = 6,
    GYSubplatformSimulator = 7
};

+ (NSString *)installationInfo
{
    // store      : sub-platform : os version : device type : sdkVersion : appVersion
    // 1(== Apple): 1 (== iOS)   : 14.0       : iPhone 10,1 : dev        : 1111-1.0.0
    //
    return [NSString stringWithFormat:@"1:%@:%@:%@:%@:%@",
            @(self.subplatform),
            self.systemVersion,
            self.sysInfo,
            Glassfy.sdkVersion,
            self.appVersion];
}

+ (GYSubplatform)subplatform
{
    GYSubplatform subplatform = GYSubplatformUnknown;
#if TARGET_OS_IPHONE
    #if TARGET_OS_SIMULATOR
    subplatform = GYSubplatformSimulator;
    #elif TARGET_OS_TV
    subplatform = GYSubplatformTV;
    #elif TARGET_OS_WATCH
    subplatform = GYSubplatformWatch;
    #elif TARGET_OS_MACCATALYST
    subplatform = GYSubplatformCatalyst;
    #else
    subplatform = GYSubplatformiOS;
    #endif
#elif TARGET_OS_OSX
    subplatform = GYSubplatformOSx;
#elif TARGET_OS_DRIVERKIT
    subplatform = GYSubplatformDrive;
#endif
    return subplatform;
}

+ (NSNotificationName)applicationDidBecomeActiveNotification
{
    NSNotificationName notification;
#if TARGET_OS_IOS  || TARGET_OS_TV
    notification = UIApplicationDidBecomeActiveNotification;
#elif TARGET_OS_OSX
    notification = NSApplicationDidBecomeActiveNotification;
#endif
    return notification;
}


+ (NSString *)appVersion
{
    NSString *bundleVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    NSString *appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    
    return [NSString stringWithFormat:@"%@-%@", bundleVersion, appVersion];
}

+ (NSString *)systemVersion
{
    NSString *systemVersion;
#if TARGET_OS_IPHONE
    systemVersion = UIDevice.currentDevice.systemVersion;
#else
    NSOperatingSystemVersion v = [NSProcessInfo processInfo].operatingSystemVersion;
    systemVersion = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)v.majorVersion, (long)v.minorVersion, (long)v.patchVersion];
#endif
    return systemVersion;
}

+ (NSString *)sysInfo
{
    NSString *result = nil;
    
    size_t size;
    int mib[2];
    mib[0] = CTL_HW;
    if (@available(iOS 14.0, macOS 11.0, watchOS 7.0, *)) {
        mib[1] = HW_PRODUCT;
    }
    else {
        mib[1] = HW_MACHINE;
    }
    if (sysctl(mib, 2, NULL, &size, NULL, 0) < 0) {
        return nil;
    }
    
    char *answer = malloc(size);
    if (sysctl(mib, 2, answer, &size, NULL, 0) < 0) {
        free(answer);
        return nil;
    }
    
    result = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    free(answer);
    
    return result;
}

@end

