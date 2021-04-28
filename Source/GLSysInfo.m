//
//  GLSysInfo.m
//  Glassfy
//
//  Created by Luca Garbolino on 22/03/21.
//

#import "Glassfy.h"
#import "GLSysInfo.h"
#import <TargetConditionals.h>
#include <sys/sysctl.h>

#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
#endif

@implementation GLSysInfo

typedef NS_ENUM(NSUInteger, GLSubplatform) {
    GLSubplatformUnknown = 0,
    GLSubplatformiOS = 1,
    GLSubplatformCatalyst = 2,
    GLSubplatformTV = 3,
    GLSubplatformWatch = 4,
    GLSubplatformOSx = 5,
    GLSubplatformDrive = 6,
    GLSubplatformSimulator = 7
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

+ (GLSubplatform)subplatform
{
    GLSubplatform subplatform = GLSubplatformUnknown;
#if TARGET_OS_IPHONE
    #if TARGET_OS_SIMULATOR
    subplatform = GLSubplatformSimulator;
    #elif TARGET_OS_TV
    subplatform = GLSubplatformTV;
    #elif TARGET_OS_WATCH
    subplatform = GLSubplatformWatch;
    #elif TARGET_OS_MACCATALYST
    subplatform = GLSubplatformCatalyst;
    #else
    subplatform = GLSubplatformiOS;
    #endif
#elif TARGET_OS_OSX
    subplatform = GLSubplatformOSx;
#elif TARGET_OS_DRIVERKIT
    subplatform = GLSubplatformDrive;
#endif
    return subplatform;
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

