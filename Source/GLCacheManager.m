//
//  GLCacheManager.m
//  Glassfy
//
//  Created by Luca Garbolino on 18/12/20.
//

#import "GLCacheManager.h"

#define kGLInstallationId @"kGLInstallationId"
#define kGLUserId @"kGLUserId"

@interface GLCacheManager()
@property(nonatomic, readwrite, strong) NSString *installationId;
@end

@implementation GLCacheManager

- (instancetype)initWithUserId:(nullable NSString *)userId
{
    self = [super init];
    if (self) {
        self.userId = userId;
        
        NSString *installationId = [NSUserDefaults.standardUserDefaults stringForKey:kGLInstallationId];
        if (![installationId isKindOfClass:NSString.class] || installationId.length == 0) {
            installationId = NSUUID.UUID.UUIDString;
            [NSUserDefaults.standardUserDefaults setObject:installationId forKey:kGLInstallationId];
        }
        self.installationId = installationId;
    }
    return self;
}

+ (void)resetIds
{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:kGLInstallationId];
}

@end
