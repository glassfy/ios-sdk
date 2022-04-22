//
//  GYStoresInfo.m
//  Glassfy
//
//  Created by Luca Garbolino on 12/04/22.
//

#import "GYStoresInfo.h"
#import "GYAPIStoreInfoResponse.h"

@interface GYStoresInfo()
@property(nonatomic, strong) NSArray<GYStoreInfo*> *all;
@end

@implementation GYStoresInfo (Private)

+ (instancetype)storesInfoWithResponse:(GYAPIStoreInfoResponse *_Nullable)response
{
    GYStoresInfo *storesInfo = [[self alloc] init];
    storesInfo.all = response.info ?: @[];
    
    return storesInfo;
}

@end

@implementation GYStoresInfo

- (NSArray<GYStoreInfo*> *)filter:(GYStore)type
{
    return [self.all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"store == %@", @(type)]];
}

@end
