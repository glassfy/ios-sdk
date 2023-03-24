//
//  GYInitializeOptions.m
//  Glassfy
//
//  Created by Luca Garbolino on 23/03/23.
//

#import "GYInitializeOptions.h"

@interface GYInitializeOptions()
@property(nonatomic, readwrite, strong) NSString *apiKey;
@end

@implementation GYInitializeOptions


+ (instancetype)initializeOptionsWithAPIKey:(NSString *)apiKey
{
    return [[self alloc] initWithAPIKey:apiKey];
}

- (GYInitializeOptions *)watcherMode:(BOOL)enable
{
    self.watcherMode = enable;
    return self;
}

- (GYInitializeOptions *)crossPlatformSdkFramework:(NSString *)framework
{
    self.crossPlatformSdkFramework = framework;
    return self;
}

- (GYInitializeOptions *)crossPlatformSdkVersion:(NSString *)version
{
    self.crossPlatformSdkVersion = version;
    return self;
}


#pragma mark - private

- (instancetype)initWithAPIKey:(NSString *)apiKey
{
    self = [super init];
    if (self) {
        _apiKey = apiKey;
    }
    return self;
}

@end
