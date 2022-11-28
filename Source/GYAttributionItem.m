//
//  GYAttributionItem.h
//  Glassfy
//
//  Created by Luca Garbolino on 02/11/22.
//

#import "GYAttributionItem+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface GYAttributionItem()
@property(nonatomic, strong, nullable) NSString *value;
@property(nonatomic, assign) GYAttributionType type;
@end

@implementation GYAttributionItem (Private)

- (id)encodedObject
{
    NSMutableDictionary *attributionInfo = [NSMutableDictionary dictionary];
    NSString *nameStr = [self.class attributionTypeToString:self.type];
    attributionInfo[nameStr] = self.value ?: [NSNull null];
    
    return [NSDictionary dictionaryWithDictionary:attributionInfo];
}

+ (NSString *)attributionTypeToString:(GYAttributionType)type {
    switch (type) {
        case GYAttributionTypeAdjustID:     return @"adjustid";
        case GYAttributionTypeAppsFlyerID:  return @"appsflyerid";
        case GYAttributionTypeIDFA:         return @"idfa";
        case GYAttributionTypeIDFV:         return @"idfv";
        case GYAttributionTypeIP:           return @"ip";
    }
}

@end

@implementation GYAttributionItem

+ (instancetype)attributionItemWithType:(GYAttributionType)type value:(NSString *_Nullable)value
{
    GYAttributionItem *item = [GYAttributionItem new];
    item.type = type;
    item.value = value;
    
    return item;
}

@end

NS_ASSUME_NONNULL_END
