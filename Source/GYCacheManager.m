//
//  GYCacheManager.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import "GYCacheManager.h"

#define kGYInstallationId @"kGYInstallationId"
#define kGYUserId @"kGYUserId"

@interface GYCacheManager()
@property(nonatomic, readwrite, strong) NSString *installationId;
@end

@implementation GYCacheManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *installationId = [NSUserDefaults.standardUserDefaults stringForKey:kGYInstallationId];
        if (![installationId isKindOfClass:NSString.class] || installationId.length == 0) {
            installationId = NSUUID.UUID.UUIDString;
            [NSUserDefaults.standardUserDefaults setObject:installationId forKey:kGYInstallationId];
        }
        self.installationId = installationId;
    }
    return self;
}

+ (void)resetIds
{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kGYInstallationId];
}

@end
