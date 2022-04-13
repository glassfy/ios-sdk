//
//  GYPlatformInfo.m
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import "GYPlatformInfo.h"
#import "GYPlatformInfoPaddle.h"
#import "GYLogger.h"

@interface GYPlatformInfo()
@property(nonatomic, assign) GYPlatform platform;
@property(nonatomic, strong) NSDictionary *rawInfo;
@end

@implementation GYPlatformInfo (Private)

- (instancetype)initWithObject:(NSDictionary *)obj error:(NSError ** _Nullable)error
{
    NSString *platform = obj[@"platform"];
    if (![platform isKindOfClass:NSString.class] || platform.integerValue == 0) {
        return nil;
    }
    
    switch (platform.integerValue) {
        case GYPlatformPaddle:
            self = [GYPlatformInfoPaddle new];
            break;
        case GYPlatformIos || GYPlatformAndroid:
            self = [super init];
            break;
        default:
            GYLog(@"PLATFORM Unknown type: %@", platform);
            self = [super init];
            break;
    }

    if (self) {
        NSMutableDictionary *rawInfo = [NSMutableDictionary dictionaryWithDictionary:obj];
        [rawInfo removeObjectForKey:@"platform"];
        self.rawInfo = rawInfo;
        self.platform = platform.integerValue;
    }
    return self;
}

@end

@implementation GYPlatformInfo
@end
