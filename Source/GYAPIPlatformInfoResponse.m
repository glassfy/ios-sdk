//
//  GYAPIPlatformInfoResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import "GYAPIPlatformInfoResponse.h"
#import "GYPlatformInfo+Private.h"

@implementation GYAPIPlatformInfoResponse
- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError **)error
{
    self = [super initWithObject:obj error:error];
    if (error && *error) {
        return self;
    }
    
    if (self) {
        NSMutableArray<GYPlatformInfo*> *platformsInfo = [NSMutableArray array];
        if ([obj[@"info"] isKindOfClass:NSArray.class]) {
            NSArray *infoJSON = obj[@"info"];
            for (NSDictionary *platformInfoJSON in infoJSON) {
                if (![platformInfoJSON isKindOfClass:NSDictionary.class]) {
                    continue;
                }
                
                GYPlatformInfo *platformInfo = [[GYPlatformInfo alloc] initWithObject:platformInfoJSON error:nil];
                if (platformInfo) {
                    [platformsInfo addObject:platformInfo];
                }
            }
        }
        self.info = platformsInfo;
    }
    return self;
}
@end
