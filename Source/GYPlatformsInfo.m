//
//  GYPlatformsInfo.m
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import "GYPlatformsInfo.h"
#import "GYAPIPlatformInfoResponse.h"

@interface GYPlatformsInfo()
@property(nonatomic, strong) NSArray<GYPlatformInfo *> *all;
@end

@implementation GYPlatformsInfo (Private)

+ (instancetype)platformsInfoWithResponse:(GYAPIPlatformInfoResponse *_Nullable)response
{
    GYPlatformsInfo *platformsInfo = [[self alloc] init];
    platformsInfo.all = response.info ?: @[];
    
    return platformsInfo;
}

@end

@implementation GYPlatformsInfo

- (NSArray<GYPlatformInfo *> *)filter:(GYPlatform)type
{
    return [self.all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"platform == %@", @(type)]];
}

@end
