//
//  GYAPIStoreInfoResponse.m
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import "GYAPIStoreInfoResponse.h"
#import "GYStoreInfo+Private.h"

@implementation GYAPIStoreInfoResponse
- (instancetype _Nullable)initWithObject:(NSDictionary *)obj error:(NSError **)error
{
    self = [super initWithObject:obj error:error];
    if (error && *error) {
        return self;
    }
    
    if (self) {
        NSMutableArray<GYStoreInfo*> *storesInfo = [NSMutableArray array];
        if ([obj[@"info"] isKindOfClass:NSArray.class]) {
            NSArray *infoJSON = obj[@"info"];
            for (NSDictionary *storeInfoJSON in infoJSON) {
                if (![storeInfoJSON isKindOfClass:NSDictionary.class]) {
                    continue;
                }
                
                GYStoreInfo *storeInfo = [[GYStoreInfo alloc] initWithObject:storeInfoJSON error:nil];
                if (storeInfo) {
                    [storesInfo addObject:storeInfo];
                }
            }
        }
        self.info = storesInfo;
    }
    return self;
}
@end
