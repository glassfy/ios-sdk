//
//  GYStoreInfo.m
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import "GYStoreInfo.h"
#import "GYStoreInfoPaddle.h"
#import "GYLogger.h"

@interface GYStoreInfo()
@property(nonatomic, assign) GYStore store;
@property(nonatomic, strong) NSDictionary *rawInfo;
@end

@implementation GYStoreInfo (Private)

- (instancetype)initWithObject:(NSDictionary *)obj error:(NSError ** _Nullable)error
{
    NSString *store = obj[@"store"];
    if (![store isKindOfClass:NSString.class] || store.integerValue == 0) {
        return nil;
    }
    
    switch (store.integerValue) {
        case GYStorePaddle:
            self = [GYStoreInfoPaddle new];
            break;
        case GYStoreAppStore || GYStorePlayStore:
            self = [super init];
            break;
        default:
            GYLog(@"PLATFORM Unknown type: %@", store);
            self = [super init];
            break;
    }

    if (self) {
        NSMutableDictionary *rawInfo = [NSMutableDictionary dictionaryWithDictionary:obj];
        [rawInfo removeObjectForKey:@"store"];
        self.rawInfo = rawInfo;
        self.store = store.integerValue;
    }
    return self;
}

@end

@implementation GYStoreInfo
@end
